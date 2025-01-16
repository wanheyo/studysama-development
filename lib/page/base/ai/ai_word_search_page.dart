import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search_safety/word_search_safety.dart';

import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class AIWordSearchPage extends StatefulWidget {
  final String content;

  const AIWordSearchPage({Key? key, required this.content}) : super(key: key);

  @override
  _AIWordSearchPageState createState() => _AIWordSearchPageState();
}

class _AIWordSearchPageState extends State<AIWordSearchPage> {
  final ApiService apiService = ApiService();
  // String get domainURL => apiService.domainUrl;
  String token = "";
  User? user;

  List<String> words = [];
  bool isCompleted = false;
  DateTime? startTime;
  Duration? completionTime;
  int needToFound = 0;
  int alreadyFound = 0;

  List<List<String>> grid = [];
  late Set<String> foundWords = {};
  bool isLoading = true;

  // Selection tracking
  Offset? startCell;
  Offset? currentCell;
  bool isSelecting = false;
  List<Offset> selectedCells = [];

  // Track found words with their positions
  Map<String, List<Offset>> foundWordsPositions = {};

  @override
  void initState() {
    super.initState();
    initializeData();

    startTime = DateTime.now();
  }

  Future<void> initializeData() async {
    await loadUser();
    await fetchQuiz();
    // await fetchUserFollow();
    // fetchCourses();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        token = tokenString;
      }

