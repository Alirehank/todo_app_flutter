
// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

List<Task> taskFromJson(String str) => List<Task>.from(json.decode(str).map((x) => Task.fromJson(x)));

String taskToJson(List<Task> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Task {
    int id;
    int userId;
    String title;
    String? description;
    bool isCompleted;
    DateTime createdAt;
    DateTime updatedAt;

    Task({
        required this.id,
        required this.userId,
        required this.title,
        this.description,
        required this.isCompleted,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        description: json["description"],
        isCompleted: json["is_completed"] == 1,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "description": description,
        "is_completed": isCompleted ? 1 : 0,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
