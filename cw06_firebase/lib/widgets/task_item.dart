import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onToggle;
  final Function(Task) onDelete;
  final Function(Task, String, String) onAddSubTask;
  final Function(SubTask) onToggleSubTask;
  final Function(Task, SubTask) onDeleteSubTask;

  TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onAddSubTask,
    required this.onToggleSubTask,
    required this.onDeleteSubTask,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(task),
            ),
            Expanded(
              child: Text(
                task.name,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => onDelete(task),
            ),
          ],
        ),
        children: [
          ...task.subTasks.map((subTask) => ListTile(
                leading: Checkbox(
                  value: subTask.isCompleted,
                  onChanged: (_) => onToggleSubTask(subTask),
                ),
                title: Text('${subTask.timeSlot} - ${subTask.description}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => onDeleteSubTask(task, subTask),
                ),
              )),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Sub-task'),
            onTap: () => _showAddSubTaskDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAddSubTaskDialog(BuildContext context) {
    final timeController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Sub-task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Time Slot (e.g., 9 AM - 10 AM)',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (timeController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                onAddSubTask(
                  task,
                  timeController.text,
                  descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
