import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'diseno_medico.dart';

InputDecoration kDoctorFieldDecoration(String label,
    {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.archivoNarrow(fontSize: 14),
    hintStyle: GoogleFonts.archivoNarrow(
      fontSize: 13,
      color: kMGreyText,
    ),
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
      labelStyle: GoogleFonts.archivoNarrow(
        fontSize: 14,
        color: kMBlack,
      ),
      hintStyle: GoogleFonts.archivoNarrow(
        fontSize: 13,
        color: kMGreyText,
      ),
      isDense: true,
      filled: true,
      fillColor: filledLight ? kMLightBlue : kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth =
              constraints.maxWidth < 420 ? constraints.maxWidth : 360;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                // MISMO FONDO AZUL QUE NUEVA RECETA
                decoration: BoxDecoration(
                  color: kMSidebarBlue.withOpacity(1.0),
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

class ScheduleFollowUpDialog extends StatelessWidget {
  final String patientName;

  const ScheduleFollowUpDialog({
    super.key,
    required this.patientName,
  });

  InputDecoration _rxDecoration({
    String? label,
    String? hint,
    bool filledLight = true,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(
        fontSize: 14,
        color: kMBlack,
      ),
      hintStyle: GoogleFonts.archivoNarrow(
        fontSize: 13,
        color: kMGreyText,
      ),
      isDense: true,
      filled: true,
      fillColor: filledLight ? kMLightBlue : kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: kMSidebarBlue.withOpacity(1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
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
                        'Para $patientName',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          color: kMBlack.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 18),

                      TextField(
                        decoration: _rxDecoration(
                          label: 'Tipo de Seguimiento',
                          hint:
                              'Ej. Consulta de control, Nuevo estudio',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        decoration: _rxDecoration(
                          label: 'Fecha',
                          hint: 'dd / mm / aaaa',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Programar seguimiento'),
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

class NewPrescriptionScreen extends StatelessWidget {
  const NewPrescriptionScreen({super.key});

  InputDecoration _rxDecoration({
    String? label,
    String? hint,
    bool filledLight = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(
        fontSize: 14,
        color: kMBlack,
      ),
      hintStyle: GoogleFonts.archivoNarrow(
        fontSize: 13,
        color: kMGreyText,
      ),
      isDense: true,
      filled: true,
      fillColor: filledLight ? kMLightBlue : kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DoctorLayout(
      selectedIndex: 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 720;
          final double maxWidth =
              constraints.maxWidth < 1100 ? constraints.maxWidth : 900;

          return Container(
            // fondo azul “texturizado” del diseño
            color: kMSidebarBlue.withOpacity(0.12),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TÍTULO
                      Center(
                        child: Text(
                          'Nueva Receta Electrónica',
                          style: GoogleFonts.archivo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: kMBlack,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

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
                      const SizedBox(height: 24),

                      // DIAGNÓSTICO
                      Text(
                        'Diagnostico',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        maxLines: 2,
                        decoration: _rxDecoration(
                          hint: 'Escribir diagnóstico principal...',
                          filledLight: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // MEDICAMENTOS (0)
                      Text(
                        'Medicamentos (0)',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // BLOQUE AZUL CLARO
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kMLightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // fila 1: Medicamento / Frecuencia
                            if (isMobile)
                              Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Medicamento',
                                      style: GoogleFonts.archivoNarrow(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    decoration: _rxDecoration(
                                      hint: 'Seleccionar medicamento',
                                      filledLight: true,
                                    ),
                                    items: const [],
                                    onChanged: (_) {},
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Frecuencia',
                                      style: GoogleFonts.archivoNarrow(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    decoration: _rxDecoration(
                                      hint: 'Seleccionar frecuencia',
                                      filledLight: true,
                                    ),
                                    items: const [],
                                    onChanged: (_) {},
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Medicamento',
                                          style:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        DropdownButtonFormField<String>(
                                          decoration: _rxDecoration(
                                            hint:
                                                'Seleccionar medicamento',
                                            filledLight: true,
                                          ),
                                          items: const [],
                                          onChanged: (_) {},
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Frecuencia',
                                          style:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        DropdownButtonFormField<String>(
                                          decoration: _rxDecoration(
                                            hint:
                                                'Seleccionar frecuencia',
                                            filledLight: true,
                                          ),
                                          items: const [],
                                          onChanged: (_) {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 14),

                            // fila 2: Dosis / Duración
                            if (isMobile)
                              Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Dosis',
                                      style: GoogleFonts.archivoNarrow(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    decoration: _rxDecoration(
                                      hint: 'Ej. 500 mg',
                                      filledLight: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Duración',
                                      style: GoogleFonts.archivoNarrow(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    decoration: _rxDecoration(
                                      hint: 'Ej. 7 días',
                                      filledLight: true,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dosis',
                                          style:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          decoration: _rxDecoration(
                                            hint: 'Ej. 500 mg',
                                            filledLight: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Duración',
                                          style:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          decoration: _rxDecoration(
                                            hint: 'Ej. 7 días',
                                            filledLight: true,
                                          ),
                                        ),
                                      ],
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
                        maxLines: 3,
                        decoration: _rxDecoration(
                          hint:
                              'Instrucciones para el paciente, precauciones, etc.',
                          filledLight: true,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // BOTONES INFERIORES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMPrimaryBlue,
                              foregroundColor: kMWhite,
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 26, vertical: 10),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Enviar Receta'),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMBlue12,
                              foregroundColor: kMBlack,
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 26, vertical: 10),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Guardar Borrador'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
