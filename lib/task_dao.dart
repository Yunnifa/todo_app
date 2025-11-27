import 'package:drift/drift.dart';
import 'database.dart'; // Impor database utama kita

part 'task_dao.g.dart';

// Anotasi ini memberitahu Drift bahwa kelas ini adalah Data Access Object
// untuk tabel 'Tasks' yang ada di AppDatabase.
@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);

  // 1. Perintah untuk MELIHAT SEMUA tugas secara real-time (menggunakan Stream)
  // Ini adalah metode yang akan kita gunakan di UI dengan StreamBuilder.
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();

  // 2. Perintah untuk MENAMBAH satu tugas baru
  Future<int> insertTask(TasksCompanion entry) => into(tasks).insert(entry);

  // 3. Perintah untuk MEMPERBARUI satu tugas yang ada
  Future<bool> updateTask(Task entry) => update(tasks).replace(entry);

  // 4. Perintah untuk MENGHAPUS satu tugas berdasarkan ID-nya
  Future<int> deleteTask(int id) => (delete(tasks)..where((t) => t.id.equals(id))).go();
}