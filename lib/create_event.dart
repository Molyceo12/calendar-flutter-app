import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Category options with colors
  final List<Map<String, dynamic>> categories = [
    {"name": "Meeting", "color": const Color(0xFFFFA000)},
    {"name": "Hangout", "color": const Color(0xFF9C27B0)},
    {"name": "Cooking", "color": const Color(0xFFE53935)},
    {"name": "Other", "color": const Color(0xFF616161)},
    {"name": "Weekend", "color": const Color(0xFF2E7D32)},
    {"name": "Add", "color": Colors.white, "isAdd": true},
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
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB2DFDB).withAlpha((0.7 * 255).toInt()),
                    const Color(0xFFF48FB1).withAlpha((0.7 * 255).toInt()),
                    const Color(0xFFB39DDB).withAlpha((0.7 * 255).toInt()),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    "Let's set the\nschedule easily",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Date selection
                  const Text(
                    "Select the date",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date options
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...dateOptions.map((date) {
                          final bool isSelected =
                              date.day == selectedDate.day &&
                                  date.month == selectedDate.month &&
                                  date.year == selectedDate.year;

                          final String dayNum = date.day.toString();
                          final String weekday =
                              DateFormat('E').format(date).substring(0, 2);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF7C4DFF)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    dayNum,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    weekday,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                        // Other date option
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  "Other",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Time selection
                  const Text(
                    "Select time",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time range selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "From",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime:
                                      const TimeOfDay(hour: 12, minute: 0),
                                );

                                if (pickedTime != null) {
                                  setState(() {
                                    startTime =
                                        "${pickedTime.hour}.${pickedTime.minute.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                              child: Text(
                                startTime,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          size: 32,
                          color: Color(0xFF64748B),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "To",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime:
                                      const TimeOfDay(hour: 14, minute: 0),
                                );

                                if (pickedTime != null) {
                                  setState(() {
                                    endTime =
                                        "${pickedTime.hour}.${pickedTime.minute.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                              child: Text(
                                endTime,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category selection
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category options
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final bool isSelected =
                          category["name"] == selectedCategory;
                      final bool isAdd = category["isAdd"] == true;

                      return GestureDetector(
                        onTap: () {
                          if (!isAdd) {
                            setState(() {
                              selectedCategory = category["name"];
                            });
                          } else {
                            // Handle add new category
                            // This would typically show a dialog to create a new category
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isAdd
                                ? Colors.white
                                : Colors.white.withAlpha((0.2 * 255).toInt()),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAdd
                                  ? const Color(0xFF7C4DFF)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: category["color"],
                                  shape: BoxShape.circle,
                                  border: isAdd
                                      ? Border.all(
                                          color: const Color(0xFF7C4DFF),
                                          width: 1)
                                      : null,
                                ),
                                child: isAdd
                                    ? const Icon(Icons.add,
                                        size: 16, color: Color(0xFF7C4DFF))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category["name"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Note section
                  const Text(
                    "Note",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note text field
                  Container(
                    height: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: noteController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add notes here...",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
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