import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/program_exercise.dart';
import 'package:my_first_app/models/workout_log.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<ProgramExercise>> _todaysExercisesFuture;
  late Future<List<WorkoutLog>> _workoutLogsFuture;

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  void _initFutures() {
    final dbHelper = DatabaseHelper.instance;
    final today = DateFormat('EEEE').format(DateTime.now());
    _todaysExercisesFuture = dbHelper.getProgramExercises().then((exercises) =>
        exercises.where((e) => e.dayOfWeek == today).toList());
    _workoutLogsFuture = dbHelper.getWorkoutLogs();
  }

  void _onDateChanged(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Activity',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.apps),
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
            FutureBuilder<List<ProgramExercise>>(
              future: _todaysExercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildTodaysChallengeCard([]);
                } else {
                  return _buildTodaysChallengeCard(snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<WorkoutLog>>(
              future: _workoutLogsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No workout history.'));
                } else {
                  return _buildWorkoutHistory(snapshot.data!);
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
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _onDateChanged(-7),
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(25),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _onDateChanged(7),
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
            final day = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1 - index));
            return _buildDateColumn(
              DateFormat.E().format(day).substring(0, 1),
              day.day.toString(),
              isActive: day.day == _selectedDate.day,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistory(List<WorkoutLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
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
                  DateFormat.yMMMd().format(log.date),
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateColumn(String day, String date, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFFD0FD3E),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysChallengeCard(List<ProgramExercise> exercises) {
    return Card(
      color: const Color(0xFFD0FD3E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Challenge",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (exercises.isEmpty)
                    Text(
                      'No exercises planned for today.',
                      style: GoogleFonts.poppins(
                        color: Colors.black.withAlpha(178),
                        fontSize: 14,
                      ),
                    )
                  else
                    ...exercises.map((e) => Text(
                          e.exerciseTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.black.withAlpha(178),
                            fontSize: 14,
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.directions_run,
              size: 60,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}