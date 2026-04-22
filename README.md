# Eventos App - Gestión de Eventos y Recordatorios

**Proyecto Final - Cómputo Móvil**  
**Cuatrimestre:** 8° | Ciclo: Enero-Abril 2026  
**Proyecto 7:** App de Eventos

## Descripción

Aplicación móvil desarrollada en Flutter para la gestión de eventos personales y recordatorios. Permite crear, editar, eliminar y organizar eventos con fecha, hora, categoría y prioridad. Además, consume la API REST pública de [Nager.Date](https://date.nager.at/) para consultar días festivos de distintos países e importarlos como eventos personales.

## Funcionalidades principales

- **CRUD completo de eventos:** Crear, leer, editar y eliminar eventos personales
- **Fecha y hora:** Selectores nativos de fecha (DatePicker) y hora (TimePicker)
- **Listado ordenado:** Eventos ordenados cronológicamente con filtros (Todos, Hoy, Próximos, Pasados)
- **Categorías y prioridad:** Clasificación por categoría (Personal, Trabajo, Escuela, Social, Deporte, Otro) y prioridad (Alta, Media, Baja)
- **Búsqueda de eventos:** Búsqueda por título, descripción o categoría con validación de formulario
- **Días festivos (API REST):** Consulta de días festivos por país desde la API Nager.Date con opción de importarlos
- **Persistencia local:** Almacenamiento de eventos con SharedPreferences
- **Marcar como completado:** Toggle para marcar/desmarcar eventos completados
- **Pull-to-refresh:** Actualización del listado mediante gesto de arrastre
- **Manejo de estados:** Indicadores de carga, mensajes de error con reintento y estados vacíos

## Arquitectura del proyecto

```
lib/
├── main.dart                        # Punto de entrada con Provider y tema
├── models/
│   ├── event.dart                   # Modelo de evento con fromJson/toJson
│   └── holiday.dart                 # Modelo de día festivo (API)
├── providers/
│   └── event_provider.dart          # Manejo de estado con Provider (MVVM)
├── services/
│   ├── api_service.dart             # Consumo de API REST (Nager.Date)
│   └── storage_service.dart         # Persistencia local (SharedPreferences)
├── screens/
│   ├── home_screen.dart             # Pantalla principal con filtros y listado
│   ├── create_event_screen.dart     # Formulario crear/editar evento
│   ├── event_detail_screen.dart     # Detalle completo del evento
│   ├── holidays_screen.dart         # Días festivos desde API
│   └── search_screen.dart           # Búsqueda de eventos
└── widgets/
    ├── event_card.dart              # Tarjeta reutilizable de evento
    ├── loading_widget.dart          # Indicador de carga reutilizable
    └── error_widget.dart            # Widget de error con reintentar
```

**Separación de capas:**
- **UI (screens/widgets):** Interfaz gráfica y presentación
- **Lógica (providers):** Manejo de estado con ChangeNotifier + Provider
- **Datos (services/models):** Consumo de API y persistencia local

## Tecnologías y paquetes

| Paquete | Versión | Uso |
|---|---|---|
| `provider` | ^6.1.2 | Manejo de estado (MVVM) |
| `http` | ^1.2.1 | Consumo de API REST |
| `shared_preferences` | ^2.3.0 | Persistencia local de eventos |
| `intl` | ^0.20.2 | Formateo de fechas en español |

## API utilizada

**Nager.Date** - `https://date.nager.at/api/v3/`

Endpoints consumidos:
- `GET /PublicHolidays/{year}/{countryCode}` - Días festivos por año y país
- `GET /AvailableCountries` - Países disponibles

## Instrucciones de ejecución

### Requisitos previos
- Flutter SDK (>=3.11.0)
- Dart SDK
- Conexión a internet (para consultar días festivos)

### Pasos
```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>

# 2. Navegar a la carpeta del proyecto
cd eventos_app

# 3. Instalar dependencias
flutter pub get

# 4. Ejecutar la aplicación
flutter run

# 5. Para generar el APK
flutter build apk --debug
```
