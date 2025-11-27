// lib/main_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatelessWidget {
  // Terima 'navigationShell' dari GoRouter
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body sekarang hanya menampilkan halaman aktif dari navigationShell
      body: navigationShell,

      // BottomNavigationBar sekarang mengontrol navigasi antar branch
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            // --- SESUAI PERMINTAAN ANDA ---
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
        ],
        // Dapatkan index tab yang aktif dari navigationShell
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Gunakan goBranch untuk pindah tab tanpa membuat halaman baru
          navigationShell.goBranch(
            index,
            // 'initialLocation: true' berarti jika kita kembali ke tab,
            // kita akan melihat halaman awal dari tab tersebut, bukan halaman terakhir yg dibuka.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        // Styling tambahan sesuai referensi
        type: BottomNavigationBarType.fixed, // Agar label selalu terlihat jika aktif
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}