import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'holidays_screen.dart';
import 'search_screen.dart';

// Pantalla principal con listado de eventos y filtros
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filtros disponibles
  final List<String> _filters = ['Todos', 'Hoy', 'Próximos', 'Pasados'];

  @override
  void initState() {
    super.initState();
    // Cargar eventos al iniciar la pantalla
    context.read<EventProvider>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos'),
        centerTitle: true,
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          // Botón de días festivos
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'Días festivos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HolidaysScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          // Estado de carga
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Cargando eventos...');
          }

          // Estado de error
          if (provider.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: provider.errorMessage,
              onRetry: () => provider.loadEvents(),
            );
          }

          return Column(
            children: [
              // Chips de filtros
              _buildFilterChips(provider),
              // Contador de eventos
              _buildEventCounter(provider),
              // Lista de eventos
              Expanded(child: _buildEventList(provider)),
            ],
          );
        },
      ),
      // Botón flotante para crear evento
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Evento'),
      ),
    );
  }

  // Construye la fila de chips para filtrar eventos
  Widget _buildFilterChips(EventProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = provider.activeFilter == filter;
            String label = filter;

            // Agregar conteo al label
            switch (filter) {
              case 'Hoy':
                label = 'Hoy (${provider.todayCount})';
                break;
              case 'Próximos':
                label = 'Próximos (${provider.upcomingCount})';
                break;
              case 'Pasados':
                label = 'Pasados (${provider.pastCount})';
                break;
              case 'Todos':
                label = 'Todos (${provider.events.length})';
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) provider.setFilter(filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Muestra un contador descriptivo de eventos visibles
  Widget _buildEventCounter(EventProvider provider) {
    final count = provider.filteredEvents.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '$count evento${count != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Construye la lista de eventos con pull-to-refresh
  Widget _buildEventList(EventProvider provider) {
    final events = provider.filteredEvents;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay eventos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para crear uno',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            event: event,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
            onToggleCompleted: () {
              provider.toggleCompleted(event.id);
            },
          );
        },
      ),
    );
  }
}
