// lib/todo_list_page.dart

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  // Helper: Format Jam (AM/PM)
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  // Helper: Gabungkan Tanggal + Jam
  DateTime? _combineDateAndTime(DateTime date, TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showAddTaskDialog() {
    _taskController.clear();
    TimeOfDay? tempStartTime;
    TimeOfDay? tempEndTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _taskController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'What you wanna do??',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
                    onSubmitted: (_) => _addTask(tempStartTime, tempEndTime),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      // Tombol Start Time
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setModalState(() {
                              tempStartTime = time;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Text(
                            tempStartTime != null
                                ? _formatTimeOfDay(tempStartTime!)
                                : "Start Time",
                            style: TextStyle(
                                color: tempStartTime != null ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("-"),
                      ),
                      // Tombol End Time
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: tempStartTime ?? TimeOfDay.now(),
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setModalState(() {
                              tempEndTime = time;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Text(
                            tempEndTime != null
                                ? _formatTimeOfDay(tempEndTime!)
                                : "End Time",
                            style: TextStyle(
                                color: tempEndTime != null ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                        onPressed: () => _addTask(tempStartTime, tempEndTime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addTask(TimeOfDay? start, TimeOfDay? end) {
    if (_taskController.text.isNotEmpty) {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final now = DateTime.now();

      final startDateTime = _combineDateAndTime(now, start);
      var endDateTime = _combineDateAndTime(now, end);

      // Fix Lintas Hari
      if (startDateTime != null && endDateTime != null) {
        if (endDateTime.isBefore(startDateTime)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
        }
      }

      final entry = TasksCompanion(
        title: Value(_taskController.text),
        date: Value(now),
        startTime: Value(startDateTime),
        endTime: Value(endDateTime),
      );

      db.taskDao.insertTask(entry);
      Navigator.pop(context);
    }
  }

  void _updateTask(Task task, bool isDone) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final updatedTask = task.copyWith(isDone: isDone);
    db.taskDao.updateTask(updatedTask);
  }

  void _deleteTask(int id) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    db.taskDao.deleteTask(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildCategoryChips(),
          ),
          Expanded(child: _buildTodoList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    final db = Provider.of<AppDatabase>(context);
    return StreamBuilder<List<Task>>(
      stream: db.taskDao.watchAllTasks(),
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
      child: Text(title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
    );
  }

  Widget _buildTodoItem(Task task) {
    String? timeRangeText;
    bool isOverdue = false; // Status Telat

    if (task.startTime != null) {
      final start = DateFormat.jm().format(task.startTime!);
      final end = task.endTime != null ? " - ${DateFormat.jm().format(task.endTime!)}" : "";
      timeRangeText = "$start$end";

      // LOGIKA WARNA MERAH: Jika waktu lewat & belum selesai
      if (task.endTime != null && !task.isDone) {
        if (DateTime.now().isAfter(task.endTime!)) {
          isOverdue = true;
        }
      }
    }

    // Tentukan warna
    final textColor = isOverdue ? Colors.red : Colors.blue.shade400;
    final iconColor = isOverdue ? Colors.red : Colors.blue.shade300;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      // Tambah border merah jika telat
      shape: isOverdue
          ? RoundedRectangleBorder(
          side: const BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(12.0))
          : null,
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (bool? value) {
            if (value != null) _updateTask(task, value);
          },
        ),
        title: Text(task.title,
            style: TextStyle(
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isDone
                    ? Theme.of(context).textTheme.titleMedium?.color
                    : Theme.of(context).textTheme.bodyMedium?.color)),
        subtitle: timeRangeText != null
            ? Row(children: [
          Icon(Icons.access_time, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(timeRangeText,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.w500))
        ])
            : null,
        trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () => _deleteTask(task.id)),
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
          _buildChip("Wishlist")
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
            fontWeight: FontWeight.bold),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}