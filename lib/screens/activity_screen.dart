import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/program_exercise.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  late Future<List<ProgramExercise>> _programForDayFuture;

  @override
  void initState() {
    super.initState();
    _fetchProgramForSelectedDate();
  }

  void _fetchProgramForSelectedDate() {
    final dbHelper = DatabaseHelper.instance;
    final dayOfWeek = DateFormat('EEEE', 'en_US').format(_selectedDate);
    _programForDayFuture = dbHelper.getProgramExercises().then(
        (exercises) => exercises.where((e) => e.dayOfWeek == dayOfWeek).toList());
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = selectedDay;
      _fetchProgramForSelectedDate();
    });
  }
  
  void _onPageChanged(int days) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: days));
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

    @override

    Widget build(BuildContext context) {

      final theme = Theme.of(context);

  

      return Scaffold(

        appBar: AppBar(

          title: Text(

            'My Activity',

            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: theme.colorScheme.onBackground),

          ),

          actions: [

            IconButton(

              onPressed: () => _onDaySelected(DateTime.now()),

              icon: Icon(Icons.today, color: theme.colorScheme.primary),

              tooltip: 'Today',

            ),

          ],

          backgroundColor: Colors.transparent,

          elevation: 0,

        ),

        body: Column(

          children: [

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              child: _buildCalendarView(),

            ),

            const SizedBox(height: 8),

            Expanded(

              child: FutureBuilder<List<ProgramExercise>>(

                future: _programForDayFuture,

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {

                    return const Center(child: CircularProgressIndicator());

                  } else if (snapshot.hasError) {

                    return Center(child: Text('Error: ${snapshot.error}'));

                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {

                    return _buildEmptyState();

                  } else {

                    return _buildTodaysProgram(snapshot.data!);

                  }

                },

              ),

            ),

          ],

        ),

      );

    }

  

    Widget _buildCalendarView() {

      final theme = Theme.of(context);

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

                  color: theme.colorScheme.onBackground,

                ),

              ),

              Row(

                children: [

                  IconButton(

                    onPressed: () => _onPageChanged(-7),

                    icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),

                  ),

                  IconButton(

                    onPressed: () => _onPageChanged(7),

                    icon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),

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

              return _buildDateColumn(

                day: day,

                isSelected: DateFormat.yMd('en_US').format(day) == DateFormat.yMd('en_US').format(_selectedDate),

                isToday: _isToday(day),

              );

            }),

          ),

        ],

      );

    }

  

    Widget _buildDateColumn({required DateTime day, bool isSelected = false, bool isToday = false}) {

      final theme = Theme.of(context);

      return GestureDetector(

        onTap: () => _onDaySelected(day),

        child: Container(

          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),

          decoration: isSelected

              ? BoxDecoration(

                  color: theme.colorScheme.primary,

                  borderRadius: BorderRadius.circular(16),

                )

              : (isToday

                  ? BoxDecoration(

                      border: Border.all(color: theme.colorScheme.primary),

                      borderRadius: BorderRadius.circular(16),

                    )

                  : null),

          child: Column(

            children: [

              Text(

                DateFormat.E('en_US').format(day).substring(0, 1),

                style: GoogleFonts.poppins(

                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,

                  fontWeight: FontWeight.w500,

                ),

              ),

              const SizedBox(height: 8),

              Text(

                day.day.toString(),

                style: GoogleFonts.poppins(

                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,

                  fontWeight: FontWeight.bold,

                  fontSize: 16,

                ),

              ),

            ],

          ),

        ),

      );

    }

  

    Widget _buildTodaysProgram(List<ProgramExercise> exercises) {

      final theme = Theme.of(context);

      return Padding(

        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              _isToday(_selectedDate) ? 'Today\'s Program' : DateFormat.yMMMEd('en_US').format(_selectedDate),

              style: GoogleFonts.poppins(

                fontSize: 20,

                fontWeight: FontWeight.w500,

                color: theme.colorScheme.onBackground,

              ),

            ),

            const SizedBox(height: 16),

            Expanded(

              child: ListView.builder(

                itemCount: exercises.length,

                itemBuilder: (context, index) {

                  final exercise = exercises[index];

                  return Card(

                    // Let the Card use its theme color

                    margin: const EdgeInsets.only(bottom: 10),

                    child: ListTile(

                      title: Text(

                        exercise.exerciseTitle,

                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),

                      ),

                      subtitle: Text(

                        '${exercise.sets} sets, ${exercise.reps} reps',

                        style: GoogleFonts.poppins(),

                      ),

                      trailing: Icon(

                        exercise.isCompleted

                            ? Icons.check_circle

                            : Icons.check_circle_outline,

                        color: exercise.isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),

                      ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      );

    }

  

    Widget _buildEmptyState() {

      final theme = Theme.of(context);

      return Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(Icons.calendar_today_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.4)),

            const SizedBox(height: 16),

            Text(

              'No workout planned for this day.',

              style: theme.textTheme.titleMedium,

            ),

            const SizedBox(height: 8),

            Text(

              'Enjoy your rest day!',

              style: theme.textTheme.bodyMedium?.copyWith(

                color: theme.colorScheme.onSurface.withOpacity(0.6),

              ),

            ),

          ],

        ),

      );

    }

  }

  