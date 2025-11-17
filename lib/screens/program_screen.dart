import 'package:flutter/material.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/program_exercise.dart';
import 'package:collection/collection.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  late Future<Map<String, List<ProgramExercise>>> _program;
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _program = _loadProgram();
  }

  Future<Map<String, List<ProgramExercise>>> _loadProgram() async {
    final exercises = await DatabaseHelper.instance.getProgramExercises();
    final grouped = groupBy(exercises, (ProgramExercise e) => e.dayOfWeek);

    // Ensure all days are present in the map
    for (var day in _daysOfWeek) {
      grouped.putIfAbsent(day, () => []);
    }
    
    // Sort the map by the order of days in _daysOfWeek
    final sortedGrouped = Map.fromEntries(
      _daysOfWeek.map((day) => MapEntry(day, grouped[day]!))
    );

    return sortedGrouped;
  }

  void _refreshProgram() {
    setState(() {
      _program = _loadProgram();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Weekly Program'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProgram,
          )
        ],
      ),
      body: FutureBuilder<Map<String, List<ProgramExercise>>>(
        future: _program,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.values.every((list) => list.isEmpty)) {
            return const Center(child: Text('Your program is empty. Add exercises to get started!'));
          }

          final programByDay = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _daysOfWeek.map((day) {
                return _buildDayColumn(context, day, programByDay[day]!);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, String day, List<ProgramExercise> exercises) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              day,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: exercises.isEmpty
                ? const Center(child: Text('Rest Day'))
                : ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final progExercise = exercises[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(progExercise.exerciseTitle),
                          subtitle: Text('Sets: ${progExercise.sets}, Reps: ${progExercise.reps}'),
                          leading: Checkbox(
                            value: progExercise.isCompleted,
                            onChanged: (bool? value) async {
                              if (value != null) {
                                setState(() {
                                  progExercise.isCompleted = value;
                                });
                                await DatabaseHelper.instance.updateProgramExercise(progExercise);
                              }
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                            onPressed: () async {
                              await DatabaseHelper.instance.deleteProgramExercise(progExercise.id!);
                              _refreshProgram();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${progExercise.exerciseTitle} removed from program.')),
                              );
                            },
                            tooltip: 'Delete',
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
}
