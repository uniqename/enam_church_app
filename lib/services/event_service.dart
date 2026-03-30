import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import 'supabase_service.dart';
import 'local_data_service.dart';
import 'package:uuid/uuid.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  static const _kLocalEventsKey = 'local_events_added';

  Future<List<Event>> _getLocalAddedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalEventsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Event.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocalAddedEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kLocalEventsKey, jsonEncode(events.map((e) => e.toSupabase()).toList()));
  }

  Future<List<Event>> getAllEvents() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query(
          'events',
          orderBy: 'date',
          ascending: false,
        );
        if (data.isNotEmpty) {
          return data.map((json) => Event.fromSupabase(json)).toList();
        }
      } catch (e) {
        print('⚠️ Supabase unavailable, using local data: $e');
      }
    }
    // Merge seed events with locally-added events
    final seed = LocalDataService().getEvents();
    final local = await _getLocalAddedEvents();
    final allIds = {for (final e in seed) e.id};
    final extra = local.where((e) => !allIds.contains(e.id)).toList();
    return [...extra, ...seed]..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<Event?> getEventById(String id) async {
    try {
      final data = await _supabase.getById('events', id);
      return data != null ? Event.fromSupabase(data) : null;
    } catch (e) {
      print('❌ Failed to fetch event: $e');
      return null;
    }
  }

  Future<void> addEvent(Event event) async {
    final id = _uuid.v4();
    final withId = Event(
      id: id,
      title: event.title,
      date: event.date,
      time: event.time,
      location: event.location,
      type: event.type,
      status: event.status,
    );
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('events', withId.toSupabase());
        print('✅ Event added: ${event.title}');
        return;
      } catch (e) {
        print('⚠️ Supabase unavailable, saving event locally: $e');
      }
    }
    final events = await _getLocalAddedEvents();
    events.insert(0, withId);
    await _saveLocalAddedEvents(events);
    print('✅ Event saved locally: ${event.title}');
  }

  Future<void> updateEvent(Event event) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.update('events', event.id, event.toSupabase());
        print('✅ Event updated: ${event.title}');
        return;
      } catch (e) {
        print('⚠️ Supabase unavailable for updateEvent: $e');
      }
    }
    final events = await _getLocalAddedEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      events[index] = event;
      await _saveLocalAddedEvents(events);
    }
  }

  Future<void> deleteEvent(String id) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.delete('events', id);
        print('✅ Event deleted: $id');
        return;
      } catch (e) {
        print('⚠️ Supabase unavailable for deleteEvent: $e');
      }
    }
    final events = await _getLocalAddedEvents();
    events.removeWhere((e) => e.id == id);
    await _saveLocalAddedEvents(events);
  }

  Future<List<Event>> getUpcomingEvents() async {
    final all = await getAllEvents();
    final now = DateTime.now();
    return all.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<Event>> getEventsByStatus(String status) async {
    final all = await getAllEvents();
    return all.where((e) => e.status == status).toList();
  }
}
