class Event {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String category;
  final String note;
  final List<String> attendees;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.note = '',
    this.attendees = const [],
  });

  // Create a copy of the event with updated fields
  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? category,
    String? note,
    List<String>? attendees,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      note: note ?? this.note,
      attendees: attendees ?? this.attendees,
    );
  }
}
