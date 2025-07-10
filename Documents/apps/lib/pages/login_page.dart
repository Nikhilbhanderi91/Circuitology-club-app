import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_page.dart';
import 'user_home_page.dart';
import 'admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  String responseMessage = '';
  bool isLoading = false;

  Future<void> loginUser({required bool isAdmin}) async {
    setState(() {
      isLoading = true;
      responseMessage = '';
    });

    final url = Uri.parse(
      isAdmin
          ? "http://10.0.2.2:8000/api/admin/login"
          : "http://10.0.2.2:8000/api/login",
    );

    final body = jsonEncode({
      "email": email.text.trim(),
      "password": password.text.trim(),
    });

    try {
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("🔁 Raw login response: ${res.body}");

      final data = jsonDecode(res.body);
      final token = data['token'] ?? data['access_token'];

      if (token == null) {
        print("❌ Token is null in response");
        setState(() {
          responseMessage = '❌ Login Failed: Token missing';
          isLoading = false;
        });
        return;
      }

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final saved = await prefs.setString('auth_token', token);
        await prefs.setBool('is_admin', isAdmin);

        if (saved) {
          print("✅ Token saved: ${prefs.getString('auth_token')}");
          setState(() => responseMessage = "✅ Login Successful");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
              isAdmin ? const AdminDashboardPage() : const UserHomePage(),
            ),
          );
        } else {
          print("❌ Failed to save token");
          setState(() => responseMessage = "⚠️ Token save failed");
        }
      } else {
        print("❌ Login failed: ${data['message'] ?? 'Unknown error'}");
        setState(() {
          responseMessage = '❌ Login Failed: ${data['message'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      print("⚠️ Exception during login: $e");
      setState(() => responseMessage = '⚠️ Network Error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: password,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text("Login as User"),
                    onPressed: () => loginUser(isAdmin: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text("Login as Admin"),
                    onPressed: () => loginUser(isAdmin: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                responseMessage,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  RegisterPage()),
                ),
                child: const Text("New? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
