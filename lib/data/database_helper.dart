import 'dart:async';

import 'package:my_first_app/models/program_exercise.dart';
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
      version: 2,
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
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUserProgramTable(db);
    }
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
}
