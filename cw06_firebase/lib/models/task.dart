class Task {
  String id;
  String name;
  bool isCompleted;
  List<SubTask> subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.subTasks = const [],
  });
}

class SubTask {
  String id;
  String timeSlot;
  String description;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.timeSlot,
    required this.description,
    this.isCompleted = false,
  });
}
