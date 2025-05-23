import 'package:calendar_app/controllers/event_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/providers/auth_provider.dart';

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Events for month provider
final eventsForMonthProvider =
    FutureProvider.family<List<Event>, DateTime>((ref, month) async {
  final dbService = ref.watch(databaseServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return [];
  }

  return await dbService.getEventsForMonth(month, userId);
});

// Event controller provider
final eventControllerProvider =
    StateNotifierProvider<EventController, AsyncValue<void>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return EventController(dbService, ref);
});
