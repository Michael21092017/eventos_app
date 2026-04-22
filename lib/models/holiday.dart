// Modelo de día festivo obtenido de la API Nager.Date
class Holiday {
  final String date;
  final String localName;
  final String name;
  final String countryCode;
  final List<String> types;

  const Holiday({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    required this.types,
  });

  // Constructor factory para crear un Holiday desde JSON de la API
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: json['date'] as String,
      localName: json['localName'] as String,
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  // Obtiene la fecha como objeto DateTime
  DateTime get dateTime => DateTime.parse(date);

  // Verifica si el día festivo ya pasó
  bool get isPast => dateTime.isBefore(DateTime.now());
}
