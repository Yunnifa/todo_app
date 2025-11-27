import 'package:flutter/material.dart';

class AppTheme {
  // Definisikan warna utama agar mudah diganti nanti
  static const Color primaryColor = Color(0xFF4A90E2); // Biru muda cerah
  static const Color lightBackgroundColor = Color(0xFFF7F8FA); // Putih keabuan
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF888888);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Skema Warna Utama
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        background: lightBackgroundColor,
        onBackground: textColor,
      ),

      // Warna Latar Belakang Scaffold
      scaffoldBackgroundColor: lightBackgroundColor,

      // Tema AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0, // Tanpa bayangan
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto', // Ganti dengan font pilihan Anda
        ),
      ),

      // Tema Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Tema Teks
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
            fontWeight: FontWeight.bold, color: textColor, fontSize: 24),
        titleMedium: TextStyle(color: secondaryTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: textColor, fontSize: 14),
      ),

      // Tema Kartu (Card) & Container
      cardTheme: CardThemeData( // <-- PERBAIKAN: Gunakan CardThemeData
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Tema Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor; // Warna saat dicentang
          }
          return Colors.grey.shade300; // Warna saat tidak dicentang
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: const CircleBorder(), // Mengubah checkbox menjadi lingkaran
      ),

      // Tema Tombol
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}