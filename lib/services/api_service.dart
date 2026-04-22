import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holiday.dart';

// Servicio para consumir la API REST de Nager.Date (días festivos)
class ApiService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  // Obtiene los días festivos de un país para un año específico
  static Future<List<Holiday>> getHolidays(int year, String countryCode) async {
    final url = Uri.parse('$_baseUrl/PublicHolidays/$year/$countryCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Holiday.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener días festivos: ${response.statusCode}');
    }
  }

  // Obtiene los países disponibles en la API
  static Future<List<Map<String, String>>> getAvailableCountries() async {
    final url = Uri.parse('$_baseUrl/AvailableCountries');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map(
            (json) => {
              'countryCode': json['countryCode'] as String,
              'name': json['name'] as String,
            },
          )
          .toList();
    } else {
      throw Exception('Error al obtener países: ${response.statusCode}');
    }
  }

  // Obtiene los días festivos del próximo año para un país
  static Future<List<Holiday>> getNextYearHolidays(String countryCode) async {
    final nextYear = DateTime.now().year + 1;
    return getHolidays(nextYear, countryCode);
  }
}
