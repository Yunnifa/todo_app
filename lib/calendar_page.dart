// lib/calendar_page.dart

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  DateTime? _combineDateAndTime(DateTime date, TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                  children: [
                    TextField(
                      controller: _taskController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Add a new task for TODAY...',
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
                        // Start Time
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
                                border: Border.all(color: Colors.grey.shade300)
                            ),
                            child: Text(
                              tempStartTime != null
                                  ? _formatTimeOfDay(tempStartTime!)
                                  : "Start Time",
                              style: TextStyle(
                                  color: tempStartTime != null ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("-"),
                        ),
                        // End Time
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
                                border: Border.all(color: Colors.grey.shade300)
                            ),
                            child: Text(
                              tempEndTime != null
                                  ? _formatTimeOfDay(tempEndTime!)
                                  : "End Time",
                              style: TextStyle(
                                  color: tempEndTime != null ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold
                              ),
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
                  ],
                ),
              );
            }
        );
      },
    );
  }

  void _addTask(TimeOfDay? start, TimeOfDay? end) {
    if (_taskController.text.isNotEmpty) {
      final db = Provider.of<AppDatabase>(context, listen: false);

      // KEMBALI KE LOGIKA AWAL: Selalu simpan untuk HARI INI
      final targetDate = DateTime.now();

      final startDateTime = _combineDateAndTime(targetDate, start);
      var endDateTime = _combineDateAndTime(targetDate, end);

      if (startDateTime != null && endDateTime != null) {
        if (endDateTime.isBefore(startDateTime)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
        }
      }

      final entry = TasksCompanion(
        title: Value(_taskController.text),
        date: Value(targetDate),
        startTime: Value(startDateTime),
        endTime: Value(endDateTime),
      );

      db.taskDao.insertTask(entry);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'), centerTitle: true),
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
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList() {
    final db = Provider.of<AppDatabase>(context);

    return StreamBuilder<List<Task>>(
      stream: db.taskDao.watchAllTasks(),
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
              'No tasks for this day.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: tasksForSelectedDay.length,
          itemBuilder: (context, index) {
            final task = tasksForSelectedDay[index];

            String? timeRangeText;
            bool isOverdue = false; // Status Telat

            if (task.startTime != null) {
              final start = DateFormat.jm().format(task.startTime!);
              final end = task.endTime != null ? " - ${DateFormat.jm().format(task.endTime!)}" : "";
              timeRangeText = "$start$end";

              // LOGIKA MERAH DI KALENDER JUGA
              if (task.endTime != null && !task.isDone) {
                if (DateTime.now().isAfter(task.endTime!)) {
                  isOverdue = true;
                }
              }
            }

            final textColor = isOverdue ? Colors.red : Colors.blue.shade400;
            final iconColor = isOverdue ? Colors.red : Colors.blue.shade300;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: isOverdue
                  ? RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.red, width: 1.0),
                  borderRadius: BorderRadius.circular(12.0))
                  : null,
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : null,
                  ),
                ),
                subtitle: timeRangeText != null
                    ? Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      timeRangeText,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
                    : null,
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (value) {
                    final dbLocal = Provider.of<AppDatabase>(context, listen: false);
                    final updatedTask = task.copyWith(isDone: value ?? false);
                    dbLocal.taskDao.updateTask(updatedTask);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () {
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