import 'package:flutter/material.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:todo_app/services/taskcrud.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;

  TaskFormPage({this.task});

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleCtrl.text = widget.task!.title;
      descCtrl.text = widget.task!.description ?? '';
      isCompleted = widget.task!.isCompleted ?? false;
    }
  }

  void saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.task == null) {
      await TaskService.createTask(context, titleCtrl.text, descCtrl.text);
    } else {
      await TaskService.updateTask(
        context,
        Task(
          id: widget.task!.id,
          title: titleCtrl.text,
          description: descCtrl.text,
          isCompleted: isCompleted,
          userId: widget.task!.userId,
          createdAt: widget.task!.createdAt,
          updatedAt: DateTime.now(),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    widget.task == null ? Icons.add_task : Icons.edit_note,
                    size: 60,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  SizedBox(height: 16),
                  if (widget.task != null)
                    CheckboxListTile(
                      title: Text('Mark as Completed'),
                      value: isCompleted,
                      onChanged: (val) {
                        setState(() {
                          isCompleted = val ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.task == null ? 'Create Task' : 'Update Task',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
