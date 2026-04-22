// Modelo de evento del usuario
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String category;
  final String priority;
  final bool isCompleted;

  // Categorías disponibles para los eventos
  static const List<String> categories = [
    'Personal',
    'Trabajo',
    'Escuela',
    'Social',
    'Deporte',
    'Otro',
  ];

  // Niveles de prioridad disponibles
  static const List<String> priorities = ['Alta', 'Media', 'Baja'];

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.category,
    required this.priority,
    this.isCompleted = false,
  });

  // Constructor factory para crear un Event desde JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      category: json['category'] as String,
      priority: json['priority'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  // Convierte el evento a un mapa JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  // Crea una copia del evento con campos modificados
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? category,
    String? priority,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Verifica si el evento ya pasó
  bool get isPast => dateTime.isBefore(DateTime.now());

  // Verifica si el evento es hoy
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // Verifica si el evento es en los próximos 7 días
  bool get isUpcoming {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    return dateTime.isAfter(now) && dateTime.isBefore(sevenDaysLater);
  }
}
