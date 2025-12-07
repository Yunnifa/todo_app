// lib/timer_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'database.dart';

enum TimerStatus { stopped, running, paused }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  Duration _totalDuration = Duration.zero;
  Duration _currentDuration = Duration.zero;
  TimerStatus _status = TimerStatus.stopped;

  Task? _selectedTask;

  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedSecond = 0;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: 0);
    _minuteController = FixedExtentScrollController(initialItem: 0);
    _secondController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_status == TimerStatus.paused) {
      setState(() => _status = TimerStatus.running);
    } else {
      _totalDuration = Duration(
        hours: _selectedHour,
        minutes: _selectedMinute,
        seconds: _selectedSecond,
      );
      if (_totalDuration.inSeconds == 0) return;
      _currentDuration = _totalDuration;
      setState(() => _status = TimerStatus.running);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _status = TimerStatus.paused);
  }

  void _cancelTimer() {
    _timer?.cancel();
    setState(() {
      _status = TimerStatus.stopped;
      _currentDuration = Duration.zero;
      _selectedTask = null;
    });
    _setTimer(0, 0, 0);
  }

  void _tick(Timer timer) {
    if (_currentDuration.inSeconds <= 0) {
      _timer?.cancel();
      setState(() {
        _status = TimerStatus.stopped;
        _currentDuration = Duration.zero;
      });
      _setTimer(0, 0, 0);
    } else {
      setState(() =>
      _currentDuration = _currentDuration - const Duration(seconds: 1));
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  int _findNearestIndex(int currentIndex, int targetValue, int maxVal) {
    int currentValue = (currentIndex % maxVal + maxVal) % maxVal;
    int diff = targetValue - currentValue;
    if (diff.abs() > maxVal / 2)
      diff = diff > 0 ? diff - maxVal : diff + maxVal;
    return currentIndex + diff;
  }

  void _setTimer(int h, int m, int s) {
    if (_status != TimerStatus.stopped) return;
    setState(() {
      _selectedHour = h;
      _selectedMinute = m;
      _selectedSecond = s;
    });
    if (_hourController.hasClients)
      _hourController.animateToItem(
          _findNearestIndex(_hourController.selectedItem, _selectedHour, 100),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    if (_minuteController.hasClients)
      _minuteController.animateToItem(
          _findNearestIndex(_minuteController.selectedItem, _selectedMinute, 60),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    if (_secondController.hasClients)
      _secondController.animateToItem(
          _findNearestIndex(_secondController.selectedItem, _selectedSecond, 60),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
  }

  void _onTaskSelected(Task? task) {
    setState(() => _selectedTask = task);
    if (task != null && task.startTime != null && task.endTime != null) {
      var duration = task.endTime!.difference(task.startTime!);
      if (duration.isNegative) duration += const Duration(days: 1);
      if (duration.inSeconds > 0) {
        _setTimer(duration.inHours, duration.inMinutes.remainder(60),
            duration.inSeconds.remainder(60));

        // Feedback visual
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Timer diset: ${duration.inHours} jam ${duration.inMinutes % 60} menit"),
            duration: const Duration(seconds: 1)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_status == TimerStatus.running && _selectedTask != null)
                Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      // Ubah warna badge jika urgent/telat
                        color: (_selectedTask!.endTime != null && DateTime.now().isAfter(_selectedTask!.endTime!))
                            ? Colors.red.shade100
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedTask!.endTime != null && DateTime.now().isAfter(_selectedTask!.endTime!))
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                          ),
                        Text("Fokus: ${_selectedTask!.title}",
                            style: TextStyle(
                                color: (_selectedTask!.endTime != null && DateTime.now().isAfter(_selectedTask!.endTime!))
                                    ? Colors.red.shade900
                                    : Colors.blue.shade800,
                                fontWeight: FontWeight.bold)),
                      ],
                    )),
              Expanded(
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _status == TimerStatus.stopped
                          ? _buildPickerUI(context)
                          : _buildCountdownDisplay(context))),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        key: const ValueKey('PickerUI'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildPickerLabels(context),
          const SizedBox(height: 8),
          _buildTimerPickers(context),
          const SizedBox(height: 30),
          const Divider(),
          const Text("Select Task for Today",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          _buildTaskSelector(context),
        ],
      ),
    );
  }

  Widget _buildTaskSelector(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    return StreamBuilder<List<Task>>(
      stream: db.taskDao.watchAllTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SizedBox(height: 20, child: CircularProgressIndicator());
        final allTasks = snapshot.data!;
        final now = DateTime.now();
        final todayTasks = allTasks.where((t) {
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day &&
              !t.isDone;
        }).toList();

        if (todayTasks.isEmpty)
          return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text("No tasks for today. Relax! ☕"));

        // Anti-Crash Logic: Cocokkan ID
        Task? currentDropdownValue;
        if (_selectedTask != null) {
          try {
            currentDropdownValue =
                todayTasks.firstWhere((t) => t.id == _selectedTask!.id);
          } catch (e) {
            currentDropdownValue = null;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Task>(
              value: currentDropdownValue,
              hint: const Text("Pilih tugas untuk dikerjakan..."),
              isExpanded: true,
              icon:
              const Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
              // MODIFIKASI TAMPILAN ITEM DROPDOWN DISINI
              items: todayTasks.map((Task task) {
                String rangeInfo = "";
                bool isOverdue = false;

                if (task.startTime != null && task.endTime != null) {
                  var duration = task.endTime!.difference(task.startTime!);
                  if (duration.isNegative) duration += const Duration(days: 1);
                  rangeInfo =
                  " (${duration.inHours}h ${duration.inMinutes % 60}m)";

                  // LOGIKA OVERDUE / TELAT
                  if (now.isAfter(task.endTime!)) {
                    isOverdue = true;
                  }
                }

                return DropdownMenuItem<Task>(
                    value: task,
                    child: Row(
                      children: [
                        // Jika telat, tampilkan ikon Warning
                        if (isOverdue)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                          ),
                        Expanded(
                          child: Text(
                            "${task.title}$rangeInfo",
                            overflow: TextOverflow.ellipsis,
                            // Jika telat, warna teks merah & tebal
                            style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.black87,
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ));
              }).toList(),
              onChanged: _onTaskSelected,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownDisplay(BuildContext context) {
    // Cek status urgent untuk tampilan Countdown juga
    bool isUrgent = false;
    if (_selectedTask != null && _selectedTask!.endTime != null) {
      if (DateTime.now().isAfter(_selectedTask!.endTime!)) {
        isUrgent = true;
      }
    }

    final displayColor = isUrgent ? Colors.red : Theme.of(context).colorScheme.primary;

    return Container(
      key: const ValueKey('CountdownUI'),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formatDuration(_currentDuration),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 64,
                  fontFamily: 'Roboto',
                  color: displayColor)), // Warna merah jika urgent
          const SizedBox(height: 20),
          if (_totalDuration.inSeconds > 0)
            SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                    value:
                    _currentDuration.inSeconds / _totalDuration.inSeconds,
                    backgroundColor: Colors.grey.shade200,
                    color: displayColor, // Warna progress bar merah jika urgent
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10))),
        ],
      ),
    );
  }

  Widget _buildPickerLabels(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium;
    return Row(children: [
      Expanded(child: Center(child: Text('Hours', style: labelStyle))),
      const SizedBox(width: 40),
      Expanded(child: Center(child: Text('Minutes', style: labelStyle))),
      const SizedBox(width: 40),
      Expanded(child: Center(child: Text('Seconds', style: labelStyle)))
    ]);
  }

  Widget _buildTimerPickers(BuildContext context) {
    final itemStyle = TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface);
    Widget buildPicker(FixedExtentScrollController controller, int maxVal,
        Function(int) onChanged) {
      return Expanded(
          child: CupertinoPicker.builder(
              scrollController: controller,
              itemExtent: 70.0,
              childCount: null,
              onSelectedItemChanged: (int index) =>
                  onChanged((index % maxVal + maxVal) % maxVal),
              magnification: 1.1,
              useMagnifier: true,
              itemBuilder: (context, index) => Center(
                  child: Text(
                      ((index % maxVal + maxVal) % maxVal)
                          .toString()
                          .padLeft(2, '0'),
                      style: itemStyle))));
    }

    return SizedBox(
        height: 200,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          buildPicker(
              _hourController, 100, (v) => setState(() => _selectedHour = v)),
          Text(':', style: itemStyle.copyWith(fontSize: 48)),
          buildPicker(_minuteController, 60,
                  (v) => setState(() => _selectedMinute = v)),
          Text(':', style: itemStyle.copyWith(fontSize: 48)),
          buildPicker(
              _secondController, 60, (v) => setState(() => _selectedSecond = v))
        ]));
  }

  Widget _buildActionButtons(BuildContext context) {
    Widget primary(String l, VoidCallback o) => ElevatedButton(
        onPressed: o,
        style: ElevatedButton.styleFrom(minimumSize: const Size(150, 56)),
        child: Text(l, style: const TextStyle(fontSize: 18)));
    Widget secondary(String l, VoidCallback o) => OutlinedButton(
        onPressed: o,
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(150, 56),
            foregroundColor: Theme.of(context).colorScheme.secondary),
        child: Text(l, style: const TextStyle(fontSize: 18)));
    if (_status == TimerStatus.stopped) return primary('Start', _startTimer);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      secondary('Cancel', _cancelTimer),
      primary(
          _status == TimerStatus.running ? 'Pause' : 'Resume',
          _status == TimerStatus.running ? _pauseTimer : _startTimer)
    ]);
  }
}