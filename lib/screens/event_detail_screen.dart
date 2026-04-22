import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import 'create_event_screen.dart';

// Pantalla de detalle completo de un evento
class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  // Retorna el color según la prioridad
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Retorna el icono según la categoría
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Personal':
        return Icons.person;
      case 'Trabajo':
        return Icons.work;
      case 'Escuela':
        return Icons.school;
      case 'Social':
        return Icons.people;
      case 'Deporte':
        return Icons.sports;
      default:
        return Icons.event;
    }
  }

  // Muestra un diálogo de confirmación para eliminar
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<EventProvider>().deleteEvent(event.id);
              Navigator.pop(ctx); // Cerrar diálogo
              Navigator.pop(context); // Regresar a la lista
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evento eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE dd \'de\' MMMM yyyy', 'es');
    final timeFormat = DateFormat('HH:mm', 'es');

    // Escuchar cambios por si se editó el evento
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        // Buscar la versión más reciente del evento
        final currentEvent = provider.events.firstWhere(
          (e) => e.id == event.id,
          orElse: () => event,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del Evento'),
            centerTitle: true,
            actions: [
              // Botón editar
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar evento',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateEventScreen(eventToEdit: currentEvent),
                    ),
                  );
                },
              ),
              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Eliminar evento',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con título y estado
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Icon(
                                _categoryIcon(currentEvent.category),
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                currentEvent.title,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: currentEvent.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Badges de categoría y prioridad
                        Row(
                          children: [
                            Chip(
                              avatar: Icon(
                                _categoryIcon(currentEvent.category),
                                size: 18,
                              ),
                              label: Text(currentEvent.category),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              avatar: Icon(
                                Icons.flag,
                                size: 18,
                                color: _priorityColor(currentEvent.priority),
                              ),
                              label: Text('Prioridad ${currentEvent.priority}'),
                            ),
                          ],
                        ),
                        if (currentEvent.isCompleted) ...[
                          const SizedBox(height: 8),
                          const Chip(
                            avatar: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            label: Text('Completado'),
                            backgroundColor: Color(0xFFE8F5E9),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sección de fecha y hora
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha y Hora',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(dateFormat.format(currentEvent.dateTime)),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            '${timeFormat.format(currentEvent.dateTime)} hrs',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (currentEvent.isPast && !currentEvent.isToday)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Este evento ya pasó',
                                  style: TextStyle(color: Colors.orange[700]),
                                ),
                              ],
                            ),
                          ),
                        if (currentEvent.isToday)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.today,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '¡Este evento es hoy!',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sección de descripción
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          currentEvent.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de marcar como completado / no completado
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      provider.toggleCompleted(currentEvent.id);
                    },
                    icon: Icon(
                      currentEvent.isCompleted
                          ? Icons.undo
                          : Icons.check_circle,
                    ),
                    label: Text(
                      currentEvent.isCompleted
                          ? 'Marcar como pendiente'
                          : 'Marcar como completado',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: currentEvent.isCompleted
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
