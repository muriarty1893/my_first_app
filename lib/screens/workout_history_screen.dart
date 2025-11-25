import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/workout_log.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  late Future<List<WorkoutLog>> _workoutLogsFuture;

  @override
  void initState() {
    super.initState();
    _workoutLogsFuture = DatabaseHelper.instance.getWorkoutLogs(date: _selectedDate);
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _workoutLogsFuture = DatabaseHelper.instance.getWorkoutLogs(date: _selectedDate);
    });
  }

  void _onPageChanged(int days) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDate = DateTime.now();
                _selectedDate = DateTime.now();
                _workoutLogsFuture = DatabaseHelper.instance.getWorkoutLogs(date: _selectedDate);
              });
            },
            icon: const Icon(Icons.today),
            tooltip: 'Today',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarView(),
            const SizedBox(height: 24),
            FutureBuilder<List<WorkoutLog>>(
              future: _workoutLogsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text('No workout history for this day.'),
                    ),
                  );
                } else {
                  return _buildWorkoutHistoryList(snapshot.data!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy', 'en_US').format(_focusedDate),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _onPageChanged(-7),
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(25),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _onPageChanged(7),
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(25),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1 - index));
            final isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month && day.year == _selectedDate.year;
            final isToday = day.day == DateTime.now().day && day.month == DateTime.now().month && day.year == DateTime.now().year;

            return GestureDetector(
              onTap: () => _onDaySelected(day),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: isSelected
                    ? BoxDecoration(
                        color: const Color(0xFFD0FD3E),
                        borderRadius: BorderRadius.circular(16),
                      )
                    : (isToday
                        ? BoxDecoration(
                            border: Border.all(color: const Color(0xFFD0FD3E)),
                            borderRadius: BorderRadius.circular(16),
                          )
                        : null),
                child: Column(
                  children: [
                    Text(
                      DateFormat.E('en_US').format(day).substring(0, 1),
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day.day.toString(),
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistoryList(List<WorkoutLog> logs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          color: Colors.grey.withAlpha(51),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              log.exerciseTitle,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${log.sets} sets, ${log.reps} reps',
              style: GoogleFonts.poppins(),
            ),
            trailing: Text(
              DateFormat.yMMMd('en_US').format(log.date),
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}
