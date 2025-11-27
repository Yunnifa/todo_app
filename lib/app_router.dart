// lib/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_page.dart';
import 'todo_list_page.dart';
import 'calendar_page.dart';
import 'timer_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/tasks', // Tentukan halaman awal aplikasi
    routes: [
      // ShellRoute ini adalah "bingkai" utama aplikasi kita
      StatefulShellRoute.indexedStack(

        // Bagian builder ini akan membuat MainPage
        // dan MEMBERIKAN 'navigationShell' yang dibutuhkan
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },

        // Ini adalah cabang-cabang navigasi untuk setiap tab
        branches: [
          // Branch 0: Tab Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                name: 'tasks',
                builder: (context, state) => const TodoListPage(),
              ),
            ],
          ),

          // Branch 1: Tab Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),

          // Branch 2: Tab Timer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timer',
                name: 'timer',
                builder: (context, state) => const TimerPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    // errorBuilder tetap sama
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Text('Halaman tidak ditemukan'),
      ),
    ),
  );
}