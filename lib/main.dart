import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Import file-file kamu
import 'app_router.dart';
import 'app_theme.dart';
import 'database.dart'; // Pastikan import ini ada agar bisa panggil AppDatabase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi format tanggal (tetap dipertahankan)
  await initializeDateFormatting('id_ID', null);

  // 2. Jalankan aplikasi dengan menyuntikkan Database ASLI
  runApp(
    Provider<AppDatabase>(
      // Inilah "Real Database" yang akan dipakai saat aplikasi jalan normal
      create: (context) => AppDatabase(),
      // Menutup koneksi database saat aplikasi dimatikan (Best Practice)
      dispose: (context, db) => db.close(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',

      // 3. Tema kamu tetap aman di sini
      theme: AppTheme.lightTheme,

      // 4. Router kamu tetap aman di sini
      routerConfig: router,
    );
  }
}