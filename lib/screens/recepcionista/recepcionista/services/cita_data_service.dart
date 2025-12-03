import '../models/cita_models.dart';
import '../../../login/services/database_service.dart';

// DATOS DE EJEMPLO - Calendario médico profesional con alta disponibilidad
// Ahora integrado con Firestore para Áreas y Doctores
class CitaDataService {
  // ============================================
  // ÁREAS MÉDICAS
  // ============================================
  static Future<List<Area>> getAreas() async {
    try {
      final db = DatabaseService();
      // Usamos getHospitalAreas que ya existe en DatabaseService
      // Retorna List<Map<String, dynamic>>
      final areasData = await db.getHospitalAreas();
      
      return areasData.map((data) {
        return Area(
          id: data['id'] ?? '',
          nombre: data['nombre'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching areas: $e');
      return [];
    }
  }

  // ============================================
  // DOCTORES CON ALTA DISPONIBILIDAD
  // ============================================
  static Future<List<Doctor>> getDoctores() async {
    try {
      final db = DatabaseService();
      // Usamos getPersonnelList y filtramos por 'medico'
      final personal = await db.getPersonnelList();
      
      return personal
          .where((p) => (p['tipo'] ?? '').toString().toLowerCase() == 'medico')
          .map((data) {
            return Doctor(
              id: data['id'] ?? '',
              nombre: data['nombre'] ?? '',
              areaId: data['area'] ?? '', // Asumiendo que 'area' en personal coincide con ID de area
              disponibilidad: _generarDisponibilidadAnual(
                esEspecialista: true, // Por defecto para demo
                altaDemanda: false,
              ),
            );
          }).toList();
    } catch (e) {
      print('❌ Error fetching doctors: $e');
      return [];
    }
  }

  static Future<List<Doctor>> getDoctoresByArea(String areaId) async {
    final doctores = await getDoctores();
    // Filtrar por nombre de área (ya que en personal guardamos el nombre del área, no el ID)
    // O si guardamos el ID, comparar ID.
    // En DatabaseService.addPersonnel guardamos 'area': area (que viene de un dropdown de nombres)
    // Así que aquí comparamos con el nombre o ID.
    // En AgendarCitaPage, areaId viene de getAreas().
    // Si getAreas devuelve IDs que son nombres (ej 'Cardiología'), entonces funciona.
    // Si devuelve IDs numéricos, necesitamos mapear.
    // En DatabaseService.getHospitalAreas, el ID es el doc.id.
    // En Firestore 'areas' collection, los docs suelen ser IDs auto-generados o nombres.
    // Asumiremos que coinciden o haremos una comparación flexible.
    
    return doctores.where((doc) => 
      doc.areaId.toLowerCase() == areaId.toLowerCase() || 
      doc.areaId.toLowerCase().contains(areaId.toLowerCase())
    ).toList();
  }

  // Obtener disponibilidad de un doctor para un mes específico
  static Future<Map<DateTime, DisponibilidadDia>> getDisponibilidadMes(
    String doctorId,
    int year,
    int month,
  ) async {
    // TODO: En Firebase, esto sería una query a /disponibilidad/{doctorId}/{year}/{month}

    final doctores = await getDoctores();
    final doctor = doctores.firstWhere((d) => d.id == doctorId);
    final Map<DateTime, DisponibilidadDia> disponibilidad = {};

    // Generar disponibilidad para TODOS los días que tienen horarios definidos
    doctor.disponibilidad.forEach((fechaStr, horas) {
      try {
        final fecha = DateTime.parse(fechaStr);

        // Solo incluir fechas del mes solicitado
        if (fecha.year == year && fecha.month == month) {
          final citasTotal = 8;
          final citasDisponibles = horas.length;
          final citasOcupadas = citasTotal - citasDisponibles;

          disponibilidad[fecha] = DisponibilidadDia(
            fecha: fecha,
            citasDisponibles: citasDisponibles,
            citasOcupadas: citasOcupadas,
            citasTotal: citasTotal,
          );
        }
      } catch (e) {
        print('Error parsing date $fechaStr: $e');
      }
    });

    return disponibilidad;
  }

  // Obtener horas disponibles para un doctor en una fecha específica
  static Future<List<String>> getHorasDisponibles(String doctorId, DateTime fecha) async {
    // TODO: En Firebase: /disponibilidad/{doctorId}/{fecha}

    final doctores = await getDoctores();
    final doctor = doctores.firstWhere((d) => d.id == doctorId);
    final fechaStr =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

    return doctor.disponibilidad[fechaStr] ?? [];
  }

  // ============================================
  // FIREBASE INTEGRATION PLACEHOLDER
  // ============================================
  /*
  static Future<List<Area>> getAreasFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('areas')
        .get();
    
    return snapshot.docs
        .map((doc) => Area.fromJson(doc.data()))
        .toList();
  }

  static Future<List<Doctor>> getDoctoresByAreaFromFirebase(String areaId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctores')
        .where('areaId', isEqualTo: areaId)
        .get();
    
    return snapshot.docs
        .map((doc) => Doctor.fromJson(doc.data()))
        .toList();
  }

  static Future<Map<DateTime, DisponibilidadDia>> getDisponibilidadMesFromFirebase(
    String doctorId,
    int year,
    int month,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('disponibilidad')
        .doc(doctorId)
        .collection('$year-$month')
        .get();
    
    final Map<DateTime, DisponibilidadDia> disponibilidad = {};
    
    for (var doc in snapshot.docs) {
      final data = DisponibilidadDia.fromJson(doc.data());
      disponibilidad[data.fecha] = data;
    }
    
    return disponibilidad;
  }

  static Future<void> guardarCita(
    String pacienteId,
    String doctorId,
    DateTime fecha,
    String hora,
  ) async {
    await FirebaseFirestore.instance.collection('citas').add({
      'pacienteId': pacienteId,
      'doctorId': doctorId,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'estado': 'pendiente',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  */
  // Generador de disponibilidad para 2026 con parámetros
  static Map<String, List<String>> _generarDisponibilidadAnual({
    required bool esEspecialista,
    required bool altaDemanda,
  }) {
    final Map<String, List<String>> disponibilidad = {};
    final year = 2026;

    // Días festivos oficiales y comunes en México (MM-DD)
    final holidays = {
      '01-01', // Año Nuevo
      '02-05', // Día de la Constitución
      '03-21', // Natalicio de Benito Juárez
      '05-01', // Día del Trabajo
      '05-10', // Día de las Madres (medio día)
      '09-16', // Día de la Independencia
      '11-02', // Día de Muertos
      '11-20', // Día de la Revolución
      '12-12', // Día de la Virgen de Guadalupe
      '12-25', // Navidad
    };

    // Horarios Base
    final fullDay = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '14:00',
      '15:00',
      '16:00',
    ];
    final halfDay = ['09:00', '10:00', '11:00'];
    final mediumDay = ['10:00', '11:00', '14:00', '15:00'];

    // Horarios Reducidos (para especialistas o alta demanda)
    final busyDay = ['10:00', '11:00', '16:00']; // Pocos huecos
    final veryBusyDay = ['11:00', '16:00']; // Muy pocos huecos

    var date = DateTime(year, 1, 1);
    // Iterar todo el año
    while (date.year == year) {
      final key =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final monthDay =
          "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      if (holidays.contains(monthDay)) {
        // Festivo - Sin citas
        disponibilidad[key] = [];
      } else if (date.weekday == DateTime.sunday) {
        // Domingo - Sin citas
        disponibilidad[key] = [];
      } else if (date.weekday == DateTime.saturday) {
        // Sábado
        if (altaDemanda) {
          // Si es alta demanda, sábados muy llenos o no trabaja
          disponibilidad[key] = (date.day % 2 == 0) ? [] : ['10:00', '11:00'];
        } else {
          disponibilidad[key] = halfDay;
        }
      } else {
        // Lunes a Viernes
        if (altaDemanda) {
          // Alta demanda: mezcla de días ocupados y medios
          if (date.day % 3 == 0) {
            disponibilidad[key] = veryBusyDay;
          } else if (date.day % 2 == 0) {
            disponibilidad[key] = busyDay;
          } else {
            disponibilidad[key] = mediumDay;
          }
        } else if (esEspecialista) {
          // Especialista normal: mezcla de full y medium
          if (date.day % 4 == 0) {
            disponibilidad[key] = mediumDay;
          } else {
            disponibilidad[key] = fullDay;
          }
        } else {
          // General / Baja demanda: casi siempre full
          disponibilidad[key] = fullDay;
        }
      }

      date = date.add(const Duration(days: 1));
    }

    // Agregar Diciembre 2025 (copiado de lo que ya teníamos)
    final dec2025 = {
      '2025-12-01': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-02': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
      '2025-12-03': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-04': ['08:00', '09:00'],
      '2025-12-05': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-06': <String>[],
      '2025-12-08': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-09': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
      '2025-12-10': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-11': ['10:00', '11:00'],
      '2025-12-12': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-13': <String>[],
      '2025-12-15': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-16': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
      '2025-12-17': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-18': ['14:00', '15:00'],
      '2025-12-19': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-20': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
      '2025-12-22': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-23': ['08:00', '09:00', '10:00'],
      '2025-12-24': <String>[],
      '2025-12-26': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-27': <String>[],
      '2025-12-29': [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
      ],
      '2025-12-30': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
      '2025-12-31': ['09:00', '10:00'],
    };

    disponibilidad.addAll(dec2025);

    return disponibilidad;
  }
}
