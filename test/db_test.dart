import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

// Sesuaikan nama package
import 'package:first_project_1140/database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Kita gunakan inMemory agar cepat dan tidak menimpa file asli
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Schema Tests', () {
    test('Default Value: timeSpentInSeconds harus 0 saat task baru dibuat', () async {
      // 1. Kita buat data task TAPI tidak mengisi 'timeSpentInSeconds'
      // Tujuannya: Mengecek apakah database otomatis mengisinya dengan 0
      final entry = TasksCompanion.insert(
        title: 'Cek Default Value',
        date: DateTime.now(),
        // isDone defaultnya juga false di definisi tabel kamu
      );

      // 2. Insert langsung ke tabel (bypass DAO)
      await database.into(database.tasks).insert(entry);

      // 3. Ambil data
      final task = await database.select(database.tasks).getSingle();

      // 4. Validasi
      expect(task.title, 'Cek Default Value');
      expect(task.timeSpentInSeconds, 0); // Harus 0 sesuai schema
      expect(task.isDone, false); // Harus false sesuai schema
    });

    test('CRUD Langsung ke Tabel: Insert & Read', () async {
      // 1. Insert Data Lengkap
      final entry = TasksCompanion(
        title: const Value('Direct Insert'),
        date: Value(DateTime.now()),
        isDone: const Value(true),
        timeSpentInSeconds: const Value(120),
      );

      await database.into(database.tasks).insert(entry);

      // 2. Baca Data
      final tasks = await database.select(database.tasks).get();

      // 3. Validasi
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Direct Insert');
      expect(tasks.first.isDone, true);
      expect(tasks.first.timeSpentInSeconds, 120);
    });

    test('Delete Langsung di Tabel', () async {
      final entry = TasksCompanion.insert(
        title: 'Hapus Aku',
        date: DateTime.now(),
      );

      // Insert dan dapatkan ID
      final id = await database.into(database.tasks).insert(entry);

      // Delete berdasarkan ID
      await (database.delete(database.tasks)..where((t) => t.id.equals(id))).go();

      // Cek harus kosong
      final tasks = await database.select(database.tasks).get();
      expect(tasks.isEmpty, true);
    });
  });
}