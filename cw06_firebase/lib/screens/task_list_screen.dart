import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';
import 'package:uuid/uuid.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> tasks = [];
  final _uuid = Uuid();

  void _addTask(String name) {
    setState(() {
      tasks.add(Task(
        id: _uuid.v4(),
        name: name,
      ));
    });
  }

  void _addSubTask(Task task, String timeSlot, String description) {
    setState(() {
      task.subTasks.add(SubTask(
        id: _uuid.v4(),
        timeSlot: timeSlot,
        description: description,
      ));
    });
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _toggleSubTaskCompletion(SubTask subTask) {
    setState(() {
      subTask.isCompleted = !subTask.isCompleted;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  void _deleteSubTask(Task task, SubTask subTask) {
    setState(() {
      task.subTasks.remove(subTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskItem(
            task: tasks[index],
            onToggle: _toggleTaskCompletion,
            onDelete: _deleteTask,
            onAddSubTask: _addSubTask,
            onToggleSubTask: _toggleSubTaskCompletion,
            onDeleteSubTask: _deleteSubTask,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTaskDialog(onAdd: _addTask),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
