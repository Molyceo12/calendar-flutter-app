import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String color;
  final bool hasNotification;
  final String userId;

  Event({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    this.color = '#4CAF50', // Default green color
    this.hasNotification = false,
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  // Create a copy with modified fields
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? color,
    bool? hasNotification,
    String? userId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      color: color ?? this.color,
      hasNotification: hasNotification ?? this.hasNotification,
      userId: userId ?? this.userId,
    );
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'color': color,
      'has_notification': hasNotification ? 1 : 0,
      'user_id': userId,
    };
  }

  // Create from Map (SQLite)
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      color: map['color'],
      hasNotification: map['has_notification'] == 1,
      userId: map['user_id'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          date == other.date &&
          color == other.color &&
          hasNotification == other.hasNotification &&
          userId == other.userId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      date.hashCode ^
      color.hashCode ^
      hasNotification.hashCode ^
      userId.hashCode;
}
