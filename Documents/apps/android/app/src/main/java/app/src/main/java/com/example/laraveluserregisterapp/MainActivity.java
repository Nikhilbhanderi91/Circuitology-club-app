import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                title: 'Laravel API Register',
                theme: ThemeData(primarySwatch: Colors.blue),
        home: RegisterScreen(),
    );
    }
}

class RegisterScreen extends StatefulWidget {
    @override
    _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passCtrl = TextEditingController();

    String message = '';

    Future<void> registerUser() async {
        var url = Uri.parse('http://10.0.2.2:8000/api/register'); // for Android Emulator

        var response = await http.post(
                url,
                headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
                'name': nameCtrl.text,
                'email': emailCtrl.text,
                'password': passCtrl.text,
      }),
    );

        if (response.statusCode == 200 || response.statusCode == 201) {
            setState(() {
                message = "✅ Registered: ${response.body}";
            });
        } else {
            setState(() {
                message = "❌ Error: ${response.body}";
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                appBar: AppBar(title: Text("User Register")),
        body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                children: [
        TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Name'),
            ),
        TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email'),
            ),
        TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
            ),
        SizedBox(height: 20),
        ElevatedButton(
                onPressed: registerUser,
                child: Text("Register"),
            ),
        SizedBox(height: 20),
        Text(message),
          ],
        ),
      ),
    );
    }
}
