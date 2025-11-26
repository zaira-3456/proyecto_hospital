import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_medico.dart';
import 'widgets/dialogos_medico.dart';

class DoctorResultsScreen extends StatefulWidget {
  const DoctorResultsScreen({super.key});

  @override
  State<DoctorResultsScreen> createState() => _DoctorResultsScreenState();
}

class _DoctorResultsScreenState extends State<DoctorResultsScreen> {
  ResultItem? _selected = _results.first;

  @override
  Widget build(BuildContext context) {
    return DoctorLayout(
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 1100;

          // ================= COLUMNA IZQUIERDA: LISTA =================
          Widget listColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultados Clínicos',
                style: GoogleFonts.archivo(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consultar los resultados',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 14,
                  color: kMGreyText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: kMLightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buscar resultados',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 13,
                          color: kMGreyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ..._results.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ResultCard(
                    item: r,
                    selected: _selected == r,
                    onTap: () => setState(() => _selected = r),
                  ),
                ),
              ),
            ],
          );

          // ================= COLUMNA DETALLE =================
          Widget detailColumn;
          if (_selected == null) {
            detailColumn = Center(
              child: Text(
                'Selecciona un resultado',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 16,
                  color: kMGreyText,
                ),
              ),
            );
          } else {
            detailColumn = _ResultDetail(item: _selected!);
          }

          // ============== LAYOUT MÓVIL / TABLET ==============
          if (!wide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  listColumn,
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kMLightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: detailColumn,
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMPrimaryBlue,
                        foregroundColor: kMWhite,
                      ),
                      onPressed: () {
                        if (_selected != null) {
                          _showScheduleDialog(
                            context,
                            _selected!.paciente,
                          );
                        }
                      },
                      child: Text(
                        'Programar Seguimiento',
                        style: GoogleFonts.archivoNarrow(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ============== LAYOUT ESCRITORIO ==============
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1350),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: listColumn),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        // Altura base para que el detalle respire
                        height: 520,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: kMLightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: detailColumn,
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
}

/// ======= CARD RESULTADO EN LA LISTA =======

class _ResultCard extends StatelessWidget {
  final ResultItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ResultCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kMLightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
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
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: GoogleFonts.archivo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.paciente,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: kMGreyText),
                        const SizedBox(width: 4),
                        Text(
                          item.fecha,
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 12,
                            color: kMGreyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kMGreenBright,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.estado,
                  style: GoogleFonts.archivoNarrow(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======= PANEL DETALLE RESULTADO =======

class _ResultDetail extends StatelessWidget {
  final ResultItem item;

  const _ResultDetail({required this.item});

  Widget _row(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.archivoNarrow(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.archivoNarrow(
            fontSize: 13,
            color: color ?? kMBlack,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.titulo,
          style: GoogleFonts.archivo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.paciente,
          style: GoogleFonts.archivoNarrow(fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 4),
            Text(
              'Fecha de estudio: ${item.fecha}',
              style: GoogleFonts.archivoNarrow(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Resultados de Laboratorio',
          style: GoogleFonts.archivo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kMWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _row('Hemoglobina', '13.5 g/dL · Normal',
                  color: kMPrimaryBlue),
              const SizedBox(height: 4),
              _row('Leucocitos', '7200 /µL · Normal',
                  color: kMPrimaryBlue),
              const SizedBox(height: 4),
              _row('Plaquetas', '250000 /µL · Normal',
                  color: kMPrimaryBlue),
              const SizedBox(height: 4),
              _row('Glucosa', '110 mg/dL · Alto', color: kMRed),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMBlue15,
                foregroundColor: kMBlack,
              ),
              onPressed: () {},
              child: Text(
                'Compartir',
                style: GoogleFonts.archivoNarrow(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMPrimaryBlue,
                foregroundColor: kMWhite,
              ),
              onPressed: () {
                _showScheduleDialog(context, item.paciente);
              },
              child: Text(
                'Programar Seguimiento',
                style: GoogleFonts.archivoNarrow(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ======= MODELO DE DATOS =======

class ResultItem {
  final String titulo;
  final String paciente;
  final String fecha;
  final String estado;

  const ResultItem({
    required this.titulo,
    required this.paciente,
    required this.fecha,
    required this.estado,
  });
}

const _results = <ResultItem>[
  ResultItem(
    titulo: 'Análisis de Sangre Completo',
    paciente: 'María Gonzáles López',
    fecha: '15/11/2025',
    estado: 'Disponible',
  ),
  ResultItem(
    titulo: 'Radiografía de Tórax',
    paciente: 'Juan Carlos Ruiz',
    fecha: '15/11/2025',
    estado: 'Disponible',
  ),
  ResultItem(
    titulo: 'Ultrasonido Prenatal',
    paciente: 'Ana Sofía Martínez',
    fecha: '15/11/2025',
    estado: 'Disponible',
  ),
  ResultItem(
    titulo: 'Análisis de Sangre Completo',
    paciente: 'María Gonzáles López',
    fecha: '10/11/2025',
    estado: 'Disponible',
  ),
];

/// ======= FUNCIÓN PARA MOSTRAR POPUP CON ANIMACIÓN =======

Future<void> _showScheduleDialog(
  BuildContext context,
  String patientName,
) {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'Programar seguimiento',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (_, __, ___) {
      return ScheduleFollowUpDialog(patientName: patientName);
    },
    transitionBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
