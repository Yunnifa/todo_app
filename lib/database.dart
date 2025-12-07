// lib/database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'task_dao.dart';

part 'database.g.dart';

// 1. Update Definisi tabel Tasks
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get date => dateTime()();
  IntColumn get timeSpentInSeconds =>
      integer().withDefault(const Constant(0))();

  // KOLOM BARU: Untuk range waktu (Start & End)
  // Kita buat nullable() karena mungkin ada tugas yang tidak butuh jam spesifik
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
}

// Definisi database Drift
@DriftDatabase(tables: [Tasks], daos: [TaskDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  // 2. NAIKKAN VERSI SCHEMA DARI 2 KE 3
  @override
  int get schemaVersion => 3;

  @override
  TaskDao get taskDao => TaskDao(this);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Migrasi dari versi 1 ke 2 (Time Spent)
        if (from < 2) {
          await m.addColumn(tasks, tasks.timeSpentInSeconds);
        }

        // 3. LOGIKA MIGRASI BARU (Versi 2 ke 3)
        // Menambahkan kolom startTime dan endTime
        if (from < 3) {
          await m.addColumn(tasks, tasks.startTime);
          await m.addColumn(tasks, tasks.endTime);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

final database = AppDatabase();