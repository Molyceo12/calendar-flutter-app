import 'package:flutter/material.dart';

/// Utility function to parse a hex color string like "#RRGGBB" or "RRGGBB" to a Color object.
/// Adds full opacity if alpha is not specified.
Color parseHexColor(String hexColor) {
  String hex = hexColor.toUpperCase().replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF$hex"; // add alpha if missing
  }
  if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  throw FormatException("Invalid hex color format");
}

enum EventCategory {
  meeting,
  hangout,
  cooking,
  other,
  weekend,
}

Map<EventCategory, Color> categoryColors = {
  EventCategory.meeting: Color(0xFFFFA000),
  EventCategory.hangout: Color(0xFF9C27B0),
  EventCategory.cooking: Color(0xFFE53935),
  EventCategory.other: Color(0xFF616161),
  EventCategory.weekend: Color(0xFF2E7D32),
};

String categoryToString(EventCategory category) {
  switch (category) {
    case EventCategory.meeting:
      return "Meeting";
    case EventCategory.hangout:
      return "Hangout";
    case EventCategory.cooking:
      return "Cooking";
    case EventCategory.other:
      return "Other";
    case EventCategory.weekend:
      return "Weekend";
  }
}

EventCategory stringToCategory(String value) {
  switch (value) {
    case "Meeting":
      return EventCategory.meeting;
    case "Hangout":
      return EventCategory.hangout;
    case "Cooking":
      return EventCategory.cooking;
    case "Other":
      return EventCategory.other;
    case "Weekend":
      return EventCategory.weekend;
    default:
      return EventCategory.other;
  }
}
