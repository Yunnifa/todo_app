import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// Sesuaikan import dengan lokasi file timer_page.dart kamu
import 'package:first_project_1140/timer_page.dart';

void main() {
  // Helper untuk membersihkan Timer agar tidak ada error 'Pending Timer'
  // JURUS PEMBERSIH WAJIB UNTUK TIMER
  Future<void> disposeWidget(WidgetTester tester) async {
    // Ganti UI dengan kotak kosong -> memicu dispose() di TimerPage -> timer.cancel()
    await tester.pumpWidget(const SizedBox());
    // Beri waktu sedikit agar proses cancel selesai
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Helper untuk membuat widget yang siap di-test
  Widget createTestWidget() {
    return const MaterialApp(
      home: TimerPage(),
    );
  }

  testWidgets('Tampilan Awal: Picker Muncul, Tombol Start Muncul', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Pastikan Picker Muncul (Ada 3 CupertinoPicker: Jam, Menit, Detik)
    expect(find.byType(CupertinoPicker), findsNWidgets(3));

    // 2. Pastikan Label Headers Muncul
    expect(find.text('Hours'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
    expect(find.text('Seconds'), findsOneWidget);

    // 3. Pastikan Tombol Preset Muncul
    expect(find.text('00:10:00'), findsOneWidget);

    // 4. Pastikan Tombol Start Muncul
    expect(find.text('Start'), findsOneWidget);

    await disposeWidget(tester);
  });

  testWidgets('Flow Preset: Klik Preset -> Picker Berubah -> Klik Start -> Masuk Countdown', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Klik Preset '00:10:00'
    await tester.tap(find.text('00:10:00'));

    // Tunggu animasi scroll picker selesai (di kode timer_page durasinya 400ms)
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 2. Klik Start
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle(); // Tunggu animasi AnimatedSwitcher

    // 3. Pastikan UI berubah ke Countdown
    // Harusnya muncul teks "00:10:00" yang besar
    expect(find.text('00:10:00'), findsOneWidget);

    // Tombol harus berubah jadi Pause dan Cancel
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await disposeWidget(tester);
  });

  testWidgets('Flow Timer Berjalan: Waktu berkurang setiap detik', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Set waktu lewat preset
    await tester.tap(find.text('00:10:00'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 2. Start
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Cek waktu awal
    expect(find.text('00:10:00'), findsOneWidget);

    // 3. SIMULASI WAKTU BERJALAN 1 DETIK
    // Kita "pump" dengan durasi 1 detik. Ini akan memicu callback timer.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(); // Rebuild UI

    // 4. Validasi waktu berkurang jadi 00:09:59
    expect(find.text('00:09:59'), findsOneWidget);

    // Maju lagi 2 detik
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Validasi waktu jadi 00:09:57
    expect(find.text('00:09:57'), findsOneWidget);

    await disposeWidget(tester);
  });

  testWidgets('Flow Pause & Resume', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Start 10 menit
    await tester.tap(find.text('00:10:00'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Maju 1 detik
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('00:09:59'), findsOneWidget);

    // 1. Klik PAUSE
    await tester.tap(find.text('Pause'));
    await tester.pump(); // Rebuild UI

    // Tombol harus jadi Resume
    expect(find.text('Resume'), findsOneWidget);

    // 2. Pastikan Waktu BERHENTI saat dipause
    // Kita majukan waktu test 5 detik
    await tester.pump(const Duration(seconds: 5));
    // Teks harus TETAP 00:09:59
    expect(find.text('00:09:59'), findsOneWidget);

    // 3. Klik RESUME
    await tester.tap(find.text('Resume'));
    await tester.pump();

    // Maju 1 detik lagi
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // Waktu lanjut berkurang (00:09:58)
    expect(find.text('00:09:58'), findsOneWidget);

    await disposeWidget(tester);
  });

  testWidgets('Flow Cancel: Reset ke tampilan awal', (WidgetTester tester) async {
    // INI YANG TADI CRASH, SEKARANG HARUSNYA AMAN
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Start
    await tester.tap(find.text('00:10:00'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Pastikan masuk mode running
    expect(find.text('Cancel'), findsOneWidget);

    // 1. Klik CANCEL
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle(); // Tunggu animasi AnimatedSwitcher balik ke picker

    // 2. Validasi balik ke Picker
    expect(find.byType(CupertinoPicker), findsNWidgets(3));
    expect(find.text('Start'), findsOneWidget);

    await disposeWidget(tester);
  });
}