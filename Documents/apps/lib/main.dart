import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'pages/user_home_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/register_page.dart';
import 'pages/club_members_page.dart';
import 'pages/manage_events_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final isAdmin = prefs.getBool('is_admin') ?? false;

  runApp(MyApp(
    initialScreen: token != null
        ? (isAdmin ? const AdminDashboardPage() : const UserHomePage())
        : const LoginScreen(),
  ));
}

String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  if (Platform.isIOS || Platform.isMacOS) return 'http://127.0.0.1:8000';
  return 'http://localhost:8000';
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laravel Flutter Auth',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: initialScreen,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/userhome': (context) => const UserHomePage(),
        '/admin': (context) => const AdminDashboardPage(),
        '/members': (context) => const ClubMembersPage(),
        '/manage_events': (context) => const ManageEventsPage(), // ✅ New route
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final userEmail = TextEditingController();
  final userPassword = TextEditingController();
  final adminEmail = TextEditingController();
  final adminPassword = TextEditingController();
  String userResponse = '';
  String adminResponse = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> loginUser() async {
    final url = Uri.parse('${getBaseUrl()}/api/login');
    try {
      final res = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail.text.trim(),
          'password': userPassword.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);
      final token = data['token'] ?? data['access_token'];

      if (res.statusCode == 200 && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setBool('is_admin', false);

        Navigator.pushReplacementNamed(context, '/userhome');
      } else {
        setState(() => userResponse = data['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => userResponse = "⚠️ Error: $e");
    }
  }

  Future<void> loginAdmin() async {
    final url = Uri.parse('${getBaseUrl()}/api/admin/login');
    try {
      final res = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': adminEmail.text.trim(),
          'password': adminPassword.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);
      final token = data['token'] ?? data['access_token'];

      if (res.statusCode == 200 && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setBool('is_admin', true);

        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        setState(() => adminResponse = data['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => adminResponse = "⚠️ Error: $e");
    }
  }

  Widget buildLoginForm({
    required String label,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required VoidCallback onLogin,
    required String responseMsg,
    required VoidCallback onRegisterClick,
    bool isAdmin = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, size: 80, color: Colors.indigo),
          const SizedBox(height: 16),
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: "$label Email",
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.login),
            label: const Text("Login"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          if (!isAdmin)
            TextButton(
              onPressed: onRegisterClick,
              child: const Text("New user? Register here →"),
            ),
          const SizedBox(height: 12),
          if (responseMsg.isNotEmpty)
            Text(responseMsg,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Welcome to Circuitology Club!",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "User"),
            Tab(icon: Icon(Icons.security), text: "Admin"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildLoginForm(
            label: "User",
            emailCtrl: userEmail,
            passCtrl: userPassword,
            onLogin: loginUser,
            responseMsg: userResponse,
            onRegisterClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterPage()),
              );
            },
          ),
          buildLoginForm(
            label: "Admin",
            emailCtrl: adminEmail,
            passCtrl: adminPassword,
            onLogin: loginAdmin,
            responseMsg: adminResponse,
            onRegisterClick: () {},
            isAdmin: true,
          ),
        ],
      ),
    );
  }
}
