import 'dart:async';

import 'package:my_first_app/models/workout_log.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/program_exercise.dart';
import 'package:collection/collection.dart';
import 'package:my_first_app/screens/exercise_list_screen.dart';

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

  Future<void> _showEditExerciseDialog(ProgramExercise exercise) async {
    final formKey = GlobalKey<FormState>();
    final setsController = TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit "${exercise.exerciseTitle}"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: setsController,
                  decoration: const InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  exercise.sets = int.parse(setsController.text);
                  exercise.reps = int.parse(repsController.text);
                  await DatabaseHelper.instance.updateProgramExercise(exercise);
                  Navigator.of(context).pop();
                  _refreshProgram();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClearWeekDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Week'),
          content: const Text('Are you sure you want to uncheck all exercises for the week?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () async {
                await DatabaseHelper.instance.clearAllExerciseCompletion();
                Navigator.of(context).pop();
                _refreshProgram();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Weekly Program'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Week',
            onPressed: _showClearWeekDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProgram,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('AI feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Create with AI'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExerciseListScreen()),
                      );
                    },
                    icon: const Icon(Icons.search_outlined),
                    label: const Text('Browse All'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<ProgramExercise>>>(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, String day, List<ProgramExercise> exercises) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
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
                                progExercise.isCompleted = value;
                                await DatabaseHelper.instance.updateProgramExercise(progExercise);

                                if (value) {
                                  final log = WorkoutLog(
                                    exerciseId: progExercise.exerciseId,
                                    exerciseTitle: progExercise.exerciseTitle,
                                    sets: progExercise.sets,
                                    reps: progExercise.reps,
                                    date: DateTime.now(),
                                  );
                                  await DatabaseHelper.instance.insertWorkoutLog(log);
                                }
                                
                                _refreshProgram();
                              }
                            },
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                unawaited(_showEditExerciseDialog(progExercise));
                              } else if (value == 'delete') {
                                await DatabaseHelper.instance.deleteProgramExercise(progExercise.id!);
                                _refreshProgram();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${progExercise.exerciseTitle} removed from program.')),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
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
