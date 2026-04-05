import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores personalizados
  static const Color robokids = Color.fromARGB(255, 16, 171, 238);

  // TEMA CLARO
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    // Color primario
    primaryColorLight: robokids,
    // Color de fondo de las pantallas
    scaffoldBackgroundColor: Colors.white,
    // Estilo del AppBar
    appBarTheme: AppBarTheme(
      foregroundColor: robokids,
      backgroundColor: Colors.white,
    ),
    // Estilo de los ElevatedButtons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: robokids,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    // Estilo de los OutlinedButtons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
    ),
    // Estilo de los TextButtons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.lightBlue),
    ),
    // Estilo de los textos
    textTheme: TextTheme().copyWith(
      titleLarge: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      titleMedium: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: Colors.black,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: Colors.black,
        fontSize: 12,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: robokids,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: robokids,
    ),
  );

  // TEMA OSCURO
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Color primario
    primaryColorDark: Colors.white,
    // Color de fondo de las pantallas
    scaffoldBackgroundColor: Colors.grey.shade900,
    // Estilo del AppBar
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey.shade900,
    ),
    // Estilo de los ElevatedButtons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    ),
    // Estilo de los OutlinedButtons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
    ),
    // Estilo de los TextButtons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.blue),
    ),
    // Estilo de los textos
    textTheme: TextTheme().copyWith(
      titleLarge: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      titleMedium: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: Colors.white,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: Colors.white,
        fontSize: 12,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
     progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Colors.white,
    ),
  );
}
