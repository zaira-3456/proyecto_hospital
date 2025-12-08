import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diseno_medico.dart';
import '../../../recepcionista/recepcionista/models/cita_models.dart';
import '../../../recepcionista/recepcionista/services/appointments_service.dart';
import '../../../login/services/database_service.dart';

InputDecoration kDoctorFieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.archivoNarrow(fontSize: 14),
    hintStyle: GoogleFonts.archivoNarrow(fontSize: 13, color: kMGreyText),
    border: const OutlineInputBorder(),
    isDense: true,
  );
}

/// ========== DIALOG: SOLICITAR NUEVO ESTUDIO ==========

class RequestStudyDialog extends StatelessWidget {
  const RequestStudyDialog({super.key});

  InputDecoration _rxDecoration({
    String? label,
    String? hint,
    bool filledLight = false,
  }) {
    // MISMO ESTILO QUE NewPrescriptionScreen
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(fontSize: 14, color: kMBlack),
      hintStyle: GoogleFonts.archivoNarrow(fontSize: 13, color: kMGreyText),
      isDense: true,
      filled: true,
      fillColor: filledLight ? kMLightBlue : kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth < 420
              ? constraints.maxWidth
              : 360;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                // MISMO FONDO AZUL QUE NUEVA RECETA
                decoration: BoxDecoration(
                  color: kMSidebarBlue.withValues(alpha: 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'Solicitar Nuevo Estudio',
                      style: GoogleFonts.archivo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kMBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Completa la información del estudio clínico',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PACIENTE
                    Text(
                      'Paciente',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      decoration: _rxDecoration(
                        hint: 'Seleccionar paciente',
                        filledLight: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '1',
                          child: Text('María Gonzáles López'),
                        ),
                        DropdownMenuItem(
                          value: '2',
                          child: Text('Juan Carlos Ruiz'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 14),

                    // TIPO DE ESTUDIO
                    Text(
                      'Tipo de Estudio',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      decoration: _rxDecoration(
                        hint: 'Seleccionar tipo de estudio',
                        filledLight: true,
                      ),
                      items: const [],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 14),

                    // PRIORIDAD
                    Text(
                      'Prioridad',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      decoration: _rxDecoration(
                        hint: 'Seleccionar Prioridad',
                        filledLight: true,
                      ),
                      items: const [],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 14),

                    // FECHA PROGRAMADA
                    Text(
                      'Fecha Programada',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: _rxDecoration(
                        hint: 'dd / mm / aaaa',
                        filledLight: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // NOTAS ADICIONALES
                    Text(
                      'Notas Adicionales',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      maxLines: 3,
                      decoration: _rxDecoration(
                        hint: 'Notas adicionales...',
                        filledLight: true,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // BOTONES (MISMOS COLORES QUE NUEVA RECETA)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMBlue12,
                            foregroundColor: kMBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            textStyle: GoogleFonts.archivoNarrow(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMPrimaryBlue,
                            foregroundColor: kMWhite,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            textStyle: GoogleFonts.archivoNarrow(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onPressed: () {
                            // TODO: guardar solicitud
                            Navigator.pop(context);
                          },
                          child: const Text('Solicitar Estudio'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ========== DIALOG: PROGRAMAR SEGUIMIENTO ==========

class ScheduleFollowUpDialog extends StatefulWidget {
  final String patientName;

  const ScheduleFollowUpDialog({super.key, required this.patientName});

  @override
  State<ScheduleFollowUpDialog> createState() => _ScheduleFollowUpDialogState();
}

class _ScheduleFollowUpDialogState extends State<ScheduleFollowUpDialog> {
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  // Datos de pacientes para simular base de datos (mismos que en pacientes_medico.dart)
  final Map<String, Map<String, String>> _patientData = {
    'María Gonzáles López': {
      'telefono': '55 1234 5678',
      'email': 'mariagonzalez@gmail.com',
    },
    'Juan Carlos Ruiz': {
      'telefono': '55 9876 5432',
      'email': 'jc.ruiz@email.com',
    },
    'Ana Sofía Martínez': {
      'telefono': '55 5555 1234',
      'email': 'ana.martinez@email.com',
    },
    'Roberto Hernández': {
      'telefono': '55 7777 8888',
      'email': 'roberto.h@email.com',
    },
  };

  Future<void> _saveAppointment() async {
    if (_fechaController.text.isEmpty || _horaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa fecha y hora',
            style: GoogleFonts.archivoNarrow(),
          ),
          backgroundColor: kMRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final parts = _fechaController.text.split('/');
      if (parts.length != 3) throw FormatException('Formato inválido');

      final fecha = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      // Buscar datos del paciente
      final patientInfo =
          _patientData[widget.patientName] ??
          {'telefono': '55 0000 0000', 'email': ''};

      final cita = Cita(
        id: 'cita_${DateTime.now().millisecondsSinceEpoch}',
        paciente: Paciente(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          nombre: widget.patientName,
          telefono: patientInfo['telefono']!,
        ),
        doctor: Doctor(
          id: 'doc001',
          nombre: 'Dr. García',
          areaId: 'cardio',
          disponibilidad: {},
        ),
        fecha: fecha,
        hora: _horaController.text,
        tipo: TipoCita.seguimiento,
        estado: EstadoCita.confirmada,
        createdAt: DateTime.now(),
      );

      print('🔵 DEBUG: Guardando cita...');
      print('  ID: ${cita.id}');
      print('  Paciente: ${cita.paciente.nombre}');
      print('  Doctor: ${cita.doctor.nombre}');
      print('  Tipo: ${cita.tipo}');

      await AppointmentsService().addCita(cita);

      print('✅ Cita guardada');
      print('📊 Total citas: ${AppointmentsService().allAppointments.length}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Seguimiento programado exitosamente',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kMGreenBright,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.archivoNarrow()),
            backgroundColor: kMRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _rxDecoration({
    String? label,
    String? hint,
    bool filledLight = true,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(fontSize: 14, color: kMBlack),
      hintStyle: GoogleFonts.archivoNarrow(fontSize: 13, color: kMGreyText),
      isDense: true,
      filled: true,
      fillColor: filledLight ? kMLightBlue : kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: kMSidebarBlue.withValues(alpha: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Programar Seguimiento',
                        style: GoogleFonts.archivo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kMBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Para ${widget.patientName}',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          color: kMBlack.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 18),

                      TextField(
                        decoration: _rxDecoration(
                          label: 'Tipo de Seguimiento',
                          hint: 'Ej. Consulta de control, Nuevo estudio',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _fechaController,
                        decoration: _rxDecoration(
                          label: 'Fecha',
                          hint: 'dd / mm / aaaa',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _horaController,
                        decoration: _rxDecoration(
                          label: 'Hora',
                          hint: '--:-- -----',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        decoration: _rxDecoration(
                          label: 'Motivo de seguimiento',
                          hint: 'Describir el motivo del seguimiento',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        decoration: _rxDecoration(
                          label: 'Notas Adicionales',
                          hint:
                              'Instrucciones para el paciente, precauciones, etc.',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 22),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMBlue12,
                              foregroundColor: kMBlack,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMPrimaryBlue,
                              foregroundColor: kMWhite,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                              ),
                            ),
                            onPressed: _isSaving ? null : _saveAppointment,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        kMWhite,
                                      ),
                                    ),
                                  )
                                : const Text('Programar seguimiento'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ========== PANTALLA: NUEVA RECETA ELECTRÓNICA ==========

class NewPrescriptionScreen extends StatefulWidget {
  final String? prescriptionId;  // Para modo edición
  final Map<String, dynamic>? existingData;  // Datos existentes del borrador
  
  const NewPrescriptionScreen({
    super.key,
    this.prescriptionId,
    this.existingData,
  });

  @override
  State<NewPrescriptionScreen> createState() => _NewPrescriptionScreenState();
}

class _NewPrescriptionScreenState extends State<NewPrescriptionScreen> {
  final _diagnosisController = TextEditingController();
  final _med1NameController = TextEditingController();
  final _med1DoseController = TextEditingController();
  final _med1FreqController = TextEditingController();
  final _med1DurationController = TextEditingController();
  final _med2NameController = TextEditingController();
  final _med2DoseController = TextEditingController();
  final _med2FreqController = TextEditingController();
  final _med2DurationController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _selectedPatientId;
  String? _selectedPatientName;
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  bool _isSaving = false;
  
  bool get _isEditMode => widget.prescriptionId != null;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadExistingData();
  }
  
  void _loadExistingData() {
    if (widget.existingData != null) {
      final data = widget.existingData!;
      
      // Cargar datos existentes
      _selectedPatientId = data['pacienteId'];
      _selectedPatientName = data['pacienteNombre'];
      _diagnosisController.text = data['diagnostico'] ?? '';
      _instructionsController.text = data['instrucciones'] ?? '';
      
      // Cargar medicamentos
      final medicamentos = data['medicamentos'] as List<dynamic>? ?? [];
      if (medicamentos.isNotEmpty) {
        final med1 = medicamentos[0] as Map<String, dynamic>;
        _med1NameController.text = med1['nombre'] ?? '';
        _med1DoseController.text = med1['dosis'] ?? '';
        _med1FreqController.text = med1['frecuencia'] ?? '';
        _med1DurationController.text = med1['duracion'] ?? '';
      }
      
      if (medicamentos.length > 1) {
        final med2 = medicamentos[1] as Map<String, dynamic>;
        _med2NameController.text = med2['nombre'] ?? '';
        _med2DoseController.text = med2['dosis'] ?? '';
        _med2FreqController.text = med2['frecuencia'] ?? '';
        _med2DurationController.text = med2['duracion'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _med1NameController.dispose();
    _med1DoseController.dispose();
    _med1FreqController.dispose();
    _med1DurationController.dispose();
    _med2NameController.dispose();
    _med2DoseController.dispose();
    _med2FreqController.dispose();
    _med2DurationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final db = DatabaseService();
      final patientsData = await db.getPatients();
      
      if (mounted) {
        setState(() {
          _patients = patientsData.map((p) {
            return {
              'id': p['id'] ?? '',
              'nombreCompleto': p['nombreCompleto'] ?? 'Sin nombre',
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: $e'),
            backgroundColor: kMRed,
          ),
        );
      }
    }
  }

  Future<void> _savePrescription() async {
    // Validate required fields
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un paciente'),
          backgroundColor: kMOrange,
        ),
      );
      return;
    }

    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un diagnóstico'),
          backgroundColor: kMOrange,
        ),
      );
      return;
    }

    if (_med1NameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa al menos un medicamento'),
          backgroundColor: kMOrange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get current username from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('current_username');
      
      if (currentUsername == null) {
        throw Exception('No hay usuario autenticado');
      }
      
      // Prepare medications list
      final medications = <Map<String, String>>[];
      
      // Add medication 1
      if (_med1NameController.text.trim().isNotEmpty) {
        medications.add({
          'nombre': _med1NameController.text.trim(),
          'dosis': _med1DoseController.text.trim(),
          'frecuencia': _med1FreqController.text.trim(),
          'duracion': _med1DurationController.text.trim(),
        });
      }
      
      // Add medication 2 if provided
      if (_med2NameController.text.trim().isNotEmpty) {
        medications.add({
          'nombre': _med2NameController.text.trim(),
          'dosis': _med2DoseController.text.trim(),
          'frecuencia': _med2FreqController.text.trim(),
          'duracion': _med2DurationController.text.trim(),
        });
      }

      // Save to Firestore
      if (_isEditMode) {
        // Modo edición: actualizar documento existente
        await FirebaseFirestore.instance
            .collection('recetas')
            .doc(widget.prescriptionId)
            .update({
          'pacienteId': _selectedPatientId,
          'pacienteNombre': _selectedPatientName,
          'medicoId': currentUsername,
          'medicoNombre': currentUsername,
          'diagnostico': _diagnosisController.text.trim(),
          'medicamentos': medications,
          'instrucciones': _instructionsController.text.trim(),
          'fecha': FieldValue.serverTimestamp(),
          'estado': 'borrador',  // Mantener como borrador al editar
        });
      } else {
        // Modo nuevo: crear documento nuevo
        await FirebaseFirestore.instance.collection('recetas').add({
          'pacienteId': _selectedPatientId,
          'pacienteNombre': _selectedPatientName,
          'medicoId': currentUsername,
          'medicoNombre': currentUsername,
          'diagnostico': _diagnosisController.text.trim(),
          'medicamentos': medications,
          'instrucciones': _instructionsController.text.trim(),
          'fecha': FieldValue.serverTimestamp(),
          'estado': 'activa',
        });
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode 
                  ? 'Borrador actualizado exitosamente' 
                  : 'Receta guardada exitosamente',
            ),
            backgroundColor: kMGreenBright,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar receta: $e'),
            backgroundColor: kMRed,
          ),
        );
      }
    }
  }

  InputDecoration _rxDecoration({
    String? label,
    String? hint,
    bool filledLight = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(fontSize: 14, color: kMBlack),
      hintStyle: GoogleFonts.archivoNarrow(fontSize: 13, color: kMGreyText),
      isDense: true,
      filled: true,
      fillColor: filledLight ? kMLightBlue : kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMWhite,
      appBar: AppBar(
        backgroundColor: kMWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kMBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nueva Receta',
          style: GoogleFonts.archivo(
            color: kMBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TÍTULO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nueva Receta Electrónica',
                      style: GoogleFonts.archivo(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const DoctorLogoCircle(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Genera una nueva receta médica para tus pacientes',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 14,
                    color: kMGreyText,
                  ),
                ),
                const SizedBox(height: 28),

                // PACIENTE
                Text(
                  'Paciente *',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _isLoading
                    ? Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: kMLightBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        decoration: _rxDecoration(
                          hint: 'Seleccionar paciente',
                          filledLight: true,
                        ),
                        value: _selectedPatientId,
                        items: _patients.map((patient) {
                          return DropdownMenuItem<String>(
                            value: patient['id'],
                            child: Text(
                              patient['nombreCompleto'] ?? 'Sin nombre',
                              style: GoogleFonts.archivoNarrow(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPatientId = value;
                            _selectedPatientName = _patients
                                .firstWhere((p) => p['id'] == value)['nombreCompleto'];
                          });
                        },
                      ),
                const SizedBox(height: 24),

                // DIAGNÓSTICO
                Text(
                  'Diagnóstico Principal *',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _diagnosisController,
                  maxLines: 2,
                  decoration: _rxDecoration(
                    hint: 'Escribir diagnóstico principal...',
                    filledLight: true,
                  ),
                ),
                const SizedBox(height: 24),

                // MEDICAMENTO 1
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kMLightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicamento 1 *',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _med1NameController,
                        decoration: _rxDecoration(
                          hint: 'Nombre del medicamento',
                          filledLight: false,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _med1DoseController,
                              decoration: _rxDecoration(
                                hint: '500 mg',
                                label: 'Dosis',
                                filledLight: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _med1FreqController,
                              decoration: _rxDecoration(
                                hint: 'C/8 hrs',
                                label: 'Frecuencia',
                                filledLight: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _med1DurationController,
                              decoration: _rxDecoration(
                                hint: '7 días',
                                label: 'Duración',
                                filledLight: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // MEDICAMENTO 2 (OPCIONAL)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kMLightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicamento 2 (Opcional)',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _med2NameController,
                        decoration: _rxDecoration(
                          hint: 'Nombre del medicamento',
                          filledLight: false,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _med2DoseController,
                              decoration: _rxDecoration(
                                hint: '500 mg',
                                label: 'Dosis',
                                filledLight: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _med2FreqController,
                              decoration: _rxDecoration(
                                hint: 'C/12 hrs',
                                label: 'Frecuencia',
                                filledLight: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _med2DurationController,
                              decoration: _rxDecoration(
                                hint: '5 días',
                                label: 'Duración',
                                filledLight: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // INSTRUCCIONES ADICIONALES
                Text(
                  'Instrucciones Adicionales',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _instructionsController,
                  maxLines: 3,
                  decoration: _rxDecoration(
                    hint: 'Instrucciones para el paciente, precauciones, etc.',
                    filledLight: true,
                  ),
                ),
                const SizedBox(height: 28),

                // BOTONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancelar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMBlue12,
                        foregroundColor: kMBlack,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    // Guardar Borrador
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMOrange,
                        foregroundColor: kMWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Guardar Borrador'),
                      onPressed: _isSaving ? null : _saveDraft,
                    ),
                    const SizedBox(width: 12),
                    // Descargar / Imprimir
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMSidebarBlue,
                        foregroundColor: kMWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Descargar'),
                      onPressed: _isSaving ? null : _downloadPrescription,
                    ),
                    const SizedBox(width: 12),
                    // Enviar Receta
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMPrimaryBlue,
                        foregroundColor: kMWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: _isSaving 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(kMWhite),
                              ),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: const Text('Enviar Receta'),
                      onPressed: _isSaving ? null : _savePrescription,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    // Validate at least patient is selected
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un paciente'),
          backgroundColor: kMOrange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get current username from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('current_username');
      
      if (currentUsername == null) {
        throw Exception('No hay usuario autenticado');
      }
      
      // Prepare medications list
      final medications = <Map<String, String>>[];
      
      if (_med1NameController.text.trim().isNotEmpty) {
        medications.add({
          'nombre': _med1NameController.text.trim(),
          'dosis': _med1DoseController.text.trim(),
          'frecuencia': _med1FreqController.text.trim(),
          'duracion': _med1DurationController.text.trim(),
        });
      }
      
      if (_med2NameController.text.trim().isNotEmpty) {
        medications.add({
          'nombre': _med2NameController.text.trim(),
          'dosis': _med2DoseController.text.trim(),
          'frecuencia': _med2FreqController.text.trim(),
          'duracion': _med2DurationController.text.trim(),
        });
      }

      // Save as draft to Firestore
      await FirebaseFirestore.instance.collection('recetas').add({
        'pacienteId': _selectedPatientId,
        'pacienteNombre': _selectedPatientName,
        'medicoId': currentUsername,  // Use username instead of Firebase UID
        'medicoNombre': currentUsername,  // Use username as name for now
        'diagnostico': _diagnosisController.text.trim(),
        'medicamentos': medications,
        'instrucciones': _instructionsController.text.trim(),
        'fecha': FieldValue.serverTimestamp(),
        'estado': 'borrador',
      });

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Borrador guardado exitosamente'),
            backgroundColor: kMOrange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar borrador: $e'),
            backgroundColor: kMRed,
          ),
        );
      }
    }
  }

  Future<void> _downloadPrescription() async {
    // Validate required fields
    if (_selectedPatientId == null || 
        _diagnosisController.text.trim().isEmpty || 
        _med1NameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos requeridos antes de descargar'),
          backgroundColor: kMOrange,
        ),
      );
      return;
    }

    // TODO: Implementar generación de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Descargando receta para ${_selectedPatientName ?? "paciente"}...',
          style: GoogleFonts.archivoNarrow(),
        ),
        backgroundColor: kMSidebarBlue,
      ),
    );
  }
}

