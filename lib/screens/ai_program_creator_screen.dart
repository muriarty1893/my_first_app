import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/program_exercise.dart';
import '../services/ai_service.dart';

// A simple class to hold the structured program exercise data
class AiGeneratedExercise {
  final String dayOfWeek;
  final String exerciseTitle;
  final int sets;
  final int reps;

  AiGeneratedExercise({
    required this.dayOfWeek,
    required this.exerciseTitle,
    required this.sets,
    required this.reps,
  });

  factory AiGeneratedExercise.fromJson(Map<String, dynamic> json) {
    return AiGeneratedExercise(
      dayOfWeek: json['dayOfWeek'] ?? 'Unknown Day',
      exerciseTitle: json['exerciseTitle'] ?? 'Unknown Exercise',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
    );
  }
}

class AiProgramCreatorScreen extends StatefulWidget {
  const AiProgramCreatorScreen({super.key});

  @override
  State<AiProgramCreatorScreen> createState() => _AiProgramCreatorScreenState();
}

class _AiProgramCreatorScreenState extends State<AiProgramCreatorScreen> {
  final _textController = TextEditingController();
  final AiService _aiService = AiService();

  List<AiGeneratedExercise> _generatedProgram = [];
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _generateProgram() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _generatedProgram = [];
      _errorMessage = '';
    });

    try {
      final rawJsonResponse = await _aiService.generateProgram(_textController.text);
      
      // Parse the JSON response
      final decoded = jsonDecode(rawJsonResponse);
      
      if (decoded['program'] != null && decoded['program'] is List) {
        final List<dynamic> programList = decoded['program'];
        final program = programList
            .map((item) => AiGeneratedExercise.fromJson(item))
            .toList();
        
        setState(() {
          _generatedProgram = program;
        });
      } else {
        throw Exception("AI response was not in the expected format (missing 'program' list).");
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProgram() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Create a lookup map of all available exercises for efficient access.
      final allExercises = await DatabaseHelper.instance.getAllExercises();
      final exerciseMap = {for (var e in allExercises) e.title.toLowerCase(): e};

      // Clear the old program from the database.
      await DatabaseHelper.instance.clearUserProgram();

      // Iterate through the AI-generated program and save each exercise.
      for (final aiExercise in _generatedProgram) {
        // Find the corresponding full exercise details from our database.
        final correspondingExercise = exerciseMap[aiExercise.exerciseTitle.toLowerCase()];

        if (correspondingExercise != null) {
          final newProgramExercise = ProgramExercise(
            exerciseId: correspondingExercise.id,
            exerciseTitle: correspondingExercise.title, // Use title from DB for consistency
            dayOfWeek: aiExercise.dayOfWeek,
            sets: aiExercise.sets,
            reps: aiExercise.reps,
          );
          await DatabaseHelper.instance.addProgramExercise(newProgramExercise);
        } else {
          // It's possible the AI hallucinates an exercise title that's not in our list.
          // We'll just skip it for now, but this could be logged.
          debugPrint("AI generated an exercise not found in the database: ${aiExercise.exerciseTitle}");
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New program saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to save program: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group exercises by day for display
    final groupedProgram = groupBy(_generatedProgram, (AiGeneratedExercise e) => e.dayOfWeek);
    final sortedDays = groupedProgram.keys.sorted((a, b) {
      const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Program Creator'),
        actions: [
          if (_generatedProgram.isNotEmpty && !_isLoading)
            IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              tooltip: 'Save Program',
              onPressed: _saveProgram,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Describe your desired workout program:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., "A 3-day full-body workout for a beginner with access to dumbbells."',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateProgram,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Generate Program'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
            else if (_generatedProgram.isNotEmpty)
              Expanded(child: _buildProgramPreview(groupedProgram, sortedDays))
            else
              const Expanded(
                child: Center(
                  child: Text('Your generated program will appear here.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramPreview(Map<String, List<AiGeneratedExercise>> groupedProgram, List<String> sortedDays) {
    return ListView(
      children: sortedDays.map((day) {
        final exercises = groupedProgram[day]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            initiallyExpanded: true,
            children: exercises.map((exercise) {
              return ListTile(
                title: Text(exercise.exerciseTitle),
                subtitle: Text('${exercise.sets} sets of ${exercise.reps} reps'),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
