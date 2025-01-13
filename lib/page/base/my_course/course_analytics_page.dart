import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/course.dart';
import '../../../models/user_course.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class CourseAnalyticsPage extends StatefulWidget {
  final Course course;
  final List<UserCourse> userCourseList;

  const CourseAnalyticsPage({
    Key? key,
    required this.course,
    required this.userCourseList
  }) : super(key: key);

  @override
  _CourseAnalyticsPageState createState() => _CourseAnalyticsPageState();
}

class _CourseAnalyticsPageState extends State<CourseAnalyticsPage> {
  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;
  String token = "";
  String selectedTimeframe = 'daily';
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    endDate = DateTime.now();
    startDate = endDate!.subtract(const Duration(days: 30));
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUser();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        token = tokenString;
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // Calculate statistics
  int get totalStudents => widget.userCourseList
      .where((user) => user.roleId == 3)
      .length;

  int get activeStudents => widget.userCourseList
      .where((user) => user.roleId == 3 && user.status == 1)
      .length;

  double get averageRating {
    final ratedUsers = widget.userCourseList
        .where((user) => user.rating != null)
        .toList();
    if (ratedUsers.isEmpty) return 0;

    return ratedUsers
        .map((user) => user.rating ?? 0)
        .reduce((a, b) => a + b) / ratedUsers.length;
  }

  List<FlSpot> getEnrollmentSpots() {
    final enrollments = <DateTime, int>{};

    final sortedUsers = widget.userCourseList
        .where((user) => user.roleId == 3 && user.status == 1)
        .toList()
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    int cumulative = 0;
    for (var user in sortedUsers) {
      if (user.createdAt != null) {
        cumulative++;
        enrollments[user.createdAt!] = cumulative;
      }
    }

    return enrollments.entries
        .map((entry) => FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble()))
        .toList();
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Enrollment Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 86400000 * 7, // Show weekly intervals
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getEnrollmentSpots(),
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, Map<String, int>> getJoinLeaveData() {
    final Map<DateTime, Map<String, int>> stats = {};

    for (var user in widget.userCourseList) {
      if (user.createdAt != null) {
        final date = DateTime(
          user.createdAt!.year,
          user.createdAt!.month,
          user.createdAt!.day,
        );

        stats[date] ??= {'joined': 0, 'left': 0};
        if (user.status == 1) {
          stats[date]!['joined'] = stats[date]!['joined']! + 1;
        } else if (user.status == 0) {
          stats[date]!['left'] = stats[date]!['left']! + 1;
        }
      }
    }

    return stats;
  }

  Widget _buildBarChart() {
    final joinLeaveData = getJoinLeaveData().entries
        .where((entry) =>
    (startDate == null || entry.key.isAfter(startDate!)) &&
        (endDate == null || entry.key.isBefore(endDate!)))
        .toList();

    double minSpotX = double.infinity;
    double maxSpotX = double.negativeInfinity;
    double maxSpotY = 0;

    // Prepare data for bar chart
    final List<FlSpot> joinedSpots = [];
    final List<FlSpot> leftSpots = [];

    for (final entry in joinLeaveData) {
      final x = entry.key.millisecondsSinceEpoch.toDouble();
      final joined = entry.value['joined']!.toDouble();
      final left = entry.value['left']!.toDouble();

      joinedSpots.add(FlSpot(x, joined));
      leftSpots.add(FlSpot(x, left));

      if (x > maxSpotX) maxSpotX = x;
      if (x < minSpotX) minSpotX = x;
      if (joined > maxSpotY) maxSpotY = joined;
      if (left > maxSpotY) maxSpotY = left;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join/Leave Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDateRangeSelector(),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.green.shade700,
                        ],
                      ),
                      spots: joinedSpots,
                      isCurved: true,
                      isStrokeCapRound: true,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.red.shade700,
                        ],
                      ),
                      spots: leftSpots,
                      isCurved: true,
                      isStrokeCapRound: true,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: maxSpotY + 2, // Padding for better visualization
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10.0),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialDateRange: startDate != null && endDate != null
                    ? DateTimeRange(start: startDate!, end: endDate!)
                    : null,
              );

              if (range != null) {
                setState(() {
                  startDate = range.start;
                  endDate = range.end;
                });
              }
            },
            child: Text(
              startDate != null && endDate != null
                  ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'
                  : 'Select Date Range',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    // Group events by date
    Map<String, List<dynamic>> groupedEvents = {};
    for (var event in widget.userCourseList) {
      String formattedDate = DateFormat('dd/MM/yyyy, EEEE').format(event.updatedAt!.toLocal());
      if (groupedEvents[formattedDate] == null) {
        groupedEvents[formattedDate] = [];
      }
      groupedEvents[formattedDate]!.add(event);
    }

    return Container(
      height: 500, // Set the height of the card
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Course Timeline',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: groupedEvents.entries.map((entry) {
                      String date = entry.key;
                      List<dynamic> events = entry.value;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: events.length * 6.0, // Adjust based on event height
                                color: AppColors.secondary.withOpacity(0.8),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              Container(
                                width: 4,
                                height: events.length * 140.0, // Adjust based on event height
                                color: AppColors.secondary.withOpacity(0.8),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display date header
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                // Display events for this date
                                Column(
                                  children: events.map((event) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 16), // Offset for alignment
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    DateFormat('hh:mm a').format(event.updatedAt!.toLocal()),
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: event.status == 0
                                                        ? Colors.red.withOpacity(0.5)
                                                        : AppColors.tertiary.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.grey[300],
                                                          image: event.user!.image != null
                                                              ? DecorationImage(
                                                            image: NetworkImage(
                                                                '$domainURL/storage/${event.user!.image!}'),
                                                            fit: BoxFit.cover,
                                                          )
                                                              : null,
                                                        ),
                                                        child: event.user!.image == null
                                                            ? Center(
                                                          child: Text(
                                                            event.user!.username.isNotEmpty
                                                                ? event.user!.username[0].toUpperCase()
                                                                : '?',
                                                            style: const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black54,
                                                            ),
                                                          ),
                                                        )
                                                            : null,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          '${event.user?.name ?? 'Null'} ${event.roleId == 1 ? 'created' : (event.status == 1 ? 'joined' : 'left')} this course${event.status == 0 ? ', joined at ${DateFormat('dd/MM/yyyy').format(event.createdAt!.toLocal())}' : ''}',
                                                          style: TextStyle(fontSize: 14),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Analytics"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Students',
                    totalStudents.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    'Active Students',
                    activeStudents.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    'Average Rating',
                    widget.course.averageRating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // // Filters
            // Row(
            //   children: [
            //     Expanded(
            //       child: DropdownButtonFormField<String>(
            //         value: selectedTimeframe,
            //         items: ['daily', 'weekly', 'monthly']
            //             .map((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Text(value[0].toUpperCase() + value.substring(1)),
            //           );
            //         }).toList(),
            //         onChanged: (String? newValue) {
            //           if (newValue != null) {
            //             setState(() {
            //               selectedTimeframe = newValue;
            //             });
            //           }
            //         },
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //   ],
            // ),
            // const SizedBox(height: 16),

            // Charts
            _buildEnrollmentChart(),
            const SizedBox(height: 16),

            _buildBarChart(),
            const SizedBox(height: 16),

            // Timeline
            _buildTimeline(),
          ],
        ),
      ),
    );
  }
}