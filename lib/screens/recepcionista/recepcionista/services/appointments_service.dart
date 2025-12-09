import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cita_models.dart';

// Servicio global para gestionar citas
class AppointmentsService extends ChangeNotifier {
  static final AppointmentsService _instance = AppointmentsService._internal();

  factory AppointmentsService() {
    return _instance;
  }

  AppointmentsService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Cita> _citas = [];

  List<Cita> get allAppointments => List.unmodifiable(_citas);

  // Obtener todas las citas
  Future<List<Cita>> fetchCitas() async {
    try {
      final snapshot = await _db.collection('citas').orderBy('fechaHora').get();
      
      _citas = snapshot.docs.map((doc) {
        final data = doc.data();
        // Mapeo manual de datos a modelo Cita
        // Asumimos estructura de datos en Firestore
        return Cita(
          id: doc.id,
          paciente: Paciente(
            id: data['pacienteId'] ?? '',
            nombre: data['pacienteNombre'] ?? '',
            telefono: data['pacienteTelefono'] ?? '',
            nss: data['pacienteNss'] ?? '',
            curp: data['pacienteCurp'] ?? '',
            correo: data['pacienteCorreo'] ?? '',
          ),
          doctor: Doctor(
            id: data['doctorId'] ?? '',
            nombre: data['doctorNombre'] ?? '',
            areaId: data['areaId'] ?? '',
            disponibilidad: {}, // No necesitamos disponibilidad aquí
          ),
          fecha: (data['fechaHora'] as Timestamp).toDate(),
          hora: data['hora'] ?? '',
          tipo: _parseTipoCita(data['tipo'] ?? ''),
          estado: _parseEstadoCita(data['estado'] ?? ''),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      notifyListeners();
      return _citas;
    } catch (e) {
      print('❌ Error fetching citas: $e');
      return [];
    }
  }

  // Agregar nueva cita
  Future<void> addCita(Cita cita) async {
    try {
      // Guardamos datos denormalizados para facilitar lectura
      await _db.collection('citas').add({
        'pacienteId': cita.paciente.id,
        'pacienteNombre': cita.paciente.nombre,
        'pacienteTelefono': cita.paciente.telefono,
        'pacienteNss': cita.paciente.nss,
        'pacienteCurp': cita.paciente.curp,
        'pacienteCorreo': cita.paciente.correo,
        'doctorId': cita.doctor.id,
        'doctorNombre': cita.doctor.nombre,
        'areaId': cita.doctor.areaId,
        'fechaHora': Timestamp.fromDate(cita.fecha), // Guardamos fecha completa
        'hora': cita.hora,
        'tipo': cita.tipo.toString().split('.').last,
        'estado': cita.estado.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Recargamos citas para actualizar UI
      await fetchCitas();
    } catch (e) {
      print('❌ Error adding cita: $e');
      throw e;
    }
  }

  // Actualizar cita
  Future<void> updateCita(Cita updatedCita) async {
    try {
      await _db.collection('citas').doc(updatedCita.id).update({
        'fechaHora': Timestamp.fromDate(updatedCita.fecha),
        'hora': updatedCita.hora,
        'tipo': updatedCita.tipo.toString().split('.').last,
        'estado': updatedCita.estado.toString().split('.').last,
      });
      
      await fetchCitas();
    } catch (e) {
      print('❌ Error updating cita: $e');
      throw e;
    }
  }

  // Cancelar cita (cambiar estado a cancelada)
  Future<void> cancelCita(String citaId) async {
    try {
      await _db.collection('citas').doc(citaId).update({
        'estado': 'cancelada',
      });
      await fetchCitas();
    } catch (e) {
      print('❌ Error cancelling cita: $e');
      throw e;
    }
  }

  // Eliminar cita permanentemente
  Future<void> deleteCita(String citaId) async {
    try {
      await _db.collection('citas').doc(citaId).delete();
      await fetchCitas();
    } catch (e) {
      print('❌ Error deleting cita: $e');
      throw e;
    }
  }

  // Buscar citas por nombre de paciente (filtro local por ahora)
  List<Cita> searchByPatientName(String query) {
    if (query.isEmpty) return allAppointments;

    final lowerQuery = query.toLowerCase();
    return _citas.where((cita) {
      return cita.paciente.nombre.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  TipoCita _parseTipoCita(String tipo) {
    switch (tipo) {
      case 'especialidad': return TipoCita.especialidad;
      case 'seguimiento': return TipoCita.seguimiento;
      default: return TipoCita.consultaGeneral;
    }
  }

  EstadoCita _parseEstadoCita(String estado) {
    switch (estado) {
      case 'cancelada': return EstadoCita.cancelada;
      case 'completada': return EstadoCita.confirmada; // completada maps to confirmada
      default: return EstadoCita.confirmada;
    }
  }
}
