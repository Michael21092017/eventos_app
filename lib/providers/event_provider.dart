import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Provider central que maneja el estado de toda la aplicación
class EventProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  // Estado de eventos locales
  List<Event> _events = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Estado de días festivos (API)
  List<Holiday> _holidays = [];
  bool _isLoadingHolidays = false;
  String _holidaysError = '';
  String _selectedCountry = 'MX';

  // Estado de búsqueda
  List<Event> _searchResults = [];
  bool _isSearching = false;
  String _searchError = '';

  // Filtro activo en la pantalla principal
  String _activeFilter = 'Todos';

  // Getters públicos
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<Holiday> get holidays => _holidays;
  bool get isLoadingHolidays => _isLoadingHolidays;
  String get holidaysError => _holidaysError;
  String get selectedCountry => _selectedCountry;

  List<Event> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchError => _searchError;

  String get activeFilter => _activeFilter;

  // Retorna la lista de eventos filtrada según el filtro activo, ordenada por fecha
  List<Event> get filteredEvents {
    List<Event> filtered;
    switch (_activeFilter) {
      case 'Hoy':
        filtered = _events.where((e) => e.isToday).toList();
        break;
      case 'Próximos':
        filtered = _events.where((e) => e.isUpcoming && !e.isToday).toList();
        break;
      case 'Pasados':
        filtered = _events.where((e) => e.isPast && !e.isToday).toList();
        break;
      default:
        filtered = List.from(_events);
    }
    // Ordenar por fecha ascendente
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  // Cuenta de eventos por filtro
  int get todayCount => _events.where((e) => e.isToday).length;
  int get upcomingCount =>
      _events.where((e) => e.isUpcoming && !e.isToday).length;
  int get pastCount => _events.where((e) => e.isPast && !e.isToday).length;

  // Carga todos los eventos desde almacenamiento local
  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _events = await _storageService.getEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // Agrega un nuevo evento
  Future<void> addEvent(Event event) async {
    try {
      await _storageService.addEvent(event);
      _events = await _storageService.getEvents();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al agregar evento: ${e.toString()}';
      notifyListeners();
    }
  }

  // Actualiza un evento existente
  Future<void> updateEvent(Event event) async {
    try {
      await _storageService.updateEvent(event);
      _events = await _storageService.getEvents();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al actualizar evento: ${e.toString()}';
      notifyListeners();
    }
  }

  // Elimina un evento por su ID
  Future<void> deleteEvent(String eventId) async {
    try {
      await _storageService.deleteEvent(eventId);
      _events = await _storageService.getEvents();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al eliminar evento: ${e.toString()}';
      notifyListeners();
    }
  }

  // Alterna el estado completado de un evento
  Future<void> toggleCompleted(String eventId) async {
    try {
      await _storageService.toggleCompleted(eventId);
      _events = await _storageService.getEvents();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al actualizar estado: ${e.toString()}';
      notifyListeners();
    }
  }

  // Cambia el filtro activo
  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // Busca eventos por texto en título o descripción
  void searchEvents(String query) {
    _isSearching = true;
    _searchError = '';
    notifyListeners();

    try {
      final lowerQuery = query.toLowerCase();
      _searchResults = _events.where((event) {
        return event.title.toLowerCase().contains(lowerQuery) ||
            event.description.toLowerCase().contains(lowerQuery) ||
            event.category.toLowerCase().contains(lowerQuery);
      }).toList();
      _searchResults.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      _searchError = 'Error al buscar: ${e.toString()}';
      notifyListeners();
    }
  }

  // Limpia los resultados de búsqueda
  void clearSearch() {
    _searchResults = [];
    _searchError = '';
    notifyListeners();
  }

  // Carga los días festivos desde la API
  Future<void> loadHolidays({String? countryCode}) async {
    _isLoadingHolidays = true;
    _holidaysError = '';
    if (countryCode != null) _selectedCountry = countryCode;
    notifyListeners();

    try {
      final year = DateTime.now().year;
      _holidays = await ApiService.getHolidays(year, _selectedCountry);
      _isLoadingHolidays = false;
      notifyListeners();
    } catch (e) {
      _isLoadingHolidays = false;
      _holidaysError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // Importa un día festivo como evento personal
  Future<void> importHolidayAsEvent(Holiday holiday) async {
    final event = Event(
      id: 'holiday_${holiday.date}_${holiday.countryCode}',
      title: holiday.localName,
      description: '${holiday.name} - Día festivo (${holiday.countryCode})',
      dateTime: holiday.dateTime,
      category: 'Social',
      priority: 'Media',
      isCompleted: false,
    );

    // Verificar si ya existe un evento con este ID
    final exists = _events.any((e) => e.id == event.id);
    if (!exists) {
      await addEvent(event);
    }
  }

  // Verifica si un día festivo ya fue importado
  bool isHolidayImported(Holiday holiday) {
    final id = 'holiday_${holiday.date}_${holiday.countryCode}';
    return _events.any((e) => e.id == id);
  }
}
