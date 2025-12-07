import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

// Sesuaikan nama package dengan project kamu
import 'package:first_project_1140/database.dart';
import 'package:first_project_1140/task_dao.dart';

void main() {
  late AppDatabase database;
  late TaskDao taskDao;

  // Setup: Dijalankan sebelum setiap test
  setUp(() {
    // 1. Buat database in-memory (kosong & cepat)
    database = AppDatabase.inMemory();
    // 2. Inisialisasi DAO dengan database tersebut
    taskDao = TaskDao(database);
  });

  // Teardown: Bersihkan setelah selesai
  tearDown(() async {
    await database.close();
  });

  group('TaskDao Tests', () {
    test('Insert & Watch: Tambah tugas dan pastikan muncul di Stream', () async {
      // Data dummy
      final taskEntry = TasksCompanion(
        title: const Value('Belajar Unit Test'),
        date: Value(DateTime.now()),
        isDone: const Value(false),
      );

      // 1. Jalankan fungsi Insert dari DAO
      await taskDao.insertTask(taskEntry);

      // 2. Cek Stream (watchAllTasks)
      // Kita ambil data pertama yang keluar dari stream
      final List<Task> tasks = await taskDao.watchAllTasks().first;

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Belajar Unit Test');
      expect(tasks.first.isDone, false);
    });

    test('Update: Ubah status tugas dan pastikan tersimpan', () async {
      // 1. Insert data awal
      final taskEntry = TasksCompanion(
        title: const Value('Tugas Lama'),
        date: Value(DateTime.now()),
        isDone: const Value(false),
      );
      await taskDao.insertTask(taskEntry);

      // Ambil tugas yang baru disimpan (untuk mendapatkan ID-nya)
      final originalTask = (await taskDao.watchAllTasks().first).first;

      // 2. Modifikasi objek (ganti isDone jadi true)
      final updatedTask = originalTask.copyWith(isDone: true, title: 'Tugas Baru');

      // 3. Jalankan fungsi Update dari DAO
      final result = await taskDao.updateTask(updatedTask);

      // Pastikan update berhasil (return true)
      expect(result, true);

      // 4. Cek lagi di database apakah berubah
      final tasksAfterUpdate = await taskDao.watchAllTasks().first;
      expect(tasksAfterUpdate.first.isDone, true);
      expect(tasksAfterUpdate.first.title, 'Tugas Baru');
    });

    test('Delete: Hapus tugas berdasarkan ID', () async {
      // 1. Insert data
      final taskEntry = TasksCompanion(
        title: const Value('Akan Dihapus'),
        date: Value(DateTime.now()),
      );
      await taskDao.insertTask(taskEntry);

      // Ambil ID dari tugas tersebut
      final taskToDelete = (await taskDao.watchAllTasks().first).first;

      // 2. Jalankan fungsi Delete dari DAO
      await taskDao.deleteTask(taskToDelete.id);

      // 3. Cek Stream, harusnya kosong
      final tasks = await taskDao.watchAllTasks().first;
      expect(tasks.isEmpty, true);
    });
  });
}