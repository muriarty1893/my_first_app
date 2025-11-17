import 'package:flutter/material.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/exercise.dart';
import 'package:my_first_app/models/program_exercise.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = true;

  // Filter options
  Set<String> _bodyParts = {'All'};
  Set<String> _types = {'All'};
  Set<String> _equipments = {'All'};
  Set<String> _levels = {'All'};

  // Selected filters
  String _selectedBodyPart = 'All';
  String _selectedType = 'All';
  String _selectedEquipment = 'All';
  String _selectedLevel = 'All';

  @override
  void initState() {
    super.initState();
    _loadExercisesAndFilters();
  }

  Future<void> _loadExercisesAndFilters() async {
    setState(() {
      _isLoading = true;
    });

    final exercises = await DatabaseHelper.instance.getAllExercises();

    if (mounted) {
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;

        // Populate filter sets
        _bodyParts.addAll(exercises.map((e) => e.bodyPart));
        _types.addAll(exercises.map((e) => e.type));
        _equipments.addAll(exercises.map((e) => e.equipment));
        _levels.addAll(exercises.map((e) => e.level));

        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Exercise> filtered = _allExercises;

    if (_selectedBodyPart != 'All') {
      filtered = filtered.where((e) => e.bodyPart == _selectedBodyPart).toList();
    }
    if (_selectedType != 'All') {
      filtered = filtered.where((e) => e.type == _selectedType).toList();
    }
    if (_selectedEquipment != 'All') {
      filtered = filtered.where((e) => e.equipment == _selectedEquipment).toList();
    }
    if (_selectedLevel != 'All') {
      filtered = filtered.where((e) => e.level == _selectedLevel).toList();
    }

    setState(() {
      _filteredExercises = filtered;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedBodyPart = 'All';
      _selectedType = 'All';
      _selectedEquipment = 'All';
      _selectedLevel = 'All';
      _filteredExercises = _allExercises;
    });
  }

  Future<void> _showAddExerciseDialog(Exercise exercise) async {
    final formKey = GlobalKey<FormState>();
    String selectedDay = 'Monday';
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add "${exercise.title}" to program'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: const InputDecoration(labelText: 'Day of the Week'),
                    items: daysOfWeek.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        selectedDay = newValue;
                      }
                    },
                  ),
                  TextFormField(
                    controller: setsController,
                    decoration: const InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of sets';
                      }
                      if (int.tryParse(value) == null) {
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of reps';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final programExercise = ProgramExercise(
                    exerciseId: exercise.id,
                    exerciseTitle: exercise.title,
                    dayOfWeek: selectedDay,
                    sets: int.parse(setsController.text),
                    reps: int.parse(repsController.text),
                  );
                  await DatabaseHelper.instance.addProgramExercise(programExercise);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${exercise.title} added to $selectedDay')),
                  );
                }
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
        title: const Text('All Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercisesAndFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? const Center(child: Text('No exercises match the selected filters.'))
                      : ListView.builder(
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return ListTile(
                              title: Text(exercise.title),
                              subtitle: Text('${exercise.bodyPart} | ${exercise.equipment} | ${exercise.level}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: 'Add to program',
                                onPressed: () => _showAddExerciseDialog(exercise),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(exercise.title),
                                    content: SingleChildScrollView(
                                      child: Text(exercise.desc),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection('Body Part', _bodyParts, _selectedBodyPart, (value) {
            setState(() {
              _selectedBodyPart = value;
              _applyFilters();
            });
          }),
          _buildFilterSection('Type', _types, _selectedType, (value) {
            setState(() {
              _selectedType = value;
              _applyFilters();
            });
          }),
          _buildFilterSection('Equipment', _equipments, _selectedEquipment, (value) {
            setState(() {
              _selectedEquipment = value;
              _applyFilters();
            });
          }),
          _buildFilterSection('Level', _levels, _selectedLevel, (value) {
            setState(() {
              _selectedLevel = value;
              _applyFilters();
            });
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: _resetFilters,
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Set<String> options, String selectedValue, ValueChanged<String> onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 8.0,
            children: options.map((option) {
              return FilterChip(
                label: Text(option),
                selected: selectedValue == option,
                onSelected: (selected) {
                  onSelected(option);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
