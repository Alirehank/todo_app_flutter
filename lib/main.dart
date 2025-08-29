import 'package:flutter/material.dart';
import 'package:todo_app/screens/dashboard.dart';
import 'package:todo_app/screens/login.dart';
import 'package:todo_app/services/authservice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> _getInitialPage() async {
    final token = await AuthService.getToken();
    return token == null ? LoginPage() : DashboardPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return snapshot.data!;
        },
      ),
    );
  }
}
