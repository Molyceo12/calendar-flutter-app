import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/reminder.dart';
import 'package:calendar_app/screens/create_event_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/utils/date_utils.dart';
import 'package:calendar_app/widgets/date_selector.dart';
import 'package:calendar_app/widgets/event_card.dart';
import 'package:calendar_app/widgets/reminder_card.dart';
import 'package:calendar_app/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current date
  DateTime selectedDate = DateTime.now();
  
  // Sample events
  final List<Event> events = [
    Event(
      id: '1',
      title: 'Meeting with Bruce Wayne',
      date: DateTime.now(),
      startTime: '08.00',
      endTime: '09.30',
      category: 'Meeting',
      attendees: ['Bruce Wayne', 'You'],
    ),
    Event(
      id: '2',
      title: 'National awareness test in Wakanda Village',
      date: DateTime.now(),
      startTime: '12.00',
      endTime: '14.00',
      category: 'Other',
      attendees: ['T\'Challa', 'You'],
    ),
  ];
  
  // Sample reminders
  final List<Reminder> reminders = [
    Reminder(
      id: '1',
      title: 'Handle SIM at Klayatan office',
      date: DateTime.now().add(const Duration(days: 1)),
      timeRange: '12.00 - 16.00',
    ),
    Reminder(
      id: '2',
      title: 'Handle SIM at Klayatan office',
      date: DateTime.now().add(const Duration(days: 1)),
      timeRange: '12.00 - 16.00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Generate week days for date selector
    final List<DateTime> weekDays = List.generate(
      7,
      (index) => DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day - 3 + index,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and avatar
                _buildHeader(),
                const SizedBox(height: 30),

                // Date selector
                DateSelector(
                  dates: weekDays,
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  showOtherOption: false,
                ),
                const SizedBox(height: 30),

                // Schedule section
                const SectionHeader(title: "Schedule Today"),
                const SizedBox(height: 16),
                
                // Schedule events
                _buildEventsList(),
                const SizedBox(height: 30),

                // Reminders section
                const SectionHeader(
                  title: "Reminder",
                  subtitle: "Don't forget schedule for tomorrow",
                ),
                const SizedBox(height: 16),
                
                // Reminder cards
                _buildRemindersList(),
                const SizedBox(height: 20),

                // Set schedule button
                _buildSetScheduleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning,",
              style: AppTheme.headingLarge,
            ),
            Text(
              "Shuri",
              style: AppTheme.headingLarge,
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF9A8D4),
              width: 4,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    // Filter events for the selected date
    final todayEvents = events.where(
      (event) => DateTimeUtils.isSameDay(event.date, selectedDate)
    ).toList();
    
    if (todayEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No events scheduled for today",
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todayEvents.length,
      itemBuilder: (context, index) {
        final event = todayEvents[index];
        final categoryColor = AppTheme.categoryColors[event.category] ?? 
            AppTheme.primaryColor;
            
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EventCard(
            time: event.startTime,
            title: event.title,
            attendeesCount: event.attendees.length,
            backgroundColor: categoryColor,
          ),
        );
      },
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ReminderCard(
          title: reminder.title,
          timeRange: reminder.timeRange,
        );
      },
    );
  }

  Widget _buildSetScheduleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
        },
        child: const Text("Set schedule"),
      ),
    );
  }
}
