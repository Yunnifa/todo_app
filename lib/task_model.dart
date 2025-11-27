class Task {
  String title;
  bool isDone;
  final DateTime date;

  Task({required this.title, this.isDone = false, required this.date});
}

class TaskData {
  static final List<Task> tasks = [
    Task(title: 'Mengerjakan Tugas Akhir', date: DateTime.now(), isDone: false),
    Task(title: 'Belajar Flutter State Management', date: DateTime.now(), isDone: true),
    Task(title: 'Beli beras dan galon', date: DateTime.now().subtract(const Duration(days: 1)), isDone: true),
    Task(title: 'Meeting dengan tim capstone', date: DateTime.now().add(const Duration(days: 1)), isDone: false),
    Task(title: 'Olahraga lari 30 menit', date: DateTime.now().add(const Duration(days: 1)), isDone: false),
    Task(title: 'Mengerjakan capstone project', date: DateTime.now().add(const Duration(days: 2)), isDone: false),
  ];
}
