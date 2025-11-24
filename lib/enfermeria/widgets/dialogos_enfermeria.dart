import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'diseño_enfermeria.dart';

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.archivoNarrow(fontSize: 14),
    hintStyle: GoogleFonts.archivoNarrow(
      fontSize: 13,
      color: Colors.grey[600],
    ),
    border: const OutlineInputBorder(),
    isDense: true,
  );
}

/// ========== DIALOG: REGISTRAR NUEVA TAREA ==========

class RegisterTaskDialog extends StatelessWidget {
  const RegisterTaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Registrar Nueva Tarea',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Paciente'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paciente 1',
                            child: Text('Paciente 1'),
                          ),
                          DropdownMenuItem(
                            value: 'Paciente 2',
                            child: Text('Paciente 2'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: _fieldDecoration(
                          'Tarea',
                          hint: 'Descripción de la tarea',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: _fieldDecoration(
                          'Habitación',
                          hint: 'Número de la habitación',
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNPrimaryBlue,
                            foregroundColor: kNWhite,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Registrar Tarea'),
                        ),
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

/// ========== DIALOG: REGISTRAR MEDICAMENTO ==========

class RegisterMedicationDialog extends StatelessWidget {
  const RegisterMedicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Registrar Medicamento',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Medicamento'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paracetamol',
                            child: Text('Paracetamol'),
                          ),
                          DropdownMenuItem(
                            value: 'Ibuprofeno',
                            child: Text('Ibuprofeno'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Paciente'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paciente 1',
                            child: Text('Paciente 1'),
                          ),
                          DropdownMenuItem(
                            value: 'Paciente 2',
                            child: Text('Paciente 2'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNPrimaryBlue,
                            foregroundColor: kNWhite,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Administrar'),
                        ),
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

/// ========== DIALOG: DETALLES DEL PACIENTE ==========

class PatientDetailsDialog extends StatelessWidget {
  final String nombre;
  final String edad;
  final String habitacion;
  final bool critico;

  const PatientDetailsDialog({
    super.key,
    required this.nombre,
    required this.edad,
    required this.habitacion,
    required this.critico,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Detalles del Paciente',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        decoration: _fieldDecoration('Nombre completo')
                            .copyWith(
                          hintText: nombre,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        decoration:
                            _fieldDecoration('Edad').copyWith(
                          hintText: edad,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        decoration: _fieldDecoration(
                          'Habitación/Cama',
                        ).copyWith(
                          hintText: habitacion,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Estado',
                        style: GoogleFonts.archivoNarrow(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              critico ? kNRedAlert : kNGreenDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          critico ? 'Crítico' : 'Estable',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 13,
                            color: kNWhite,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4D4D4),
                            foregroundColor: kNBlack,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
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

/// ========== DIALOG: ADMINISTRAR MEDICAMENTO ==========

class AdministerMedicationDialog extends StatelessWidget {
  const AdministerMedicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Administrar Medicamento',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Medicamento'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paracetamol',
                            child: Text('Paracetamol'),
                          ),
                          DropdownMenuItem(
                            value: 'Ibuprofeno',
                            child: Text('Ibuprofeno'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Paciente'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paciente 1',
                            child: Text('Paciente 1'),
                          ),
                          DropdownMenuItem(
                            value: 'Paciente 2',
                            child: Text('Paciente 2'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNPrimaryBlue,
                            foregroundColor: kNWhite,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
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
