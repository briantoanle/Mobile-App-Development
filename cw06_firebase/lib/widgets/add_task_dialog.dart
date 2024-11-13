import 'package:flutter/material.dart';

class AddTaskDialog extends StatelessWidget {
  final Function(String) onAdd;
  final textController = TextEditingController();

  AddTaskDialog({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: TextField(
        controller: textController,
        decoration: InputDecoration(
          labelText: 'Task Name',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              onAdd(textController.text);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
