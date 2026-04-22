import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

// Servicio de persistencia local para almacenar eventos usando SharedPreferences
class StorageService {
  static const String _eventsKey = 'stored_events';

  // Obtiene todos los eventos almacenados localmente
  Future<List<Event>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? eventsJson = prefs.getStringList(_eventsKey);

    if (eventsJson == null || eventsJson.isEmpty) {
      return [];
    }

    return eventsJson
        .map((jsonStr) => Event.fromJson(json.decode(jsonStr)))
        .toList();
  }

  // Guarda la lista completa de eventos
  Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> eventsJson = events
        .map((event) => json.encode(event.toJson()))
        .toList();
    await prefs.setStringList(_eventsKey, eventsJson);
  }

  // Agrega un nuevo evento
  Future<void> addEvent(Event event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  // Actualiza un evento existente por su ID
  Future<void> updateEvent(Event updatedEvent) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent;
      await saveEvents(events);
    }
  }

  // Elimina un evento por su ID
  Future<void> deleteEvent(String eventId) async {
    final events = await getEvents();
    events.removeWhere((e) => e.id == eventId);
    await saveEvents(events);
  }

  // Alterna el estado de completado de un evento
  Future<void> toggleCompleted(String eventId) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      events[index] = events[index].copyWith(
        isCompleted: !events[index].isCompleted,
      );
      await saveEvents(events);
    }
  }
}
