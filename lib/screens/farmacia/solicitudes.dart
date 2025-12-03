import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/diseno_farmacia.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PharmacyLayout(
      selectedIndex: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 900;

            // Rango de hoy para "órdenes completadas hoy"
            final now = DateTime.now();
            final startOfDay = DateTime(now.year, now.month, now.day);
            final endOfDay = startOfDay.add(const Duration(days: 1));

            final pendientesQuery = FirebaseFirestore.instance
                .collection('solicitudes_medicamentos')
                .where('estado', isEqualTo: 'pendiente')
                .orderBy('creadaEn', descending: false);

            final completadasQuery = FirebaseFirestore.instance
                .collection('solicitudes_medicamentos')
                .where('estado', isEqualTo: 'completada')
                // si manejas fecha de atención, filtramos por hoy
                .where(
                  'fechaAtendida',
                  isGreaterThanOrEqualTo:
                      Timestamp.fromDate(startOfDay),
                )
                .where(
                  'fechaAtendida',
                  isLessThan: Timestamp.fromDate(endOfDay),
                );

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
                      // LISTA DE PENDIENTES (StreamBuilder)
                      StreamBuilder<QuerySnapshot>(
                        stream: pendientesQuery.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Error al cargar solicitudes pendientes',
                                style: GoogleFonts.archivoNarrow(),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          if (docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'No hay solicitudes pendientes.',
                                style: GoogleFonts.archivoNarrow(),
                              ),
                            );
                          }

                          return Column(
                            children: docs.map((doc) {
                              final p = PendingRequest.fromFirestore(doc);

                              Future<void> aprobar() async {
                                try {
                                  await doc.reference.update({
                                    'estado': 'completada',
                                    'fechaAtendida':
                                        FieldValue.serverTimestamp(),
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Solicitud aprobada correctamente'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error al aprobar solicitud: $e'),
                                    ),
                                  );
                                }
                              }

                              Future<void> rechazar() async {
                                try {
                                  await doc.reference.update({
                                    'estado': 'rechazada',
                                    'fechaAtendida':
                                        FieldValue.serverTimestamp(),
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Solicitud rechazada correctamente'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error al rechazar solicitud: $e'),
                                    ),
                                  );
                                }
                              }

                              return _PendingCard(
                                p: p,
                                onApprove: aprobar,
                                onReject: rechazar,
                              );
                            }).toList(),
                          );
                        },
                      ),

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
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: completadasQuery.snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Error al cargar órdenes completadas',
                                            style: GoogleFonts.archivoNarrow(),
                                          ),
                                        );
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            child:
                                                CircularProgressIndicator(),
                                          ),
                                        );
                                      }

                                      final docs = snapshot.data!.docs;

                                      if (docs.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'No hay órdenes completadas hoy.',
                                            style: GoogleFonts.archivoNarrow(),
                                          ),
                                        );
                                      }

                                      final completadas = docs
                                          .map((d) =>
                                              CompletedOrder.fromFirestore(d))
                                          .toList();

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints:
                                              const BoxConstraints(
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
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15,
                                                color: kBlack,
                                                letterSpacing: 0.8,
                                              ),
                                              dataTextStyle:
                                                  GoogleFonts
                                                      .archivoNarrow(
                                                fontSize: 14,
                                              ),
                                            ),
                                            child: DataTable(
                                              columnSpacing:
                                                  isNarrow ? 16 : 32,
                                              columns: const [
                                                DataColumn(
                                                    label: Text(
                                                        'Medicamento')),
                                                DataColumn(
                                                    label:
                                                        Text('Cantidad')),
                                                DataColumn(
                                                    label:
                                                        Text('Enfermera')),
                                                DataColumn(
                                                    label: Text('Hora')),
                                              ],
                                              rows: completadas
                                                  .map(
                                                    (o) => DataRow(
                                                      cells: [
                                                        DataCell(Text(
                                                            o.medicamento)),
                                                        DataCell(Text(
                                                            '${o.cantidad} unidades')),
                                                        DataCell(Text(
                                                            o.enfermera)),
                                                        DataCell(
                                                            Text(o.hora)),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingCard({
    required this.p,
    required this.onApprove,
    required this.onReject,
  });

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
                if (p.habitacion.isNotEmpty)
                  Text(
                    'Habitación: ${p.habitacion}',
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
                onPressed: onApprove,
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
                onPressed: onReject,
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
  final String id;
  final String medicamento;
  final String dosis;
  final String enfermera;
  final String paciente;
  final String habitacion;
  final String hora;
  final int cantidad;

  PendingRequest({
    required this.id,
    required this.medicamento,
    required this.dosis,
    required this.enfermera,
    required this.paciente,
    required this.habitacion,
    required this.hora,
    required this.cantidad,
  });

  factory PendingRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final medicamento = (data['medicamento'] ?? '').toString();
    final dosis = (data['dosis'] ?? '').toString();
    final enfermera =
        (data['enfermeraNombre'] ?? data['enfermera'] ?? '').toString();
    final paciente =
        (data['pacienteNombre'] ?? data['paciente'] ?? '').toString();
    final habitacion = (data['habitacion'] ?? '').toString();
    final cantidadRaw = data['cantidad'];
    int cantidad;
    if (cantidadRaw is int) {
      cantidad = cantidadRaw;
    } else {
      cantidad = int.tryParse('$cantidadRaw') ?? 0;
    }

    final hora = _formatHora(data['hora'] ?? data['creadaEn']);

    return PendingRequest(
      id: doc.id,
      medicamento: medicamento,
      dosis: dosis,
      enfermera: enfermera,
      paciente: paciente,
      habitacion: habitacion,
      hora: hora,
      cantidad: cantidad,
    );
  }
}

class CompletedOrder {
  final String id;
  final String medicamento;
  final int cantidad;
  final String enfermera;
  final String hora;

  CompletedOrder({
    required this.id,
    required this.medicamento,
    required this.cantidad,
    required this.enfermera,
    required this.hora,
  });

  factory CompletedOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final medicamento = (data['medicamento'] ?? '').toString();
    final enfermera =
        (data['enfermeraNombre'] ?? data['enfermera'] ?? '').toString();
    final cantidadRaw = data['cantidad'];
    int cantidad;
    if (cantidadRaw is int) {
      cantidad = cantidadRaw;
    } else {
      cantidad = int.tryParse('$cantidadRaw') ?? 0;
    }

    final hora = _formatHora(data['fechaAtendida'] ?? data['hora']);

    return CompletedOrder(
      id: doc.id,
      medicamento: medicamento,
      cantidad: cantidad,
      enfermera: enfermera,
      hora: hora,
    );
  }
}

/// Helper para mostrar hora bonita (HH:mm) si viene como Timestamp
String _formatHora(dynamic raw) {
  if (raw is Timestamp) {
    final dt = raw.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  if (raw == null) return '';
  return raw.toString();
}
