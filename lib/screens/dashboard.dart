import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:todo_app/screens/login.dart';
import 'package:todo_app/screens/taskform.dart';
import 'package:todo_app/services/authservice.dart';
import 'package:todo_app/services/taskcrud.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Task>> _taskFuture;
  String _filter = 'All';
  @override
  void initState() {
    super.initState();
    _taskFuture = TaskService.getTasks();
  }

  void refresh() {
    setState(() {
      _taskFuture = TaskService.getTasks();
    });
  }

  void logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: Text('My Tasks'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No tasks found.\nTap '+' to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final t = tasks[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    t.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (t.description != null && t.description!.isNotEmpty)
                          Text(t.description!, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text(
                          "Created: ${formatDate(t.createdAt)}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          "Completed: ${t.isCompleted == true ? 'Yes' : 'No'}",
                          style: TextStyle(
                            color: t.isCompleted == true
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await TaskService.deleteTask(t.id);
                      refresh();
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskFormPage(task: t)),
                    );
                    refresh();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        icon: Icon(Icons.add),
        label: Text("New Task"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskFormPage()),
          );
          refresh();
        },
      ),
    );
  }
}
