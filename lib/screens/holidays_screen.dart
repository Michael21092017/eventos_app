import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

// Pantalla que muestra los días festivos obtenidos de la API REST
class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  // Países disponibles para seleccionar
  static const List<Map<String, String>> _countries = [
    {'code': 'MX', 'name': 'México'},
    {'code': 'US', 'name': 'Estados Unidos'},
    {'code': 'ES', 'name': 'España'},
    {'code': 'AR', 'name': 'Argentina'},
    {'code': 'CO', 'name': 'Colombia'},
    {'code': 'CL', 'name': 'Chile'},
    {'code': 'PE', 'name': 'Perú'},
    {'code': 'BR', 'name': 'Brasil'},
  ];

  @override
  void initState() {
    super.initState();
    // Cargar días festivos al iniciar
    context.read<EventProvider>().loadHolidays();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(title: const Text('Días Festivos'), centerTitle: true),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Selector de país
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'País',
                    prefixIcon: Icon(Icons.public),
                    border: OutlineInputBorder(),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country['code'],
                      child: Text(country['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.loadHolidays(countryCode: value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Contenido principal
              Expanded(child: _buildContent(provider, dateFormat)),
            ],
          );
        },
      ),
    );
  }

  // Construye el contenido según el estado
  Widget _buildContent(EventProvider provider, DateFormat dateFormat) {
    if (provider.isLoadingHolidays) {
      return const LoadingWidget(message: 'Cargando días festivos...');
    }

    if (provider.holidaysError.isNotEmpty) {
      return ErrorDisplayWidget(
        message: provider.holidaysError,
        onRetry: () => provider.loadHolidays(),
      );
    }

    if (provider.holidays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron días festivos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: provider.holidays.length,
      itemBuilder: (context, index) {
        final holiday = provider.holidays[index];
        final isImported = provider.isHolidayImported(holiday);
        final isPast = holiday.isPast;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPast
                  ? Colors.grey[200]
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.celebration,
                color: isPast
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              holiday.localName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPast ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(holiday.dateTime),
                  style: TextStyle(color: isPast ? Colors.grey : null),
                ),
                if (holiday.localName != holiday.name)
                  Text(
                    holiday.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            trailing: isImported
                ? const Chip(
                    label: Text('Importado', style: TextStyle(fontSize: 11)),
                    avatar: Icon(Icons.check, size: 16, color: Colors.green),
                    visualDensity: VisualDensity.compact,
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      provider.importHolidayAsEvent(holiday);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${holiday.localName} agregado a tus eventos',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Importar'),
                  ),
          ),
        );
      },
    );
  }
}
