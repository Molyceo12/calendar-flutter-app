import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/category_selector.dart';
import 'package:calendar_app/widgets/date_selector.dart';
import 'package:calendar_app/widgets/decorative_background.dart';
import 'package:calendar_app/widgets/section_header.dart';
import 'package:calendar_app/widgets/time_range_selector.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Selected date (default to tomorrow)
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

  // Time range
  String startTime = "12.00";
  String endTime = "14.00";

  // Selected category
  String selectedCategory = "Hangout";

  // Note controller
  final TextEditingController noteController = TextEditingController();

  // Category options
  final List<String> categories = [
    "Meeting",
    "Hangout",
    "Cooking",
    "Other",
    "Weekend",
  ];

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
                  const Text(
                    "Let's set the\nschedule easily",
                    style: AppTheme.headingLarge,
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
                      onPressed: () {
                        // Save the event and navigate back
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
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
