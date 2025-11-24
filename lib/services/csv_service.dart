import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/data/database_helper.dart';
import 'package:my_first_app/models/exercise.dart';

class CsvService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> loadExercisesFromCsv() async {
    // Check if data already exists to avoid re-inserting on every app start
    final existingExercises = await _dbHelper.getAllExercises();
    if (existingExercises.isNotEmpty) {
      return;
    }

    final rawData = await rootBundle.loadString("megaGymDataset.csv");
    List<List<dynamic>> listData = const CsvToListConverter(eol: '\n').convert(rawData);
    
    // Skip header row
    for (var i = 1; i < listData.length; i++) {
      final row = listData[i];
      try {
        final exercise = Exercise.fromList(row);
        await _dbHelper.insertExercise(exercise);
      } catch (e) {
        // Optional: handle or log parsing errors for specific rows
        debugPrint('Error parsing row $i: $row. Error: $e');
      }
    }
  }
}
