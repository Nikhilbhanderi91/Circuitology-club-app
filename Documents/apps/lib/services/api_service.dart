import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // 🔐 Fetch Authenticated User Details
  static Future<Map<String, dynamic>?> fetchUserDetails(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error fetching user details: ${response.body}');
      return null;
    }
  }

  // 📅 Fetch Upcoming + Finished Events
  static Future<Map<String, List<Event>>> fetchEvents() async {
    final response = await http.get(
      Uri.parse("$baseUrl/events"),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      final upcoming = (jsonData['upcomingEvents'] as List)
          .map((e) => Event.fromJson(e))
          .toList();

      final finished = (jsonData['finishedEvents'] as List)
          .map((e) => Event.fromJson(e))
          .toList();

      return {
        'upcoming': upcoming,
        'finished': finished,
      };
    } else {
      throw Exception("Failed to load events");
    }
  }

  // ✅ Register for an Event
  static Future<bool> registerEvent(int eventId, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/events/$eventId/register"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Registration failed: ${response.body}");
      return false;
    }
  }

  // 🏆 Fetch Event Winners
  static Future<List<dynamic>> fetchEventWinners(int eventId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/event/$eventId/winners"),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(" Failed to fetch winners: ${response.body}");
      return [];
    }
  }
}