      setState(() {
        // context.loaderOverlay.show();
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        // context.loaderOverlay.hide();
      });
    }
  }

  Future<void> fetchQuiz() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await apiService.generateFindWordFromUrl(widget.content, 7);
      setState(() {
        words = data;

        initializeWordSearch();

        startTime = DateTime.now();
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void initializeWordSearch() {
    setState(() {
      needToFound = words.length;
    });

    final WSSettings settings = WSSettings(
      width: 10,  // Increased grid size
      height: 10, // Increased grid size
      orientations: List.from([
        WSOrientation.horizontal,
        WSOrientation.vertical,
        WSOrientation.diagonal,
      ]),
    );

    final WordSearchSafety wordSearch = WordSearchSafety();
    final WSNewPuzzle newPuzzle = wordSearch.newPuzzle(words, settings);

    if (newPuzzle.errors!.isNotEmpty) {
      print('Puzzle generation errors: ${newPuzzle.errors}');
    } else {
      setState(() {
        grid = newPuzzle.puzzle!;
        foundWords = {};
        isLoading = false;
      });
    }
  }

  List<Offset> getLineBetweenPoints(Offset start, Offset end) {
    List<Offset> points = [];
    int x0 = start.dx.round();
    int y0 = start.dy.round();
    int x1 = end.dx.round();
    int y1 = end.dy.round();

    // Determine the direction
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();

    // Determine primary direction (horizontal, vertical, or diagonal)
    if (dx >= dy) {
      // Horizontal or diagonal
      int step = x0 < x1 ? 1 : -1;
      for (int x = x0; step > 0 ? x <= x1 : x >= x1; x += step) {
        int y = y0 + ((x - x0) * (y1 - y0)) ~/ (x1 - x0);
        points.add(Offset(x.toDouble(), y.toDouble()));
      }
    } else {
      // Vertical or diagonal
      int step = y0 < y1 ? 1 : -1;
      for (int y = y0; step > 0 ? y <= y1 : y >= y1; y += step) {
        int x = x0 + ((y - y0) * (x1 - x0)) ~/ (y1 - y0);
        points.add(Offset(x.toDouble(), y.toDouble()));
      }
    }

    return points;
  }

  String getWordFromSelection() {
    String word = "";
    for (var position in selectedCells) {
      int row = position.dy.toInt();
      int col = position.dx.toInt();
      if (row >= 0 && row < grid.length && col >= 0 && col < grid[row].length) {
        word += grid[row][col];
      }
    }
    return word;
  }

  void checkWord() {
    String selectedWord = getWordFromSelection();
    String reversedWord = String.fromCharCodes(selectedWord.runes.toList().reversed);

    // Check both forward and reversed words
    if (words.contains(selectedWord.toLowerCase())) {
      setState(() {
        alreadyFound++;
        foundWords.add(selectedWord.toUpperCase());
        foundWordsPositions[selectedWord.toUpperCase()] = List.from(selectedCells);

        if(needToFound == alreadyFound) {
          isCompleted = true;
          completionTime = DateTime.now().difference(startTime!);
          _showResultDialog();
        }
      });
    } else if (words.contains(reversedWord.toLowerCase())) {
      setState(() {
        alreadyFound++;
        foundWords.add(reversedWord.toUpperCase());
        foundWordsPositions[reversedWord.toUpperCase()] = List.from(selectedCells.reversed);

        if(needToFound == alreadyFound) {
          isCompleted = true;
          completionTime = DateTime.now().difference(startTime!);
          _showResultDialog();
        }
      });
    }
  }

  bool isCellInFoundWord(int row, int col) {
    Offset cellOffset = Offset(col.toDouble(), row.toDouble());
    return foundWordsPositions.values.any((positions) => positions.contains(cellOffset));
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Results! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //   'Score: $score/${quizItem.length}',
              //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 10),
              Text(
                'Time taken: ${completionTime!.inMinutes}m ${completionTime!.inSeconds % 60}s',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              _getPerformanceMessage(),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Review Answers'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _getPerformanceMessage() {
    if (startTime == null || completionTime == null) {
      return const Text('⏳ Time data not available',
          style: TextStyle(color: Colors.grey));
    }

    // Calculate the total time taken in seconds
    final int totalTimeInSeconds = completionTime!.inSeconds;

    if (totalTimeInSeconds <= 30) {
      return const Text('🌟 Outstanding Speed!',
          style: TextStyle(color: Colors.green));
    } else if (totalTimeInSeconds <= 60) {
      return const Text('👏 Great Pace!', style: TextStyle(color: Colors.blue));
    } else if (totalTimeInSeconds <= 120) {
      return const Text('💪 Good Effort!',
          style: TextStyle(color: Colors.orange));
    } else {
      return const Text('📚 Take Your Time!', style: TextStyle(color: Colors.red));
    }
  }


  Future<bool> _onWillPop() async {
    if (isCompleted) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Quiz?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to leave?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Words may be different when you return.',
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Leave Quiz',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('AI Word Search'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () async {
            if (await _onWillPop()) {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
        actions: [
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    final duration = DateTime.now().difference(startTime!);
                    return Text(
                      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 18),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white,))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Words to find (${alreadyFound.toString()}/${needToFound.toString()}): ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: words.map((word) {
                          bool isFound = foundWords.contains(word.toUpperCase());
                          return Chip(
                            label: Text(
                              word.toUpperCase(),
                              style: TextStyle(
                                // decoration: isFound ? TextDecoration.lineThrough : null,
                                color: isFound ? Colors.white : Colors.black,
                                fontWeight: isFound ? FontWeight.normal : FontWeight.normal,
                              ),
                            ),
                            backgroundColor: isFound
                                ? AppColors.tertiary
                                : AppColors.secondary,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: words.isEmpty ?
                Center(
                  child: ElevatedButton(
                      onPressed: fetchQuiz,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.tertiary, // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Regenerate Quiz')
                  ),
                ) :
            LayoutBuilder(
              builder: (context, constraints) {
                double cellSize = constraints.maxWidth / grid.length;
                return Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: grid.length,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: grid.length * grid.length,
                      itemBuilder: (context, index) {
                        int row = index ~/ grid.length;
                        int col = index % grid.length;
                        bool isSelected = selectedCells.contains(
                            Offset(col.toDouble(), row.toDouble())
                        );
                        bool isFoundWord = isCellInFoundWord(row, col);

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : isFoundWord
                                ? Colors.green.shade100
                                : Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              grid[row][col],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.white
                                    : isFoundWord
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          RenderBox box = context.findRenderObject() as RenderBox;
                          Offset localPosition = box.globalToLocal(details.globalPosition);
                          int col = ((localPosition.dx - 16) / cellSize).floor();
                          int row = ((localPosition.dy - 16) / cellSize).floor();

                          if (col >= 0 && col < grid.length && row >= 0 && row < grid.length) {
                            setState(() {
                              startCell = Offset(col.toDouble(), row.toDouble());
                              currentCell = startCell;
                              isSelecting = true;
                              selectedCells = [startCell!];
                            });
                          }
                        },
                        onPanUpdate: (details) {
                          if (isSelecting && startCell != null) {
                            RenderBox box = context.findRenderObject() as RenderBox;
                            Offset localPosition = box.globalToLocal(details.globalPosition);
                            int col = ((localPosition.dx - 16) / cellSize).floor();
                            int row = ((localPosition.dy - 16) / cellSize).floor();

                            if (col >= 0 && col < grid.length && row >= 0 && row < grid.length) {
                              Offset newCurrentCell = Offset(col.toDouble(), row.toDouble());
                              if (newCurrentCell != currentCell) {
                                setState(() {
                                  currentCell = newCurrentCell;
                                  selectedCells = getLineBetweenPoints(startCell!, currentCell!);
                                });
                              }
                            }
                          }
                        },
                        onPanEnd: (details) {
                          if (isSelecting) {
                            checkWord();
                            setState(() {
                              isSelecting = false;
                              selectedCells = [];
                              startCell = null;
                              currentCell = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}