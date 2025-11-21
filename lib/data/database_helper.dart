import 'dart:async';

import 'package:my_first_app/models/program_exercise.dart';
import 'package:my_first_app/models/user_profile.dart';
import 'package:my_first_app/models/workout_log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_first_app/models/exercise.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Completer<void>? _dbInitializingCompleter;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database == null) {
      if (_dbInitializingCompleter == null) {
        _dbInitializingCompleter = Completer<void>();
        await _initDB('fitness_app.db');
        _dbInitializingCompleter!.complete();
      }
      await _dbInitializingCompleter!.future;
    }
    return _database!;
  }

  Future<void> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    _database = await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE exercises ( 
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  desc TEXT NOT NULL,
  type TEXT NOT NULL,
  bodyPart TEXT NOT NULL,
  equipment TEXT NOT NULL,
  level TEXT NOT NULL,
  rating REAL,
  ratingDesc TEXT
  )
''');
    await _createUserProgramTable(db);
    await _createProfileTable(db);
    await _createWorkoutLogTable(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUserProgramTable(db);
    }
    if (oldVersion < 3) {
      await _createProfileTable(db);
    }
    if (oldVersion < 4) {
      await _createWorkoutLogTable(db);
    }
  }

  Future<void> _createWorkoutLogTable(Database db) async {
    await db.execute('''
CREATE TABLE workout_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  exerciseId INTEGER NOT NULL,
  exerciseTitle TEXT NOT NULL,
  sets INTEGER NOT NULL,
  reps INTEGER NOT NULL,
  date TEXT NOT NULL
)
''');
  }

  Future<void> _createProfileTable(Database db) async {
    await db.execute('''
CREATE TABLE user_profile (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  weight REAL NOT NULL,
  height REAL NOT NULL,
  goal TEXT NOT NULL
)
''');
  }

  Future<void> _createUserProgramTable(Database db) async {
    await db.execute('''
CREATE TABLE user_program (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  exerciseId INTEGER NOT NULL,
  exerciseTitle TEXT NOT NULL,
  dayOfWeek TEXT NOT NULL,
  sets INTEGER NOT NULL,
  reps INTEGER NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0
)
''');
  }

  Future<void> insertExercise(Exercise exercise) async {
    final db = await instance.database;
    await db.insert('exercises', exercise.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await instance.database;
    final result = await db.query('exercises');
    return result.map((json) => Exercise.fromMap(json)).toList();
  }

  Future<UserProfile> getProfile() async {
    final db = await instance.database;
    final maps = await db.query('user_profile', limit: 1);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    } else {
      // Return a default profile if none exists
      return UserProfile(id: 1, name: 'User', weight: 0, height: 0, goal: 'Get fit');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final db = await instance.database;
    final existingProfile = await db.query('user_profile', where: 'id = ?', whereArgs: [profile.id]);

    if (existingProfile.isNotEmpty) {
      await db.update('user_profile', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
    } else {
      await db.insert('user_profile', profile.toMap());
    }
  }

  // Methods for ProgramExercise
  Future<ProgramExercise> addProgramExercise(ProgramExercise programExercise) async {
    final db = await instance.database;
    final id = await db.insert('user_program', programExercise.toMap());
    return ProgramExercise(
        id: id,
        exerciseId: programExercise.exerciseId,
        exerciseTitle: programExercise.exerciseTitle,
        dayOfWeek: programExercise.dayOfWeek,
        sets: programExercise.sets,
        reps: programExercise.reps,
        isCompleted: programExercise.isCompleted);
  }

  Future<List<ProgramExercise>> getProgramExercises() async {
    final db = await instance.database;
    final result = await db.query('user_program', orderBy: 'id ASC');
    return result.map((json) => ProgramExercise.fromMap(json)).toList();
  }

  Future<int> updateProgramExercise(ProgramExercise programExercise) async {
    final db = await instance.database;
    return await db.update(
      'user_program',
      programExercise.toMap(),
      where: 'id = ?',
      whereArgs: [programExercise.id],
    );
  }

  Future<int> deleteProgramExercise(int id) async {
    final db = await instance.database;
    return await db.delete(
      'user_program',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllExerciseCompletion() async {
    final db = await instance.database;
    await db.update('user_program', {'isCompleted': 0});
  }

  // Methods for WorkoutLog
  Future<WorkoutLog> insertWorkoutLog(WorkoutLog log) async {
    final db = await instance.database;
    final id = await db.insert('workout_log', log.toMap());
    return WorkoutLog(
      id: id,
      exerciseId: log.exerciseId,
      exerciseTitle: log.exerciseTitle,
      sets: log.sets,
      reps: log.reps,
      date: log.date,
    );
  }

  Future<List<WorkoutLog>> getWorkoutLogs({DateTime? date}) async {
    final db = await instance.database;
    if (date != null) {
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(const Duration(days: 1));
      final result = await db.query(
        'workout_log',
        where: 'date >= ? AND date < ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'date DESC',
      );
      return result.map((json) => WorkoutLog.fromMap(json)).toList();
    } else {
      final result = await db.query('workout_log', orderBy: 'date DESC');
      return result.map((json) => WorkoutLog.fromMap(json)).toList();
    }
  }
}
