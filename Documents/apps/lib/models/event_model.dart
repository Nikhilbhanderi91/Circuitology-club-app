class Event {
  final int eventId;
  final String eventName;
  final String eventDescription;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventDescription,
  });

  // ✅ Factory constructor to convert JSON to Event object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      eventName: json['event_name'],
      eventDescription: json['event_description'],
    );
  }

  // ✅ Optional: Convert Event object back to JSON (for sending data)
  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'event_description': eventDescription,
    };
  }
}
