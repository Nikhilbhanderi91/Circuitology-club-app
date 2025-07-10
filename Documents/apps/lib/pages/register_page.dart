import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;


/// Platform-specific base URL
String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000'; // Android Emulator
  if (Platform.isIOS || Platform.isMacOS) return 'http://127.0.0.1:8000'; // iOS Simulator
  return 'http://localhost:8000'; // Fallback
}

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final first = TextEditingController();
  final last = TextEditingController();
  final email = TextEditingController();
  final gr = TextEditingController();
  final enroll = TextEditingController();
  final phone = TextEditingController();
  final sem = TextEditingController();
  final stream = TextEditingController();
  final pass = TextEditingController();

  String responseMessage = '';

  /// Submit user registration to Laravel API
  Future<void> registerUser() async {
    final url = Uri.parse("${getBaseUrl()}/api/register");

    final body = jsonEncode({
      "first_name": first.text,
      "last_name": last.text,
      "email": email.text,
      "gr_no": gr.text,
      "enrollment_no": enroll.text,
      "phone_no": phone.text,
      "semester": int.tryParse(sem.text) ?? 0,
      "stream": stream.text,
      "password": pass.text,
      "password_confirmation": pass.text, // ✅ Required for Laravel
    });

    try {
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // ✅ Laravel responds in JSON
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final response = jsonDecode(res.body);
        setState(() => responseMessage = ' ${response['message']}');
        clearForm();
      } else {
        print("Laravel Error: ${res.body}");
        setState(() => responseMessage = 'Failed: ${res.body}');
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      setState(() => responseMessage = '⚠️ Error: $e');
    }
  }

  void clearForm() {
    first.clear();
    last.clear();
    email.clear();
    gr.clear();
    enroll.clear();
    phone.clear();
    sem.clear();
    stream.clear();
    pass.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register User")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextField(controller: first, decoration: InputDecoration(labelText: "First Name")),
              TextField(controller: last, decoration: InputDecoration(labelText: "Last Name")),
              TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: gr, decoration: InputDecoration(labelText: "GR No")),
              TextField(controller: enroll, decoration: InputDecoration(labelText: "Enrollment No")),
              TextField(controller: phone, decoration: InputDecoration(labelText: "Phone No")),
              TextField(
                controller: sem,
                decoration: InputDecoration(labelText: "Semester"),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: stream, decoration: InputDecoration(labelText: "Stream")),
              TextField(
                controller: pass,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: registerUser, child: Text("Register")),
              SizedBox(height: 16),
              Text(responseMessage),
            ],
          ),
        ),
      ),
    );
  }
}
