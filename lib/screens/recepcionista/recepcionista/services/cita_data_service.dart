import '../models/cita_models.dart';
import '../../../login/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio de datos para citas - Integrado con Firestore
class CitaDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================
  // ÁREAS MÉDICAS (desde Firestore)
  // ============================================
  static Future<List<Area>> getAreas() async {
    try {
      final db = DatabaseService();
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
  // DOCTORES (desde Firestore)
  // ============================================
  static Future<List<Doctor>> getDoctores() async {
    try {
      final db = DatabaseService();
      final personal = await db.getPersonnelList();
      
      return personal
          .where((p) => (p['tipo'] ?? '').toString().toLowerCase() == 'medico')
          .map((data) {
            return Doctor(
              id: data['id'] ?? '',
              nombre: data['nombre'] ?? '',
              areaId: data['area'] ?? '',
              disponibilidad: {}, // Ahora se carga desde Firestore dinámicamente
            );
          }).toList();
    } catch (e) {
      print('❌ Error fetching doctors: $e');
      return [];
    }
  }

  static Future<List<Doctor>> getDoctoresByArea(String areaId) async {
    final doctores = await getDoctores();
    
    // Obtener el nombre del área para comparación flexible
    final areas = await getAreas();
    final area = areas.firstWhere(
      (a) => a.id == areaId,
      orElse: () => Area(id: areaId, nombre: areaId),
    );
    
    return doctores.where((doc) => 
      doc.areaId.toLowerCase() == areaId.toLowerCase() || 
      doc.areaId.toLowerCase() == area.nombre.toLowerCase() ||
      doc.areaId.toLowerCase().contains(areaId.toLowerCase())
    ).toList();
  }

  // ============================================
  // DISPONIBILIDAD REAL DESDE FIRESTORE
  // ============================================
  
  /// Obtener disponibilidad de un doctor para un mes específico
  /// Consulta colección 'disponibilidad_medicos' en Firestore
  static Future<Map<DateTime, DisponibilidadDia>> getDisponibilidadMes(
    String doctorId,
    int year,
    int month,
  ) async {
    try {
      // Intentar obtener disponibilidad desde Firestore
      final snapshot = await _db
          .collection('disponibilidad_medicos')
          .doc(doctorId)
          .collection('$year-${month.toString().padLeft(2, '0')}')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        // Usar datos de Firestore
        final Map<DateTime, DisponibilidadDia> disponibilidad = {};
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          try {
            final fecha = DateTime.parse(doc.id);
            final horasDisponibles = List<String>.from(data['horas'] ?? []);
            final citasOcupadas = (data['citasOcupadas'] ?? 0) as int;
            final citasTotal = (data['citasTotal'] ?? 8) as int;
            
            disponibilidad[fecha] = DisponibilidadDia(
              fecha: fecha,
              citasDisponibles: horasDisponibles.length,
              citasOcupadas: citasOcupadas,
              citasTotal: citasTotal,
            );
          } catch (e) {
            print('Error parsing date ${doc.id}: $e');
          }
        }
        
        if (disponibilidad.isNotEmpty) {
          return disponibilidad;
        }
      }
      
      // Si no hay datos en Firestore, usar disponibilidad por defecto
      return _generarDisponibilidadMes(year, month);
    } catch (e) {
      print('⚠️ Error fetching availability from Firestore: $e');
      // Fallback a disponibilidad generada
      return _generarDisponibilidadMes(year, month);
    }
  }

  /// Obtener horas disponibles para un doctor en una fecha específica
  static Future<List<String>> getHorasDisponibles(String doctorId, DateTime fecha) async {
    try {
      final mesKey = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
      final diaKey = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      
      // Intentar obtener de Firestore
      final docSnapshot = await _db
          .collection('disponibilidad_medicos')
          .doc(doctorId)
          .collection(mesKey)
          .doc(diaKey)
          .get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final horas = List<String>.from(data?['horas'] ?? []);
        
        // Excluir horas ya ocupadas por citas existentes
        final citasExistentes = await _getCitasDelDia(doctorId, fecha);
        return horas.where((hora) => !citasExistentes.contains(hora)).toList();
      }
      
      // Fallback: generar horas disponibles por defecto
      return _generarHorasDisponibles(fecha);
    } catch (e) {
      print('⚠️ Error fetching hours: $e');
      return _generarHorasDisponibles(fecha);
    }
  }

  /// Obtener citas existentes de un doctor en un día específico
  static Future<List<String>> _getCitasDelDia(String doctorId, DateTime fecha) async {
    try {
      final inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day);
      final finDelDia = inicioDelDia.add(const Duration(days: 1));
      
      final snapshot = await _db
          .collection('citas')
          .where('doctorId', isEqualTo: doctorId)
          .where('fechaHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
          .where('fechaHora', isLessThan: Timestamp.fromDate(finDelDia))
          .get();
      
      return snapshot.docs.map((doc) => doc.data()['hora'] as String? ?? '').toList();
    } catch (e) {
      print('Error getting citas: $e');
      return [];
    }
  }

  // ============================================
  // BÚSQUEDA DE PACIENTES EXISTENTES
  // ============================================
  
  /// Buscar pacientes por nombre o teléfono
  static Future<List<Map<String, dynamic>>> buscarPacientes(String query) async {
    if (query.isEmpty || query.length < 2) return [];
    
    try {
      final queryLower = query.toLowerCase();
      
      // Buscar en colección pacientes
      final snapshot = await _db.collection('pacientes').get();
      
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final nombre = (data['nombreCompleto'] ?? '').toString().toLowerCase();
            final telefono = (data['telefono'] ?? '').toString();
            final curp = (data['curp'] ?? data['CURP'] ?? '').toString().toLowerCase();
            
            return nombre.contains(queryLower) || 
                   telefono.contains(query) ||
                   curp.contains(queryLower);
          })
          .map((doc) => {
            ...doc.data(),
            'id': doc.id,
          })
          .take(10) // Limitar resultados
          .toList();
    } catch (e) {
      print('❌ Error searching patients: $e');
      return [];
    }
  }

  /// Obtener paciente por CURP
  static Future<Map<String, dynamic>?> getPacienteByCurp(String curp) async {
    if (curp.isEmpty) return null;
    
    try {
      final snapshot = await _db
          .collection('pacientes')
          .where('curp', isEqualTo: curp.toUpperCase())
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return {
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting patient by CURP: $e');
      return null;
    }
  }

  /// Obtener paciente por teléfono
  static Future<Map<String, dynamic>?> getPacienteByTelefono(String telefono) async {
    if (telefono.isEmpty || telefono.length < 10) return null;
    
    try {
      final snapshot = await _db
          .collection('pacientes')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return {
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting patient by phone: $e');
      return null;
    }
  }

  // ============================================
  // GENERADORES DE DISPONIBILIDAD (FALLBACK)
  // ============================================

  /// Generar disponibilidad para un mes cuando no hay datos en Firestore
  static Map<DateTime, DisponibilidadDia> _generarDisponibilidadMes(int year, int month) {
    final Map<DateTime, DisponibilidadDia> disponibilidad = {};
    
    // Obtener primer y último día del mes
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    var date = firstDay;
    while (date.isBefore(lastDay.add(const Duration(days: 1)))) {
      if (date.weekday != DateTime.sunday) {
        int citasDisponibles;
        int citasTotal = 8;
        
        if (date.weekday == DateTime.saturday) {
          citasDisponibles = 3;
          citasTotal = 4;
        } else {
          // Simular algo de variación
          citasDisponibles = 4 + (date.day % 4);
        }
        
        disponibilidad[date] = DisponibilidadDia(
          fecha: date,
          citasDisponibles: citasDisponibles,
          citasOcupadas: citasTotal - citasDisponibles,
          citasTotal: citasTotal,
        );
      }
      
      date = date.add(const Duration(days: 1));
    }
    
    return disponibilidad;
  }

  /// Generar horas disponibles para un día cuando no hay datos en Firestore
  static List<String> _generarHorasDisponibles(DateTime fecha) {
    if (fecha.weekday == DateTime.sunday) {
      return [];
    }
    
    if (fecha.weekday == DateTime.saturday) {
      return ['09:00', '10:00', '11:00'];
    }
    
    // Lunes a Viernes - horario completo
    List<String> horas = [
      '08:00', '09:00', '10:00', '11:00',
      '14:00', '15:00', '16:00',
    ];
    
    // Simular algunas horas ocupadas basado en el día
    if (fecha.day % 3 == 0) {
      horas.removeAt(0);
      horas.removeAt(1);
    }
    
    return horas;
  }
}
