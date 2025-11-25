import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD0FD3E),
      secondary: Color(0xFFD0FD3E),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.grey.withAlpha(51),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD0FD3E),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFD0FD3E),
      foregroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: const Color(0xFFD0FD3E),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.withAlpha(51),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.withAlpha(51),
      selectedColor: const Color(0xFFD0FD3E),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      secondaryLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF000000), // Black
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white, // White text on black app bar
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: Colors.white), // White icons on black app bar
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF0000), // Bright red
      secondary: Color(0xFF950101), // Darker red secondary accent
      onPrimary: Colors.white, // White text on bright red primary
      onSecondary: Colors.white, // White text on dark red secondary
      background: Color(0xFF000000), // Black background
      surface: Color(0xFF3D0000), // Very dark red for cards/surfaces
      onBackground: Colors.white, // White text on black background
      onSurface: Colors.white, // White text on very dark red surface
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: Colors.white, // General body text white
      displayColor: Colors.white, // General display text white
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF3D0000), // Very dark red cards
      elevation: 4,
      shadowColor: const Color(0xFFFF0000).withOpacity(0.3), // Red shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF0000), // Bright red button
        foregroundColor: Colors.white, // White text on bright red button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF0000), // Bright red FAB
      foregroundColor: Colors.white, // White icon on bright red FAB
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF000000), // Black bottom nav bar
      selectedItemColor: const Color(0xFFFF0000), // Bright red selected item
      unselectedItemColor: Colors.white.withOpacity(0.6), // Faded white unselected item
      showUnselectedLabels: true,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3D0000), // Very dark red input field background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // Faded white hint text
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF3D0000), // Very dark red chip background
      selectedColor: const Color(0xFFFF0000), // Bright red selected chip
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White label text
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White secondary label text
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.transparent),
      ),
    ),
  );
}
