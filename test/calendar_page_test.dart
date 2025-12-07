import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:drift/drift.dart' as drift;
import 'package:first_project_1140/database.dart';
import 'package:first_project_1140/calendar_page.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });


  Widget createTestWidget() {
    return Provider<AppDatabase>(
      create: (_) => database,
      child: const MaterialApp(
        home: CalendarPage(),
      ),
    );
  }

  Future<void> disposeWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  // === TEST CASE 1: TAMPILAN AWAL (UI STATE) ===
  testWidgets('Halaman Calendar harus menampilkan Kalender dan Pesan Kosong', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 2. Verifikasi UI (Ekspektasi)
    // Harapan: Widget Kalender (TableCalendar) harus ada di layar
    expect(find.byType(TableCalendar), findsOneWidget);

    // Harapan: Teks placeholder "No tasks..." harus muncul karena database masih kosong
    expect(find.textContaining('No tasks for the day'), findsOneWidget);

    // Harapan: Tombol Tambah (+) harus ada
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Bersihkan widget/stream sebelum lanjut ke test berikutnya
    await disposeWidget(tester);
  });

  // === TEST CASE 2: FITUR TAMBAH (CREATE FLOW) ===
  testWidgets('Flow Tambah Task: Buka Dialog -> Ketik -> Muncul di List', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Simulasi User: Klik tombol Tambah
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Tunggu dialog muncul

    // 2. Verifikasi Dialog & Simulasi Input
    // Harapan: Textbox input muncul
    expect(find.byType(TextField), findsOneWidget);
    // Aksi: User mengetik "Meeting Tim"
    await tester.enterText(find.byType(TextField), 'Meeting Tim');

    // 3. Simulasi Submit
    // Aksi: User menekan tombol Kirim (Send)
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle(); // Tunggu dialog tutup & list refresh

    // 4. Verifikasi Hasil Akhir
    // Harapan: Data "Meeting Tim" berhasil disimpan dan TAMPIL di layar
    expect(find.text('Meeting Tim'), findsOneWidget);
    // Harapan: Pesan "No tasks" harus HILANG karena list sudah ada isinya
    expect(find.textContaining('No tasks for the day'), findsNothing);

    await disposeWidget(tester);
  });

  // === TEST CASE 3: FITUR HAPUS (DELETE FLOW) ===
  testWidgets('Flow Hapus Task: Klik tong sampah -> Hilang dari List', (WidgetTester tester) async {
    // 1. Persiapan Data (Pre-seeding)
    // Kita suntikkan data manual ke DB sebelum UI dibuka untuk ngetes hapus
    final entry = TasksCompanion.insert(
      title: 'Task Mau Dihapus',
      date: DateTime.now(),
      isDone: const drift.Value(false),
    );
    await database.into(database.tasks).insert(entry);

    // 2. Build UI
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 3. Verifikasi Awal: Pastikan task muncul dulu
    expect(find.text('Task Mau Dihapus'), findsOneWidget);

    // 4. Simulasi User: Hapus Data (Klik icon tong sampah)
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle(); // Tunggu animasi hapus

    // 5. Verifikasi Akhir: Pastikan task SUDAH HILANG
    expect(find.text('Task Mau Dihapus'), findsNothing);

    await disposeWidget(tester);
  });

  // === TEST CASE 4: FITUR UPDATE (CHECKLIST FLOW) ===
  testWidgets('Flow Checkbox: Klik checkbox -> Status berubah di UI', (WidgetTester tester) async {
    // 1. Persiapan Data (Pre-seeding)
    // Masukkan task dengan status isDone = false
    final entry = TasksCompanion.insert(
      title: 'Ceklist Saya',
      date: DateTime.now(),
      isDone: const drift.Value(false),
    );
    await database.into(database.tasks).insert(entry);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 2. Cari Checkbox target
    final checkboxFinder = find.byType(Checkbox);

    // 3. Simulasi User: Klik Checkbox
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle(); // Tunggu UI update

    // 4. Verifikasi Logic
    // Ambil widget checkbox yang ada di layar sekarang
    final Checkbox checkboxUpdated = tester.widget(find.byType(Checkbox));
    // Harapan: Nilainya berubah menjadi TRUE (tercentang)
    expect(checkboxUpdated.value, true);

    await disposeWidget(tester);
  });
}