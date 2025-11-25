import 'package:my_first_app/screens/main_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_first_app/services/csv_service.dart';
import 'package:my_first_app/theme/app_theme.dart';
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, // Keep dark theme available
      themeMode: ThemeMode.light, // Enforce light theme for now
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}