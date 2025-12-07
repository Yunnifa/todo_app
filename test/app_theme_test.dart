import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_project_1140/app_theme.dart';

void main() {
  group('AppTheme Testing', () {

    // TEST 1: Identitas Warna (Branding)
    test('Warna Primary harus sesuai spesifikasi (Biru Muda Cerah)', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, const Color(0xFF4A90E2));
      expect(theme.colorScheme.primary, const Color(0xFF4A90E2));
    });

    // TEST 2: Warna Latar Belakang (Canvas)
    test('Scaffold background harus Putih Keabuan', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF7F8FA));
    });

    // TEST 3: Komponen Kartu (Card) - Paling Detail
    test('Card Theme harus memiliki border radius 12 dan border abu-abu', () {
      final theme = AppTheme.lightTheme;
      final cardTheme = theme.cardTheme;
      expect(cardTheme.color, Colors.white);

      // 2. Mengetest Tipe Bentuk: Memastikan bentuk dasarnya adalah kotak dengan sudut tumpul
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      // Casting object agar kita bisa mengecek properti spesifik di dalamnya
      final shape = cardTheme.shape as RoundedRectangleBorder;

      // 3. Mengetest kelengkungan sudut (Radius): Harus tepat 12.0
      expect(shape.borderRadius, BorderRadius.circular(12.0));

      // 4. Mengetest Garis Pinggir (Border):
      // - Warnanya harus abu-abu terang (shade300)
      expect(shape.side.color, Colors.grey.shade300);
      // - Ketebalannya harus 1 pixel
      expect(shape.side.width, 1.0);
    });

    // TEST 4: Bentuk Checkbox
    test('Checkbox Theme harus berbentuk Lingkaran (CircleBorder)', () {
      final theme = AppTheme.lightTheme;

      // Mengetest properti geometris.
      // Default Flutter adalah RoundedRectangle (Kotak), di sini kita paksa jadi Lingkaran.
      expect(theme.checkboxTheme.shape, isA<CircleBorder>());
    });

    // TEST 5: Tombol Aksi (FAB)
    test('FloatingActionButton harus menggunakan primary color', () {
      final theme = AppTheme.lightTheme;

      // Mengetest tombol bulat melayang (biasanya di pojok kanan bawah).
      // Memastikan warnanya sinkron dengan warna brand (Biru Muda).
      expect(theme.floatingActionButtonTheme.backgroundColor, const Color(0xFF4A90E2));
    });

    // TEST 6: Header Atas (AppBar)
    test('AppBar Theme tidak memiliki elevation (datar)', () {
      final theme = AppTheme.lightTheme;

      // Mengetest efek 3D (Bayangan/Shadow).
      // Nilai 0 berarti "Flat" (Datar), tidak ada bayangan ke bawah.
      expect(theme.appBarTheme.elevation, 0);

      // Mengetest warna background header agar sama dengan warna Scaffold,
      // menciptakan efek "menyatu" (seamless).
      expect(theme.appBarTheme.backgroundColor, const Color(0xFFF7F8FA));
    });
  });
}