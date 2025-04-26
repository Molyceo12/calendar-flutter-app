import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/category_selector.dart';
import 'package:calendar_app/widgets/date_selector.dart';
import 'package:calendar_app/widgets/decorative_background.dart';
import 'package:calendar_app/widgets/section_header.dart';
import 'package:calendar_app/widgets/time_range_selector.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:uuid/uuid.dart';

class CreateEventScreen extends StatefulWidget {
  final Event? eventToEdit;

  const CreateEventScreen({Key? key, this.eventToEdit}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late DateTime selectedDate;
  late String startTime;
  late String endTime;
  late String selectedCategory;
  late TextEditingController titleController;
  late TextEditingController noteController;
  bool isEditing = false;
  bool isSaving = false;

  // Category options
  final List<String> categories = [
    "Meeting",
    "Hangout",
    "Cooking",
    "Other",
    "Weekend",
  ];

  @override
  void initState() {
    super.initState();

    // Check if we're editing an existing event
    if (widget.eventToEdit != null) {
      isEditing = true;
      selectedDate = widget.eventToEdit!.date;
      startTime = widget.eventToEdit!.startTime;
      endTime = widget.eventToEdit!.endTime;
      selectedCategory = widget.eventToEdit!.category;
      titleController = TextEditingController(text: widget.eventToEdit!.title);
      noteController = TextEditingController(text: widget.eventToEdit!.note);
    } else {
      // Default values for new event
      selectedDate = DateTime.now().add(const Duration(days: 1));
      startTime = "12.00";
      endTime = "14.00";
      selectedCategory = "Hangout";
      titleController = TextEditingController();
      noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for the event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      if (isEditing) {
        // Update existing event
        final updatedEvent = widget.eventToEdit!.copyWith(
          title: titleController.text,
          date: selectedDate,
          startTime: startTime,
          endTime: endTime,
          category: selectedCategory,
          note: noteController.text,
        );

        await eventProvider.updateEvent(updatedEvent);
      } else {
        // Create new event
        final newEvent = Event(
          id: const Uuid().v4(),
          title: titleController.text,
          date: selectedDate,
          startTime: startTime,
          endTime: endTime,
          category: selectedCategory,
          note: noteController.text,
          attendees: [],
        );

        await eventProvider.addEvent(newEvent);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate date options (today, tomorrow, day after tomorrow)
    final List<DateTime> dateOptions = [
      DateTime.now(),
      DateTime.now().add(const Duration(days: 1)),
      DateTime.now().add(const Duration(days: 2)),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Event" : "Create Event",
          style: const TextStyle(color: AppTheme.textPrimaryColor),
        ),
      ),
      body: Stack(
        children: [
          // Decorative background shape
          const DecorativeBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    isEditing
                        ? "Update your\nschedule"
                        : "Let's set the\nschedule easily",
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: 32),

                  // Title input
                  const SectionHeader(title: "Event Title"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter event title...",
                        hintStyle: TextStyle(color: AppTheme.textTertiaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Date selection
                  const SectionHeader(title: "Select the date"),
                  const SizedBox(height: 16),

                  // Date options
                  SizedBox(
                    height: 120,
                    child: DateSelector(
                      dates: dateOptions,
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Time selection
                  const SectionHeader(title: "Select time"),
                  const SizedBox(height: 16),

                  // Time range selector
                  TimeRangeSelector(
                    startTime: startTime,
                    endTime: endTime,
                    onStartTimeChanged: (time) {
                      setState(() {
                        startTime = time;
                      });
                    },
                    onEndTimeChanged: (time) {
                      setState(() {
                        endTime = time;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Category selection
                  const SectionHeader(title: "Category"),
                  const SizedBox(height: 16),

                  // Category options
                  CategorySelector(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    onAddCategory: () {
                      // Show dialog to add new category
                      _showAddCategoryDialog();
                    },
                  ),
                  const SizedBox(height: 32),

                  // Note section
                  const SectionHeader(title: "Note"),
                  const SizedBox(height: 16),

                  // Note text field
                  Container(
                    height: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: noteController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add notes here...",
                        hintStyle: TextStyle(color: AppTheme.textTertiaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveEvent,
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? "Update" : "Save"),
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

  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            hintText: "Category name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  categories.add(categoryController.text);
                  selectedCategory = categoryController.text;
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
