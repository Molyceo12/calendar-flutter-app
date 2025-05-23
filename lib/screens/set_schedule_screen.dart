import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/services/notification_service.dart';
import 'package:calendar_app/widgets/color_selector.dart';
import 'package:calendar_app/widgets/custom_button.dart';
import 'package:calendar_app/widgets/date_time_picker_card.dart';
import 'package:calendar_app/widgets/decorative_background.dart';
import 'package:calendar_app/widgets/notification_toggle.dart';
import 'package:calendar_app/widgets/section_header.dart';
import 'package:calendar_app/widgets/styled_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetScheduleScreen extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final Event? event;

  const SetScheduleScreen({
    super.key,
    this.selectedDate,
    this.event,
  });

  @override
  ConsumerState<SetScheduleScreen> createState() => _SetScheduleScreenState();
}

class _SetScheduleScreenState extends ConsumerState<SetScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String _selectedColor = '#EC4899';
  bool _hasNotification = false;
  bool _isLoading = false;

  final List<Map<String, String>> _colorOptions = [
    {'name': 'Pink', 'value': '#EC4899'},
    {'name': 'Purple', 'value': '#7C4DFF'},
    {'name': 'Indigo', 'value': '#6366F1'},
    {'name': 'Orange', 'value': '#F59E0B'},
    {'name': 'Green', 'value': '#10B981'},
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with event data if editing
    if (widget.event != null) {
      _titleController = TextEditingController(text: widget.event!.title);
      _descriptionController =
          TextEditingController(text: widget.event!.description);
      _selectedDate = widget.event!.date;
      _selectedColor = widget.event!.color;
      _hasNotification = widget.event!.hasNotification;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = widget.selectedDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  // Select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context), // Use the current theme
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  // Save event
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (widget.event != null) {
        // Update existing event
        final updatedEvent = widget.event!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          color: _selectedColor,
          hasNotification: _hasNotification,
        );

        await ref
            .read(eventControllerProvider.notifier)
            .updateEvent(updatedEvent);

        // Schedule or cancel notification based on hasNotification
        if (_hasNotification) {
          await NotificationService().scheduleEventNotification(updatedEvent);
          final notificationTime =
              updatedEvent.date.subtract(const Duration(minutes: 30));
          final timeRemaining = notificationTime.difference(DateTime.now());
          debugPrint('Time remaining to notification: $timeRemaining');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Time remaining to notification: $timeRemaining'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else {
          await NotificationService().cancelEventNotification(updatedEvent);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new event
        final newEvent = Event(
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          color: _selectedColor,
          hasNotification: _hasNotification,
          userId: userId,
        );

        await ref.read(eventControllerProvider.notifier).createEvent(newEvent);

        // Schedule or cancel notification based on hasNotification
        if (_hasNotification) {
          await NotificationService().scheduleEventNotification(newEvent);
          final notificationTime =
              newEvent.date.subtract(const Duration(minutes: 30));
          final timeRemaining = notificationTime.difference(DateTime.now());
          debugPrint('Time remaining to notification: $timeRemaining');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Time remaining to notification: $timeRemaining'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else {
          await NotificationService().cancelEventNotification(newEvent);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.event != null ? 'Edit Event' : 'Add Event',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Decorative background
          const DecorativeBackground(),

          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Text(
                    widget.event != null
                        ? "Update your\nschedule"
                        : "Let's set the\nschedule easily",
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  // Title field
                  const SectionHeader(title: "Event Title"),
                  StyledTextFormField(
                    controller: _titleController,
                    hintText: "Enter event title...",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Date and time
                  const SectionHeader(title: "Date & Time"),
                  DateTimePickerCard(
                    selectedDate: _selectedDate,
                    selectDate: _selectDate,
                    selectTime: _selectTime,
                  ),
                  const SizedBox(height: 24),

                  // Description field
                  const SectionHeader(title: "Description"),
                  StyledTextFormField(
                    controller: _descriptionController,
                    hintText: "Add description here...",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Color selection
                  const SectionHeader(title: "Color"),
                  ColorSelector(
                    selectedColor: _selectedColor,
                    colorOptions: _colorOptions,
                    onColorSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Notification toggle
                  NotificationToggle(
                    value: _hasNotification,
                    event: widget.event ??
                        Event(
                          title: '',
                          description: '',
                          date: DateTime.now(),
                          color: '',
                          hasNotification: false,
                          userId: '',
                        ),
                    onChanged: (value) {
                      setState(() {
                        _hasNotification = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  CustomButton(
                    text: widget.event != null ? 'Update Event' : 'Add Event',
                    onPressed: _saveEvent,
                    isLoading: _isLoading,
                  ),
                  // Removed test notification button as requested
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
