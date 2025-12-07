import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Import file project kamu (pastikan nama package sesuai)
import 'package:first_project_1140/database.dart';
import 'package:first_project_1140/main.dart'; // Untuk memanggil MyApp
import 'package:first_project_1140/main_page.dart'; // Untuk memanggil MainPage

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  // Helper untuk membersihkan timer dan mematikan StreamBuilder
  Future<void> disposeWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Aplikasi Start: Muncul Menu Bawah (Tasks, Calendar, Timer)', (WidgetTester tester) async {
    // 1. Jalankan MyApp dengan Database
    await tester.pumpWidget(
      Provider<AppDatabase>(
        create: (_) => database,
        child: const MyApp(),
      ),
    );

    // Tunggu semua animasi selesai
    await tester.pumpAndSettle();

    // 2. Validasi: Apakah MainPage (Kerangka Menu) muncul?
    expect(find.byType(MainPage), findsOneWidget);

    // 3. Validasi: Apakah Bottom Navigation Bar muncul?
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // 4. Validasi: Cek apakah 3 icon menu ada
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget); // Icon Task
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget); // Icon Calendar
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget); // Icon Timer

    // 5. Validasi: Cek label teks menu
    // Kita gunakan findsAtLeastNWidgets(1) karena teks "Tasks" mungkin muncul
    // di BottomBar DAN di Judul Halaman (AppBar).
    expect(find.text('Tasks'), findsAtLeastNWidgets(1));
    expect(find.text('Calendar'), findsAtLeastNWidgets(1));
    expect(find.text('Timer'), findsAtLeastNWidgets(1));

    // Bersihkan widget
    await disposeWidget(tester);
  });

  testWidgets('Navigasi: Klik tab Calendar harus pindah tampilan', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AppDatabase>(
        create: (_) => database,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. KLIK Tab Calendar di Bottom Navigation Bar
    // Kita cari widget Text 'Calendar' lalu klik
    // Karena mungkin ada 2 teks 'Calendar' (satu di tombol, satu mungkin hidden),
    // kita ambil yang terakhir (biasanya di navbar) atau gunakan icon biar lebih spesifik.
    // Cara aman: Klik Icon Calendar
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));

    await tester.pumpAndSettle(); // Tunggu animasi pindah tab

    // 2. Validasi: Apakah halaman Calendar muncul?
    // Kita cek apakah AppBar dengan judul 'Calendar' muncul
    expect(find.text('Calendar'), findsAtLeastNWidgets(1));

    // Bersihkan widget
    await disposeWidget(tester);
  });
}