import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  Map<String, dynamic>? userData;
  List<dynamic> upcomingEvents = [];
  List<dynamic> finishedEvents = [];
  bool isLoading = true;
  bool showFinished = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfileAndEvents();
  }

  Future<void> fetchUserProfileAndEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        print("❌ No token found");
        setState(() => isLoading = false);
        return;
      }

      final profileRes = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final eventsRes = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/events'),
        headers: {'Accept': 'application/json'},
      );

      if (profileRes.statusCode == 200 && eventsRes.statusCode == 200) {
        final userJson = jsonDecode(profileRes.body);
        final eventJson = jsonDecode(eventsRes.body);

        setState(() {
          userData = userJson['user'];
          upcomingEvents = eventJson['upcomingEvents'] ?? [];
          finishedEvents = eventJson['finishedEvents'] ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Failed to load data");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> registerEvent(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final res = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/events/$eventId/register'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registered successfully!")),
        );
      } else {
        final errorMsg = json.decode(res.body)['message'] ?? "Registration failed";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: $errorMsg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> viewWinners(int eventId) async {
    final res = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/event/$eventId/winners'),
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      final winners = json.decode(res.body);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: winners.isEmpty
              ? const Text("⚠️ No winners declared yet.")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🏆 Top Winners",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...winners.map<Widget>((winner) {
                return ListTile(
                  leading: const Icon(Icons.emoji_events,
                      color: Colors.amber),
                  title: Text(winner['winner_name'],
                      style: GoogleFonts.poppins()),
                  trailing: Text("Rank: ${winner['rank']}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold)),
                );
              }).toList(),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No winners found")),
      );
    }
  }

  void showRegisterModal(Map<String, dynamic> event) {
    bool acceptedTerms = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event['event_name'],
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(event['event_description'], style: GoogleFonts.poppins()),
              const SizedBox(height: 10),
              Text("Date: ${event['event_date']}", style: GoogleFonts.poppins()),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: acceptedTerms,
                onChanged: (value) {
                  setModalState(() => acceptedTerms = value ?? false);
                },
                title: const Text("I agree to the terms and conditions."),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: acceptedTerms
                          ? () => registerEvent(event['event_id'])
                          : null,
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventCard(String title, List events, bool isRegister) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (events.isEmpty)
          Text("No $title", style: GoogleFonts.poppins())
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(event['event_name'], style: GoogleFonts.poppins()),
                  subtitle: Text(event['event_description'], style: GoogleFonts.poppins()),
                  trailing: ElevatedButton(
                    onPressed: () {
                      isRegister
                          ? showRegisterModal(event)
                          : viewWinners(event['event_id']);
                    },
                    child: Text(isRegister ? "Register" : "Winners"),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget buildToggleBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => showFinished = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !showFinished ? Colors.deepPurple : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text("Upcoming Events",
                    style: GoogleFonts.poppins(
                        color: !showFinished ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => showFinished = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: showFinished ? Colors.deepPurple : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text("Finished Events",
                    style: GoogleFonts.poppins(
                        color: showFinished ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDrawer(String fullName) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(fullName),
            accountEmail: Text(userData?['email'] ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          buildDrawerItem(Icons.badge, "GR No", userData!['gr_no']),
          buildDrawerItem(Icons.numbers, "Enrollment No", userData!['enrollment_no']),
          buildDrawerItem(Icons.phone, "Phone", userData!['phone_no']),
          buildDrawerItem(Icons.school, "Sem / Stream",
              "Sem ${userData!['semester']} • ${userData!['stream']}"),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_admin');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = "${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Circuitology Club", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.account_circle_rounded),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: userData == null ? null : buildDrawer(fullName),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $fullName",
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            buildToggleBar(),
            const SizedBox(height: 20),
            buildEventCard(
              showFinished ? "Finished Events" : "Upcoming Events",
              showFinished ? finishedEvents : upcomingEvents,
              !showFinished,
            ),
          ],
        ),
      ),
    );
  }
}
