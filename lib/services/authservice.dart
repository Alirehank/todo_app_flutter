import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const baseUrl = 'https://dd00b02f3f31.ngrok-free.app/api';

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (res.statusCode == 201) {
      await saveToken(jsonDecode(res.body)['token']);
    } else {
      String errorMsg = 'Failed to register';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded.containsKey('errors')) {
          final firstError = decoded['errors'].values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMsg = firstError.first;
          }
        } else if (decoded.containsKey('message')) {
          errorMsg = decoded['message'];
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("Status code: ${res.statusCode}");
    print("Response body: ${res.body}");

    {
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        await saveToken(data['token']);
      } else {
        // Handle error message from Laravel
        throw Exception(data['message'] ?? 'Login failed');
      }
    }
  }

  static Future<void> logout() async {
    final token = await getToken();
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await removeToken();
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
