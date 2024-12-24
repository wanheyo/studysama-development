import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysama/models/resource.dart';

import '../../../models/lesson.dart';
import '../../../models/quiz.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class AIQuizPage extends StatefulWidget {
  final Resource resource;

  const AIQuizPage({Key? key, required this.resource}) : super(key: key);

  @override
  _AIQuizPageState createState() => _AIQuizPageState();
}

class _AIQuizPageState extends State<AIQuizPage> {
  final ApiService apiService = ApiService();
  // String get domainURL => apiService.domainUrl;
  String token = "";
  User? user;

  // late List<QuizQuestion> questions;
  // Quiz quiz = null;
  List<QuizItem> quizItem = [];
  String title = '';
  // late List<Quiz> questions;
  List<int?> userAnswers = [];
  bool isSubmitted = false;
  DateTime? startTime;
  Duration? completionTime;
  int score = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();

    // Hardcoded test data
    // questions = [
    //   QuizQuestion(
    //     question: "What is the capital of France?",
    //     options: ["Paris", "London", "Berlin", "Madrid"],
    //     answer: "Paris",
    //   ),
    //   QuizQuestion(
    //     question: "What is the capital of Germany?",
    //     options: ["Paris", "London", "Berlin", "Madrid"],
    //     answer: "Berlin",
    //   ),
    //   // Adding more test questions for better demonstration
    //   QuizQuestion(
    //     question: "What is the capital of Spain?",
    //     options: ["Paris", "London", "Berlin", "Madrid"],
    //     answer: "Madrid",
    //   ),
    //   QuizQuestion(
    //     question: "What is the capital of England?",
    //     options: ["Paris", "London", "Berlin", "Madrid"],
    //     answer: "London",
    //   ),
    //   QuizQuestion(
    //     question: "Which city hosted the 2020 Olympics?",
    //     options: ["Beijing", "Tokyo", "London", "Rio"],
    //     answer: "Tokyo",
    //   ),
    // ];
    userAnswers = List.filled(quizItem.length, null);
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
    //print("course_id: " + course_id.toString());

    try {
      final data = await apiService.generateQuizFromUrl(widget.resource.link!);
      setState(() {
        title = data['title'] ?? 'null';

        quizItem = (data['data'] as List)
            .map((json) => QuizItem.fromJson(json))
            .toList();

        userAnswers = List.filled(quizItem.length, null);
        startTime = DateTime.now();

        // isLoading = false;
      });
    } catch (e) {
      setState(() {
        print("Response: " + e.toString());
      });
    } finally {
      setState(() {
        isLoading = false;
        // const SnackBar(
        //   content: Text('Error'),
        //   backgroundColor: Colors.red,
        // );
      });
    }
  }

  void _submitQuiz() {
    if (userAnswers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitted = true;
      completionTime = DateTime.now().difference(startTime!);
      score = _calculateScore();
    });

    _showResultDialog();
  }

  // int _calculateScore() {
  //   int totalCorrect = 0;
  //   for (int i = 0; i < quizItem.length; i++) {
  //     if (userAnswers[i] == quizItem[i].correctAnswerIndex) {
  //       totalCorrect++;
  //     }
  //   }
  //   return totalCorrect;
  // }

  int _calculateScore() {
    int totalCorrect = 0;
    for (int i = 0; i < quizItem.length; i++) {
      if (userAnswers[i] == quizItem[i].answerIndex) {
        totalCorrect++;
      }
    }
    return totalCorrect;
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
              Text(
                'Score: $score/${quizItem.length}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
    double percentage = (score / quizItem.length) * 100;
    if (percentage >= 90) {
      return const Text('🌟 Outstanding Performance!',
          style: TextStyle(color: Colors.green));
    } else if (percentage >= 70) {
      return const Text('👏 Great Job!', style: TextStyle(color: Colors.blue));
    } else if (percentage >= 50) {
      return const Text('💪 Keep Practicing!',
          style: TextStyle(color: Colors.orange));
    } else {
      return const Text('📚 Time for Review!', style: TextStyle(color: Colors.red));
    }
  }

  Future<bool> _onWillPop() async {
    if (isSubmitted) return true;

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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Questions may be different when you return.',
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
        title: Text('AI Generated Quiz'),
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
          if (!isSubmitted)
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
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(color: Colors.white),
      ) :
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizItem.length,
        itemBuilder: (context, index) {
          final question = quizItem[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSubmitted
                      ? (userAnswers[index] == question.correctAnswerIndex
                      ? Colors.green
                      : Colors.red)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      question.options.length,
                          (optionIndex) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: isSubmitted
                              ? null
                              : () {
                            setState(() {
                              userAnswers[index] = optionIndex;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getOptionColor(
                                  index, optionIndex, question.correctAnswerIndex),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: userAnswers[index] == optionIndex
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text(
                                  String.fromCharCode(65 + optionIndex),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(question.options[optionIndex])),
                                if (isSubmitted &&
                                    optionIndex == question.correctAnswerIndex)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: !isSubmitted
          ? FloatingActionButton.extended(
        onPressed: _submitQuiz,
        label: const Text('Submit Quiz', style: TextStyle(fontWeight: FontWeight.bold),),
        icon: const Icon(FontAwesomeIcons.check),
      )
          : null,
    );
  }

  // Color _getOptionColor(int questionIndex, int optionIndex, int correctAnswer) {
  //   if (!isSubmitted) {
  //     return userAnswers[questionIndex] == optionIndex
  //         ? Colors.blue.withOpacity(0.1)
  //         : Colors.white;
  //   }
  //
  //   if (optionIndex == correctAnswer) {
  //     return Colors.green.withOpacity(0.1);
  //   }
  //
  //   if (userAnswers[questionIndex] == optionIndex) {
  //     return Colors.red.withOpacity(0.1);
  //   }
  //
  //   return Colors.white;
  // }

  Color _getOptionColor(int questionIndex, int optionIndex, int correctAnswer) {
    if (!isSubmitted) {
      return userAnswers[questionIndex] == optionIndex
          ? Colors.blue.withOpacity(0.1)
          : Colors.white;
    }

    if (optionIndex == correctAnswer) {
      return Colors.green.withOpacity(0.1);
    }

    if (userAnswers[questionIndex] == optionIndex) {
      return Colors.red.withOpacity(0.1);
    }

    return Colors.white;
  }
}