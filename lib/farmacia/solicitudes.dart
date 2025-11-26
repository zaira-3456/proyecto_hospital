import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_farmacia.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pendientes = _dummyPending;
    final completadas = _dummyCompleted;

    return PharmacyLayout(
      selectedIndex: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 900;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solicitudes de Enfermería',
                      style: GoogleFonts.archivo(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: kBlack,
                      ),
                    ),
                    const HospitalLogoCircle(),
                  ],
                ),
                const SizedBox(height: 20),

                // Banda Pendientes de aprobación
                Container(
                  width: double.infinity,
                  color: const Color(0xFFE1E1E1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Text(
                    'Pendientes de Aprobación',
                    style: GoogleFonts.archivo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kOrange,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ...pendientes.map((p) => _PendingCard(p: p)),
                      const SizedBox(height: 24),

                      // Banda Órdenes completadas
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFE1E1E1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        child: Text(
                          'Ordenes completadas hoy',
                          style: GoogleFonts.archivo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ====== TABLA RESPONSIVA DE ÓRDENES COMPLETADAS ======
                      LayoutBuilder(
                        builder: (context, innerConstraints) {
                          const double maxWidth = 960;

                          final double visibleWidth =
                              innerConstraints.maxWidth < maxWidth
                                  ? innerConstraints.maxWidth
                                  : maxWidth;

                          return Center(
                            child: SizedBox(
                              width: visibleWidth,
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        // la tabla “piensa” que mide 960px
                                        // así se mantiene el diseño y en móvil
                                        // aparece scroll horizontal si hace falta.
                                        minWidth: maxWidth,
                                      ),
                                      child: DataTableTheme(
                                        data: DataTableThemeData(
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                            kPrimaryBlue,
                                          ),
                                          headingTextStyle:
                                              GoogleFonts.archivo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: kBlack,
                                            letterSpacing: 0.8,
                                          ),
                                          dataTextStyle:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 14,
                                          ),
                                          headingRowHeight: 40,
                                          dataRowHeight: 44,
                                        ),
                                        child: DataTable(
                                          columnSpacing:
                                              isNarrow ? 16 : 32,
                                          columns: const [
                                            DataColumn(
                                                label: Text('Medicamento')),
                                            DataColumn(
                                                label: Text('Cantidad')),
                                            DataColumn(
                                                label: Text('Enfermera')),
                                            DataColumn(label: Text('Hora')),
                                          ],
                                          rows: completadas
                                              .map(
                                                (o) => DataRow(
                                                  cells: [
                                                    DataCell(
                                                        Text(o.medicamento)),
                                                    DataCell(Text(
                                                        '${o.cantidad} unidades')),
                                                    DataCell(
                                                        Text(o.enfermera)),
                                                    DataCell(Text(o.hora)),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingRequest p;

  const _PendingCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.medicamento} ${p.dosis}',
                  style: GoogleFonts.archivo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAD7A0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${p.cantidad} unidades',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 11,
                      color: kBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enfermera: ${p.enfermera}',
                  style: GoogleFonts.archivoNarrow(fontSize: 13),
                ),
                Text(
                  'Paciente: ${p.paciente}',
                  style: GoogleFonts.archivoNarrow(fontSize: 13),
                ),
                Text(
                  'Hora: ${p.hora}',
                  style: GoogleFonts.archivoNarrow(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  textStyle: GoogleFonts.archivoNarrow(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
                child: const Text('Aprobar'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPureRed,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  textStyle: GoogleFonts.archivoNarrow(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
                child: const Text('Rechazar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PendingRequest {
  final String medicamento;
  final String dosis;
  final String enfermera;
  final String paciente;
  final String habitacion;
  final String hora;
  final int cantidad;

  PendingRequest({
    required this.medicamento,
    required this.dosis,
    required this.enfermera,
    required this.paciente,
    required this.habitacion,
    required this.hora,
    required this.cantidad,
  });
}

class CompletedOrder {
  final String medicamento;
  final int cantidad;
  final String enfermera;
  final String hora;

  CompletedOrder({
    required this.medicamento,
    required this.cantidad,
    required this.enfermera,
    required this.hora,
  });
}

// Datos de ejemplo
final _dummyPending = [
  PendingRequest(
    medicamento: 'Paracetamol',
    dosis: '500mg',
    enfermera: 'Ariel Aquino',
    paciente: 'Marco Antonio Manrique Castro',
    habitacion: '101',
    hora: '10:30 am',
    cantidad: 10,
  ),
  PendingRequest(
    medicamento: 'Paracetamol',
    dosis: '500mg',
    enfermera: 'Ariel Aquino',
    paciente: 'Marco Antonio Manrique Castro',
    habitacion: '101',
    hora: '10:30 am',
    cantidad: 10,
  ),
  PendingRequest(
    medicamento: 'Paracetamol',
    dosis: '500mg',
    enfermera: 'Ariel Aquino',
    paciente: 'Marco Antonio Manrique Castro',
    habitacion: '101',
    hora: '10:30 am',
    cantidad: 10,
  ),
];

final _dummyCompleted = [
  CompletedOrder(
    medicamento: 'Omeprazol 20mg',
    cantidad: 6,
    enfermera: 'Ana Torres',
    hora: '09:15 am',
  ),
  CompletedOrder(
    medicamento: 'Losartán 50mg',
    cantidad: 10,
    enfermera: 'Pedro Ramirez',
    hora: '09:30 am',
  ),
];
