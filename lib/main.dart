import 'package:my_first_app/screens/main_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_app/services/csv_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  // Ensure that the Flutter binding is initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for sqflite on desktop platforms.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    // Load the exercise data from CSV into the database.
    // This will only run on the first launch.
    await CsvService().loadExercisesFromCsv();
    debugPrint("CSV data loaded successfully.");
  } catch (e) {
    debugPrint("Error loading CSV data: $e");
    // Optionally, show an error dialog to the user
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Fitness Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        primaryColor: const Color(0xFFD0FD3E),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0FD3E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark, // Enforce dark theme
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}