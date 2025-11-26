import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_medico.dart';
import 'widgets/dialogos_medico.dart';

class DoctorPrescriptionsScreen extends StatefulWidget {
  const DoctorPrescriptionsScreen({super.key});

  @override
  State<DoctorPrescriptionsScreen> createState() =>
      _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState
    extends State<DoctorPrescriptionsScreen> {
  int _tab = 0; // 0 recientes, 1 borradores

  @override
  Widget build(BuildContext context) {
    final recientes = _prescriptions;
    final borradores = _drafts;

    return DoctorLayout(
      selectedIndex: 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth < 1200 ? constraints.maxWidth : 1200.0;
          final wide = constraints.maxWidth > 1100;

          List<PrescriptionItem> list =
              _tab == 0 ? recientes : borradores;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recetas Electrónicas',
                      style: GoogleFonts.archivo(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Genera y gestiona recetas médicas digitales',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buscador + botón
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: kMLightBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Buscar estudios por paciente o tipo...',
                                    style: GoogleFonts.archivoNarrow(
                                      fontSize: 13,
                                      color: kMGreyText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMPrimaryBlue,
                              foregroundColor: kMWhite,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NewPrescriptionScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nueva Receta'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tabs Recientes/Borradores
                    Row(
                      children: [
                        _prescriptionTab(
                          text: 'Recientes (${recientes.length})',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        const SizedBox(width: 8),
                        _prescriptionTab(
                          text: 'Borradores (${borradores.length})',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lista
                    ...list.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PrescriptionCard(
                          item: p,
                          isDraft: _tab == 1,
                          wide: wide,
                        ),
                      ),
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

  Widget _prescriptionTab({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kMPrimaryBlue : kMBlue12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              color: selected ? kMWhite : kMBlack,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final PrescriptionItem item;
  final bool isDraft;
  final bool wide;

  const _PrescriptionCard({
    required this.item,
    required this.isDraft,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    Widget statusChip(Color color, String text) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: GoogleFonts.archivoNarrow(fontSize: 11),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: kMLightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kMBlue12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.paciente,
                      style: GoogleFonts.archivo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.diagnostico,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.event, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          item.fecha,
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              statusChip(
                isDraft ? kMYellow : kMBlue15,
                isDraft ? 'Borrador' : 'Enviada',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Medicamentos:',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...item.medicamentos.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $m',
                style: GoogleFonts.archivoNarrow(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.indicaciones,
            style: GoogleFonts.archivoNarrow(fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (isDraft)
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMBlue15,
                      foregroundColor: kMBlack,
                      textStyle: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Completar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMPrimaryBlue,
                      foregroundColor: kMWhite,
                      textStyle: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Editar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMRed,
                      foregroundColor: kMWhite,
                      textStyle: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PrescriptionItem {
  final String paciente;
  final String diagnostico;
  final String fecha;
  final List<String> medicamentos;
  final String indicaciones;

  const PrescriptionItem({
    required this.paciente,
    required this.diagnostico,
    required this.fecha,
    required this.medicamentos,
    required this.indicaciones,
  });
}

const _prescriptions = <PrescriptionItem>[
  PrescriptionItem(
    paciente: 'María Gonzáles López',
    diagnostico: 'Hipertensión arterial',
    fecha: '15/11/2025',
    medicamentos: [
      'Losartán 50 mg - 1 vez al día por 30 días',
      'Aspirina 100 mg - 1 vez al día por 30 días',
    ],
    indicaciones:
        'Control en 1 mes. Tomar medicamentos con alimentos.',
  ),
  PrescriptionItem(
    paciente: 'María Gonzáles López',
    diagnostico: 'Hipertensión arterial',
    fecha: '15/11/2026',
    medicamentos: [
      'Losartán 50 mg - 1 vez al día por 30 días',
      'Aspirina 100 mg - 1 vez al día por 30 días',
    ],
    indicaciones:
        'Control en 1 mes. Tomar medicamentos con alimentos.',
  ),
];

const _drafts = <PrescriptionItem>[
  PrescriptionItem(
    paciente: 'Carmen Delgado',
    diagnostico: 'Dolor muscular',
    fecha: '10/12/2025',
    medicamentos: [
      'Paracetamol 500 mg - cada 8 horas',
    ],
    indicaciones:
        'Tomar con agua. No exceder la dosis indicada.',
  ),
];
