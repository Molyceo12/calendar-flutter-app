import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/decorative_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SetScheduleScreen extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final Event? event;

  const SetScheduleScreen({
    Key? key,
    this.selectedDate,
    this.event,
  }) : super(key: key);

  @override
  ConsumerState<SetScheduleScreen> createState() => _SetScheduleScreenState();
}

class _SetScheduleScreenState extends ConsumerState<SetScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String _selectedColor = '#EC4899'; // Default to primary color
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
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
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
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.event != null ? 'Edit Event' : 'Add Event',
          style: const TextStyle(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
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
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: 32),

                  // Title field
                  const Text(
                    "Event Title",
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter event title...",
                        hintStyle: TextStyle(color: AppTheme.textTertiaryColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date and time
                  const Text(
                    "Date & Time",
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: AppTheme.primaryColor),
                            title: Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(_selectedDate),
                              style: AppTheme.bodyMedium,
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _selectDate(context),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.access_time,
                                color: AppTheme.primaryColor),
                            title: Text(
                              DateFormat('h:mm a').format(_selectedDate),
                              style: AppTheme.bodyMedium,
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _selectTime(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description field
                  const Text(
                    "Description",
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add description here...",
                        hintStyle: TextStyle(color: AppTheme.textTertiaryColor),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Color selection
                  const Text(
                    "Color",
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color['value']!;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color['value']!.substring(1),
                                    radix: 16) +
                                0xFF000000),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(int.parse(
                                              color['value']!.substring(1),
                                              radix: 16) +
                                          0x33000000),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Notification switch
                  SwitchListTile(
                    title: const Text(
                      'Reminder Notification',
                      style: AppTheme.bodyLarge,
                    ),
                    subtitle: const Text(
                      '30 minutes before event',
                      style: AppTheme.bodySmall,
                    ),
                    value: _hasNotification,
                    activeColor: AppTheme.primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onChanged: (value) {
                      setState(() {
                        _hasNotification = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEvent,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(widget.event != null
                              ? 'Update Event'
                              : 'Save Event'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
