import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClubMembersPage extends StatefulWidget {
  const ClubMembersPage({super.key});

  @override
  State<ClubMembersPage> createState() => _ClubMembersPageState();
}

class _ClubMembersPageState extends State<ClubMembersPage> {
  final String baseUrl = 'http://127.0.0.1:8000'; // Replace with your IP for real device testing
  List<dynamic> members = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClubMembers();
  }

  Future<void> fetchClubMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("❌ Token not found. Redirect to login.");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/members'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          setState(() => members = decoded);
        } else {
          print("❌ API returned unexpected format: $decoded");
        }
      } else {
        print("❌ Failed to load members: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching members: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildMemberCard(Map<String, dynamic> member) {
    final fullName = "${member['first_name'] ?? ''} ${member['last_name'] ?? ''}";
    final email = member['email'] ?? 'N/A';
    final phone = member['phone_no'] ?? 'N/A';
    final grNo = member['gr_no'] ?? 'N/A';
    final enroll = member['enrollment_no'] ?? 'N/A';
    final semester = member['semester']?.toString() ?? 'N/A';
    final stream = member['stream'] ?? 'N/A';
    final role = member['is_admin'] == true ? "Admin" : "Member";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(fullName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: GoogleFonts.poppins(fontSize: 13)),
            Text("Phone: $phone", style: GoogleFonts.poppins(fontSize: 13)),
            Text("GR: $grNo, Enroll: $enroll", style: GoogleFonts.poppins(fontSize: 13)),
            Text("Sem: $semester, Stream: $stream", style: GoogleFonts.poppins(fontSize: 13)),
            Text(role, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Club Members", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? Center(
        child: Text("No club members found", style: GoogleFonts.poppins()),
      )
          : ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          if (member is Map<String, dynamic>) {
            return buildMemberCard(member);
          } else {
            return const SizedBox(); // skip if not valid
          }
        },
      ),
    );
  }
}
