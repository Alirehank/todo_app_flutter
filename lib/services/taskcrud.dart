import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/services/authservice.dart';
import 'package:todo_app/model/task_model.dart';

class TaskService {
  static const baseUrl = 'https://dd00b02f3f31.ngrok-free.app/api/tasks';

  static Future<List<Task>> getTasks() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Check if decoded is a List or Map
      if (decoded is List) {
        return decoded.map((json) => Task.fromJson(json)).toList();
      } else if (decoded is Map && decoded.containsKey('data')) {
        final List tasks = decoded['data'];
        return tasks.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<void> createTask(
    BuildContext context,
    String title,
    String? description,
  ) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (res.statusCode != 201) {
      String errorMsg = 'Failed to create task';

      try {
        final Map<String, dynamic> errorResponse = jsonDecode(res.body);
        if (errorResponse.containsKey('errors')) {
          // Extract the first error message
          final firstFieldErrors = errorResponse['errors'].values.first;
          if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
            errorMsg = firstFieldErrors.first;
          }
        } else if (errorResponse.containsKey('message')) {
          errorMsg = errorResponse['message'];
        }
      } catch (e) {
        // Parsing failed, keep default error message
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  static Future<void> updateTask(BuildContext context, Task task) async {
    final token = await AuthService.getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/${task.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJson()),
    );

    if (res.statusCode != 200) {
      String errorMsg = 'Failed to update task';

      try {
        final Map<String, dynamic> errorResponse = jsonDecode(res.body);
        if (errorResponse.containsKey('errors')) {
          final firstFieldErrors = errorResponse['errors'].values.first;
          if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
            errorMsg = firstFieldErrors.first;
          }
        } else if (errorResponse.containsKey('message')) {
          errorMsg = errorResponse['message'];
        }
      } catch (e) {
        // Ignore and use default error
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  static Future<void> deleteTask(int id) async {
    final token = await AuthService.getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 204) throw Exception('Failed to delete task');
  }
}
