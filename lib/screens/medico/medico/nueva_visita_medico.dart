import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/diseno_medico.dart';
import '../../login/services/database_service.dart';

class NuevaVisitaMedicoScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const NuevaVisitaMedicoScreen({
    super.key,
    required this.patientData,
  });

  @override
  State<NuevaVisitaMedicoScreen> createState() => _NuevaVisitaMedicoScreenState();
}

class _NuevaVisitaMedicoScreenState extends State<NuevaVisitaMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Visit Details
  DateTime? _visitDate;
  String? _visitReason;
  final _notesController = TextEditingController();

  // Vital Signs
  final _bpController = TextEditingController();
  final _hrController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Diagnosis & Treatment
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();

  // Medications
  final List<Map<String, String>> _medications = [];

  // Next Visit
  DateTime? _nextVisitDate;

  @override
  void dispose() {
    _notesController.dispose();
    _bpController.dispose();
    _hrController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    super.dispose();
  }

  // Calculate age from date of birth
  int _calculateAge() {
    if (widget.patientData['fechaNacimiento'] == null) return 0;
    
    DateTime birthDate;
    final rawDate = widget.patientData['fechaNacimiento'];
    
    if (rawDate is Timestamp) {
      birthDate = rawDate.toDate();
    } else if (rawDate is String) {
      try {
        final parts = rawDate.split('/');
        if (parts.length == 3) {
          birthDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return 0;
        }
      } catch (_) {
        return 0;
      }
    } else {
      return 0;
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context, bool isNextVisit) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isNextVisit ? DateTime.now() : DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      helpText: isNextVisit ? 'Seleccionar próxima visita' : 'Seleccionar fecha de visita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1991DB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isNextVisit) {
          _nextVisitDate = picked;
        } else {
          _visitDate = picked;
        }
      });
    }
  }

  void _addMedication() {
    setState(() {
      _medications.add({
        'nombre': '',
        'dosis': '',
        'frecuencia': '',
        'duracion': '',
      });
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_visitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor selecciona la fecha de la visita',
            style: GoogleFonts.archivoNarrow(),
          ),
          backgroundColor: kMRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService();
      await db.addVisit(
        pacienteId: widget.patientData['id'],
        pacienteNombre: widget.patientData['nombreCompleto'],
        fecha: _visitDate!,
        motivo: _visitReason ?? 'consulta general',
        notas: _notesController.text,
        presion: _bpController.text,
        frecuenciaCardiaca: _hrController.text,
        temperatura: _temperatureController.text,
        peso: _weightController.text,
        altura: _heightController.text,
        diagnostico: _diagnosisController.text,
        medicamentos: _medications,
        planTratamiento: _treatmentPlanController.text,
        proximaVisita: _nextVisitDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Visita guardada exitosamente',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kMGreenBright,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger reload
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar visita: $e',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kMRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(fontSize: 14),
      hintStyle: GoogleFonts.archivoNarrow(fontSize: 13, color: kMGreyText),
      filled: true,
      fillColor: kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge();
    
    return Container(
        color: kMSidebarBlue.withValues(alpha: 0.12),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Center(
                      child: Text(
                        'Nueva Entrada de Visita',
                        style: GoogleFonts.archivo(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PATIENT INFORMATION (Readonly)
                    _buildSection(
                      title: 'Información del Paciente',
                      icon: Icons.person_outline,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildReadonlyField(
                              'Nombre del Paciente',
                              widget.patientData['nombreCompleto'] ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReadonlyField(
                              'Edad',
                              '$age años',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReadonlyField(
                              'Género',
                              widget.patientData['genero'] ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ),

                    //VISIT DETAILS
                    _buildSection(
                      title: 'Detalles de la Visita',
                      icon: Icons.event_note,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: InputDecorator(
                                    decoration: _fieldDecoration('Fecha de Visita *'),
                                    child: Text(
                                      _visitDate != null
                                          ? '${_visitDate!.day}/${_visitDate!.month}/${_visitDate!.year}'
                                          : 'Seleccionar fecha',
                                      style: GoogleFonts.archivoNarrow(
                                        fontSize: 14,
                                        color: _visitDate != null
                                            ? kMBlack
                                            : kMGreyText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: _fieldDecoration('Motivo *'),
                                  value: _visitReason,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'consulta general',
                                      child: Text('Consulta General'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'emergencia',
                                      child: Text('Emergencia'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'seguimiento',
                                      child: Text('Seguimiento'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _visitReason = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: _fieldDecoration(
                              'Notas',
                              hint: 'Notas adicionales sobre la visita...',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    // VITAL SIGNS
                    _buildSection(
                      title: 'Signos Vitales',
                      icon: Icons.favorite_outline,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _bpController,
                                  decoration: _fieldDecoration(
                                    'Presión Arterial',
                                    hint: 'ej., 120/80',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _hrController,
                                  decoration: _fieldDecoration(
                                    'Frecuencia Cardíaca',
                                    hint: 'ej., 72 lpm',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _temperatureController,
                                  decoration: _fieldDecoration(
                                    'Temperatura',
                                    hint: 'ej., 36.5°C',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: _fieldDecoration(
                                    'Peso',
                                    hint: 'ej., 70 kg',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  decoration: _fieldDecoration(
                                    'Altura',
                                    hint: 'ej., 170 cm',
                                  ),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // DIAGNOSIS
                    _buildSection(
                      title: 'Diagnóstico',
                      icon: Icons.medical_services_outlined,
                      child: TextFormField(
                        controller: _diagnosisController,
                        decoration: _fieldDecoration(
                          'Diagnóstico',
                          hint: 'Ingresar diagnóstico...',
                        ),
                        maxLines: 4,
                      ),
                    ),

                    // MEDICATIONS
                    _buildSection(
                      title: 'Medicamentos Prescritos',
                      icon: Icons.medication_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._medications.asMap().entries.map((entry) {
                            final index = entry.key;
                            return _buildMedicationRow(index);
                          }),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _addMedication,
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              'Agregar Medicamento',
                              style: GoogleFonts.archivoNarrow(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TREATMENT PLAN
                    _buildSection(
                      title: 'Plan de Tratamiento',
                      icon: Icons.assignment_outlined,
                      child: TextFormField(
                        controller: _treatmentPlanController,
                        decoration: _fieldDecoration(
                          'Plan de Tratamiento',
                          hint: 'Ingresar detalles del plan de tratamiento...',
                        ),
                        maxLines: 4,
                      ),
                    ),

                    // NEXT VISIT
                    _buildSection(
                      title: 'Próxima Visita (Opcional)',
                      icon: Icons.calendar_today_outlined,
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: _fieldDecoration('Fecha de Próxima Visita'),
                          child: Text(
                            _nextVisitDate != null
                                ? '${_nextVisitDate!.day}/${_nextVisitDate!.month}/${_nextVisitDate!.year}'
                                : 'Seleccionar fecha (opcional)',
                            style: GoogleFonts.archivoNarrow(
                              fontSize: 14,
                              color: _nextVisitDate != null
                                  ? kMBlack
                                  : kMGreyText,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // SAVE BUTTON
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMPrimaryBlue,
                            foregroundColor: kMWhite,
                            textStyle: GoogleFonts.archivoNarrow(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveVisit,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      kMWhite,
                                    ),
                                  ),
                                )
                              : const Text('GUARDAR VISITA'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kMLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: kMPrimaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildReadonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.archivoNarrow(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kMGreyText,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: kMBlue12,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: GoogleFonts.archivoNarrow(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kMWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: _fieldDecoration('Nombre', hint: 'Nombre del medicamento'),
                  onChanged: (value) {
                    _medications[index]['nombre'] = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: _fieldDecoration('Dosis', hint: '500mg'),
                  onChanged: (value) {
                    _medications[index]['dosis'] = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: kMRed),
                onPressed: () => _removeMedication(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _fieldDecoration('Frecuencia', hint: 'Cada 8h'),
                  onChanged: (value) {
                    _medications[index]['frecuencia'] = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: _fieldDecoration('Duración', hint: '7 días'),
                  onChanged: (value) {
                    _medications[index]['duracion'] = value;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
