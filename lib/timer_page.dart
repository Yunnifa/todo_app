import 'dart:async'; // Impor untuk logic Timer
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Enum untuk melacak status timer
enum TimerStatus { stopped, running, paused }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  // --- Variabel State untuk Logika Timer ---
  Timer? _timer;
  Duration _totalDuration = Duration.zero;
  Duration _currentDuration = Duration.zero;
  TimerStatus _status = TimerStatus.stopped;
  // -----------------------------------------

  // Variabel State untuk Picker
  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedSecond = 0;

  // Controller untuk Picker
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  @override
  void initState() {
    super.initState();
    //Gunakan 0 sebagai item awal untuk SEMUA picker yang looping
    _hourController = FixedExtentScrollController(initialItem: 0);
    _minuteController = FixedExtentScrollController(initialItem: 0);
    _secondController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer dibatalkan saat halaman ditutup
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  // --- Fungsi Logika Timer ---

  void _startTimer() {
    // Jika timer di-resume dari pause
    if (_status == TimerStatus.paused) {
      setState(() {
        _status = TimerStatus.running;
      });
    }
    // Jika timer dimulai dari awal
    else {
      _totalDuration = Duration(
        hours: _selectedHour,
        minutes: _selectedMinute,
        seconds: _selectedSecond,
      );
      // Jangan mulai jika durasi 0
      if (_totalDuration.inSeconds == 0) return;

      _currentDuration = _totalDuration;
      setState(() {
        _status = TimerStatus.running;
      });
    }

    // Mulai timer periodik yang berjalan setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _status = TimerStatus.paused;
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    setState(() {
      _status = TimerStatus.stopped;
      _currentDuration = Duration.zero;
    });
    // Reset picker ke 00:00:00
    _setTimer(0, 0, 0);
  }

  // Fungsi yang dipanggil setiap detik oleh _timer
  void _tick(Timer timer) {
    if (_currentDuration.inSeconds <= 0) {
      // Timer selesai
      _timer?.cancel();
      setState(() {
        _status = TimerStatus.stopped;
        _currentDuration = Duration.zero;
      });
      _setTimer(0, 0, 0); // Reset picker
      // Di sini Anda bisa tambahkan logika notifikasi atau suara
    } else {
      // Kurangi durasi 1 detik
      setState(() {
        _currentDuration = _currentDuration - const Duration(seconds: 1);
      });
    }
  }

  // Helper untuk format durasi (Contoh: 01:30:05)
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // --- PERBAIKAN: Helper untuk mencari index terdekat untuk looping picker ---
  int _findNearestIndex(int currentIndex, int targetValue, int maxVal) {
    int currentValue = (currentIndex % maxVal + maxVal) % maxVal;
    int diff = targetValue - currentValue;
    // Jika jarak lebih dari setengah putaran, pergi ke arah sebaliknya
    if (diff.abs() > maxVal / 2) {
      diff = diff > 0 ? diff - maxVal : diff + maxVal;
    }
    return currentIndex + diff;
  }

  // Helper untuk mengatur picker (dari tombol preset)
  void _setTimer(int h, int m, int s) {
    // Hanya izinkan set jika timer tidak sedang berjalan
    if (_status != TimerStatus.stopped) return;

    setState(() {
      _selectedHour = h;
      _selectedMinute = m;
      _selectedSecond = s;
    });

    // --- PERBAIKAN: Animasikan jam (sekarang looping) ---
    int targetHourIndex =
    _findNearestIndex(_hourController.selectedItem, _selectedHour, 100);
    _hourController.animateToItem(
      targetHourIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    // --- PERBAIKAN: Animasikan picker menit & detik ke index terdekat ---
    int targetMinIndex =
    _findNearestIndex(_minuteController.selectedItem, _selectedMinute, 60);
    _minuteController.animateToItem(
      targetMinIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    int targetSecIndex =
    _findNearestIndex(_secondController.selectedItem, _selectedSecond, 60);
    _secondController.animateToItem(
      targetSecIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // --- Bagian Build (UI) ---

  @override
  Widget build(BuildContext context) {
    // Scaffold akan otomatis mengambil warna dari AppTheme
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian ATAS: Menampilkan Picker atau Countdown
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _status == TimerStatus.stopped
                    ? _buildPickerUI(context) // Tampilkan picker
                    : _buildCountdownDisplay(context), // Tampilkan countdown
              ),

              // Bagian BAWAH: Tombol Aksi
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// UI untuk Tampilan Picker dan Preset
  Widget _buildPickerUI(BuildContext context) {
    return Column(
      key: const ValueKey('PickerUI'), // Key untuk animasi
      children: [
        // --- PERBAIKAN OVERFLOW: Mengurangi padding vertikal ---
        const SizedBox(height: 10), // Sebelumnya 20
        _buildPickerLabels(context),
        const SizedBox(height: 8),
        _buildTimerPickers(context), // Kirim context untuk tema
        const SizedBox(height: 30), // Sebelumnya 40
        _buildPresetButtons(),
      ],
    );
  }

  /// UI untuk Tampilan Countdown
  Widget _buildCountdownDisplay(BuildContext context) {
    return Container(
      key: const ValueKey('CountdownUI'), // Key untuk animasi
      // --- PERBAIKAN OVERFLOW: Mengurangi tinggi container ---
      height: 390, // Sebelumnya 400
      alignment: Alignment.center,
      child: Text(
        _formatDuration(_currentDuration),
        // Gunakan style dari AppTheme
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 64,
          fontFamily: 'Roboto', // Sesuai kode yang Anda paste
          color: Theme.of(context).colorScheme.primary, // Warna utama
        ),
      ),
    );
  }

  /// Label "Hours", "Minutes", "Seconds"
  Widget _buildPickerLabels(BuildContext context) {
    // Gunakan style dari AppTheme
    final labelStyle = Theme.of(context).textTheme.titleMedium;

    return Row(
      children: [
        Expanded(child: Center(child: Text('Hours', style: labelStyle))),
        const SizedBox(width: 40),
        Expanded(child: Center(child: Text('Minutes', style: labelStyle))),
        const SizedBox(width: 40),
        Expanded(child: Center(child: Text('Seconds', style: labelStyle))),
      ],
    );
  }

  /// 3 Picker (Jam, Menit, Detik)
  Widget _buildTimerPickers(BuildContext context) {
    // Gunakan style dari AppTheme
    final itemStyle = TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );

    Widget colonSeparator = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: itemStyle.copyWith(fontSize: 48), // Sesuaikan ukuran
      ),
    );

    // --- PERBAIKAN: Fungsi build picker dengan opsi looping ---
    Widget buildPicker(
        FixedExtentScrollController controller,
        int maxVal,
        Function(int) onChanged, {
          bool looping = false,
        }) {
      return Expanded(
        child: CupertinoPicker.builder(
          scrollController: controller,
          itemExtent: 70.0,
          // --- PERBAIKAN: Gunakan 'null' untuk childCount agar looping ---
          childCount: looping ? null : maxVal,
          onSelectedItemChanged: (int index) {
            // Terapkan modulo untuk mendapatkan nilai 0-59
            final int value =
            looping ? (index % maxVal + maxVal) % maxVal : index;
            onChanged(value);
          },
          magnification: 1.1,
          useMagnifier: true,
          itemBuilder: (BuildContext context, int index) {
            // Terapkan modulo untuk mendapatkan nilai 0-59
            final int value =
            looping ? (index % maxVal + maxVal) % maxVal : index;

            // Jangan render item di luar jangkauan untuk picker yang tidak looping
            if (!looping && (index < 0 || index >= maxVal)) {
              return null;
            }

            return Center(
              child: Text(
                value.toString().padLeft(2, '0'),
                style: itemStyle,
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Jam (sekarang looping, 0-99)
          buildPicker(
            _hourController,
            100, // <-- PERUBAHAN DI SINI (0-99)
                (value) => setState(() => _selectedHour = value),
            looping: true, // <-- PERUBAHAN DI SINI
          ),
          colonSeparator,
          // Menit (looping, 0-59)
          buildPicker(
            _minuteController,
            60,
                (value) => setState(() => _selectedMinute = value),
            looping: true,
          ),
          colonSeparator,
          // Detik (looping, 0-59)
          buildPicker(
            _secondController,
            60,
                (value) => setState(() => _selectedSecond = value),
            looping: true,
          ),
        ],
      ),
    );
  }

  /// Tombol preset
  Widget _buildPresetButtons() {
    // Gunakan FilledButton.tonal agar sesuai tema
    // Warnanya akan otomatis diambil dari colorScheme
    Widget presetButton(String label, VoidCallback onPressed) {
      return FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          fixedSize: const Size(100, 100),
        ),
        child: Text(label),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        presetButton('00:10:00', () => _setTimer(0, 10, 0)),
        presetButton('00:15:00', () => _setTimer(0, 15, 0)),
        presetButton('00:30:00', () => _setTimer(0, 30, 0)),
      ],
    );
  }

  /// Tombol aksi (Start, Pause, Cancel, Resume)
  Widget _buildActionButtons(BuildContext context) {
    // Menggunakan ElevatedButton akan otomatis mengambil style dari AppTheme
    Widget primaryButton(String label, VoidCallback onPressed) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 56), // Beri ukuran
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      );
    }

    // Menggunakan OutlinedButton untuk aksi sekunder (Cancel)
    Widget secondaryButton(String label, VoidCallback onPressed) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(150, 56),
          foregroundColor: Theme.of(context).colorScheme.secondary, // Warna teks
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      );
    }

    // Logika untuk menampilkan tombol yang sesuai
    switch (_status) {
      case TimerStatus.stopped:
        return primaryButton('Start', _startTimer);
      case TimerStatus.running:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            secondaryButton('Cancel', _cancelTimer),
            primaryButton('Pause', _pauseTimer),
          ],
        );
      case TimerStatus.paused:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            secondaryButton('Cancel', _cancelTimer),
            primaryButton('Resume', _startTimer), // _startTimer juga menangani resume
          ],
        );
    }
  }
}