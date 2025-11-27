// lib/database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'task_dao.dart';

part 'database.g.dart';

// Definisi tabel Tasks
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get date => dateTime()();
  IntColumn get timeSpentInSeconds =>
      integer().withDefault(const Constant(0))();
}

// Definisi database Drift
@DriftDatabase(tables: [Tasks], daos: [TaskDao])
class AppDatabase extends _$AppDatabase {
  /// Constructor utama (dipakai saat aplikasi jalan normal)
  AppDatabase() : super(_openConnection());

  /// Constructor in-memory (dipakai saat testing)
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  // Akses ke DAO
  TaskDao get taskDao => TaskDao(this);

  /// Strategy migrasi database
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        // Dipanggil saat database baru pertama kali dibuat
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Dipanggil saat schemaVersion naik
        if (from == 1) {
          // Versi 1 belum punya kolom timeSpentInSeconds
          await m.addColumn(tasks, tasks.timeSpentInSeconds);
        }
      },
    );
  }
}

// Membuka koneksi database file fisik (db.sqlite)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// Instance global untuk runtime aplikasi
final database = AppDatabase();
