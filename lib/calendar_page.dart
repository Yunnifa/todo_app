// lib/calendar_page.dart

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:table_calendar/table_calendar.dart';
import 'database.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _taskController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
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
                  hintText: 'Add a new task...',
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
    if (_taskController.text.isNotEmpty && _selectedDay != null) {
      // 2. Ambil DB dari Provider
      final db = Provider.of<AppDatabase>(context, listen: false);

      final entry = TasksCompanion(
        title: Value(_taskController.text),
        date: Value(_selectedDay!),
      );
      db.taskDao.insertTask(entry);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList() {
    // 3. Ambil DB dari Provider
    final db = Provider.of<AppDatabase>(context);

    return StreamBuilder<List<Task>>(
      stream: db.taskDao.watchAllTasks(), // Gunakan db lokal
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasksForSelectedDay = snapshot.data!.where((task) {
          return isSameDay(task.date, _selectedDay);
        }).toList();

        if (tasksForSelectedDay.isEmpty) {
          return const Center(
            child: Text(
              'No tasks for the day.\nClick "+" to create your tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasksForSelectedDay.length,
          itemBuilder: (context, index) {
            final task = tasksForSelectedDay[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                title: Text(task.title),
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (value) {
                    // Gunakan Provider untuk update (listen false karena dalam callback)
                    final dbLocal = Provider.of<AppDatabase>(context, listen: false);
                    final updatedTask = task.copyWith(isDone: value ?? false);
                    dbLocal.taskDao.updateTask(updatedTask);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    // Gunakan Provider untuk delete
                    final dbLocal = Provider.of<AppDatabase>(context, listen: false);
                    dbLocal.taskDao.deleteTask(task.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}