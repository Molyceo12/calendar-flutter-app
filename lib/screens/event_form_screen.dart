import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';

class EventFormScreen extends StatelessWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  Widget build(BuildContext context) {
    final isEditing = event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Add Event'),
      ),
      body: Center(
        child: Text(
          isEditing
              ? 'Edit form for event: ${event!.title}'
              : 'Form to add a new event',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
