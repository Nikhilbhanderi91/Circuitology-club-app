import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final fullName = "${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 30, thickness: 1.2),

                _buildInfoRow("Email", userData['email']),
                _buildInfoRow("Phone", userData['phone_no']),
                _buildInfoRow("GR No", userData['gr_no']),
                _buildInfoRow("Enrollment No", userData['enrollment_no']),
                _buildInfoRow("Semester", userData['semester']?.toString()),
                _buildInfoRow("Stream", userData['stream']),
                _buildInfoRow("Role", userData['is_admin'] == true ? "Admin" : "Member"),
                _buildInfoRow("Joined At", _formatDate(userData['created_at'])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (_) {
      return date;
    }
  }
}
