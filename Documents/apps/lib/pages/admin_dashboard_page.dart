import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'club_members_page.dart';
import 'manage_events_page.dart'; // ✅ Import ManageEventsPage

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? adminData;
  bool isLoading = true;
  final String baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    fetchAdminProfile();
  }

  Future<void> fetchAdminProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      logoutAdmin();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => adminData = data['admin']);
      } else {
        logoutAdmin();
      }
    } catch (e) {
      print("❌ Admin fetch error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> logoutAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_admin');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Drawer buildAdminDrawer() {
    if (adminData == null) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final fullName = adminData?['name'] ?? '';
    final email = adminData?['email'] ?? '';
    final phone = adminData?['phone'] ?? '-';
    final joined = adminData?['created_at'] ?? '-';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(fullName, style: const TextStyle(color: Colors.white)),
            accountEmail: Text(email, style: const TextStyle(color: Colors.white70)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.deepPurple, size: 38),
            ),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text("Phone: $phone", style: GoogleFonts.poppins()),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text("Joined: $joined", style: GoogleFonts.poppins()),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: Text("Role: Admin", style: GoogleFonts.poppins()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: logoutAdmin,
          ),
        ],
      ),
    );
  }

  Widget buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.deepPurple,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = adminData?['name'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: buildAdminDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fullName.isNotEmpty)
              Text("Welcome, $fullName",
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 30),

            // View Members
            buildDashboardCard(
              icon: Icons.people,
              title: "View Club Members",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ClubMembersPage()),
                );
              },
              color: Colors.deepPurple,
            ),

            // Manage Events
            buildDashboardCard(
              icon: Icons.event_note,
              title: "Manage Events",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageEventsPage()),
                );
              },
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}
