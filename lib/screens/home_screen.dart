import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/reminder.dart';
import 'package:calendar_app/screens/create_event_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/utils/date_utils.dart';
import 'package:calendar_app/widgets/date_selector.dart';
import 'package:calendar_app/widgets/event_card.dart';
import 'package:calendar_app/widgets/reminder_card.dart';
import 'package:calendar_app/widgets/section_header.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/providers/reminder_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with greeting and avatar
                      _buildHeader(user?.displayName ?? 'User'),
                      const SizedBox(height: 30),

                      // Date selector
                      SizedBox(
                        height: 80,
                        child: DateSelector(
                          dates: weekDays,
                          selectedDate: selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          showOtherOption: false,
                        ),
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
                    ],
                  ),
                ),
              ),
            ),

            // Bottom bar with set schedule button and logout
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Good Morning,",
              style: AppTheme.headingLarge,
            ),
            Text(
              name,
              style: AppTheme.headingLarge,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            _showProfileOptions(context);
          },
          child: Container(
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
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<Event>>(
      stream: Provider.of<EventProvider>(context).eventsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final events = snapshot.data ?? [];
        final todayEvents = events
            .where((event) => DateTimeUtils.isSameDay(event.date, selectedDate))
            .toList();

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

            return Dismissible(
              key: Key(event.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Event'),
                    content: const Text(
                        'Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                Provider.of<EventProvider>(context, listen: false)
                    .deleteEvent(event.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  time: event.startTime,
                  title: event.title,
                  attendeesCount: event.attendees.length,
                  backgroundColor: categoryColor,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRemindersList() {
    return StreamBuilder<List<Reminder>>(
      stream: Provider.of<ReminderProvider>(context).remindersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final reminders = snapshot.data ?? [];
        final tomorrowDate = DateTime.now().add(const Duration(days: 1));
        final tomorrowReminders = reminders
            .where((reminder) =>
                DateTimeUtils.isSameDay(reminder.date, tomorrowDate))
            .toList();

        if (tomorrowReminders.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No reminders for tomorrow",
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
          itemCount: tomorrowReminders.length,
          itemBuilder: (context, index) {
            final reminder = tomorrowReminders[index];
            return Dismissible(
              key: Key(reminder.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Reminder'),
                    content: const Text(
                        'Are you sure you want to delete this reminder?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                Provider.of<ReminderProvider>(context, listen: false)
                    .deleteReminder(reminder.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: ReminderCard(
                title: reminder.title,
                timeRange: reminder.timeRange,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
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
      ),
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to profile screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}