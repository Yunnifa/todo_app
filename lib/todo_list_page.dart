// lib/todo_list_page.dart

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 1. WAJIB: Import Provider
import 'package:table_calendar/table_calendar.dart';
import 'database.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    _taskController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What you wanna do??',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
                onSubmitted: (_) => _addTask(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                    onPressed: _addTask,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      // 2. Ambil database dari Provider (listen: false karena ini fungsi aksi)
      final db = Provider.of<AppDatabase>(context, listen: false);

      final entry = TasksCompanion(
        title: Value(_taskController.text),
        date: Value(DateTime.now()),
      );

      db.taskDao.insertTask(entry); // Gunakan 'db', bukan 'database'
      Navigator.pop(context);
    }
  }

  void _updateTask(Task task, bool isDone) {
    // 3. Ambil database dari Provider
    final db = Provider.of<AppDatabase>(context, listen: false);
    final updatedTask = task.copyWith(isDone: isDone);
    db.taskDao.updateTask(updatedTask);
  }

  void _deleteTask(int id) {
    // 4. Ambil database dari Provider
    final db = Provider.of<AppDatabase>(context, listen: false);
    db.taskDao.deleteTask(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildCategoryChips(),
          ),
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    // 5. Ambil database dari Provider (listen: true atau default)
    // Ini agar widget rebuild saat database berubah
    final db = Provider.of<AppDatabase>(context);

    return StreamBuilder<List<Task>>(
      stream: db.taskDao.watchAllTasks(), // Gunakan 'db' lokal
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTasks = snapshot.data ?? [];
        if (allTasks.isEmpty) {
          return const Center(child: Text('Tidak ada tugas.'));
        }

        final groupedTasks = groupBy(allTasks, (Task task) {
          return DateTime(task.date.year, task.date.month, task.date.day);
        });

        final sortedDates = groupedTasks.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final tasksForDate = groupedTasks[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(date),
                ...tasksForDate.map((task) => _buildTodoItem(task)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    String title;
    if (isSameDay(date, today)) {
      title = 'Today';
    } else if (isSameDay(date, tomorrow)) {
      title = 'Tomorrow';
    } else {
      title = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _buildTodoItem(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (bool? value) {
            if (value != null) {
              _updateTask(task, value);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
            color: task.isDone ? Theme.of(context).textTheme.titleMedium?.color : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () {
            _deleteTask(task.id);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip("All", isSelected: true),
          _buildChip("Work"),
          _buildChip("Personal"),
          _buildChip("Wishlist"),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}