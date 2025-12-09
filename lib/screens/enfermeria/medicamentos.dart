import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 NUEVO

import 'widgets/diseno_enfermeria.dart';
import 'widgets/dialogos_enfermeria.dart';

class NurseMedicationsScreen extends StatelessWidget {
  const NurseMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool narrow = constraints.maxWidth < 900;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Enfermera: arleth Danae Aquino Pochotl',
                        style: GoogleFonts.archivo(
                          fontSize: 20,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const NurseLogoCircle(),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Inventario de Medicamentos',
                  style: GoogleFonts.archivo(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, inner) {
                      const maxWidth = 900.0;
                      final visibleWidth =
                          inner.maxWidth < maxWidth ? inner.maxWidth : maxWidth;

                      return Center(
                        child: SizedBox(
                          width: visibleWidth,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: maxWidth,
                                  ),
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('medicamentos_inventario')
                                        .orderBy('nombre')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'Error al cargar medicamentos',
                                            style: GoogleFonts.archivoNarrow(),
                                          ),
                                        );
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child:
                                                CircularProgressIndicator(),
                                          ),
                                        );
                                      }

                                      final docs = snapshot.data!.docs;
                                      if (docs.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'No hay medicamentos registrados en el inventario.',
                                            style: GoogleFonts.archivoNarrow(),
                                          ),
                                        );
                                      }

                                      final meds = docs
                                          .map((d) =>
                                              NurseMed.fromFirestore(d))
                                          .toList();

                                      return DataTableTheme(
                                        data: DataTableThemeData(
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                  kNPrimaryBlue),
                                          headingTextStyle:
                                              GoogleFonts.archivo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: kNWhite,
                                          ),
                                          dataTextStyle:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 14,
                                            color: kNBlack,
                                          ),
                                          headingRowHeight: 40,
                                          dataRowHeight: 44,
                                        ),
                                        child: DataTable(
                                          columnSpacing:
                                              narrow ? 16 : 32,
                                          columns: const [
                                            DataColumn(
                                                label: Text('Medicamento')),
                                            DataColumn(
                                                label: Text('Tipo')),
                                            DataColumn(
                                                label: Text('Dosis')),
                                            DataColumn(
                                                label: Text('Frecuencia')),
                                            DataColumn(
                                                label: Text('Acción')),
                                          ],
                                          rows: meds
                                              .map(
                                                (m) => DataRow(
                                                  cells: [
                                                    DataCell(Text(m.nombre)),
                                                    DataCell(Text(m.tipo)),
                                                    DataCell(Text(m.dosis)),
                                                    DataCell(
                                                      Text(
                                                        m.frecuencia.isEmpty
                                                            ? '—'
                                                            : m.frecuencia,
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                                              minimumSize: const Size(0, 0),
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (_) => const AdministerMedicationDialog(),
                                                              );
                                                            },
                                                            child: Text(
                                                              'Administrar',
                                                              style: GoogleFonts.archivoNarrow(
                                                                fontSize: 13,
                                                                color: kNPrimaryBlue,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                                              minimumSize: const Size(0, 0),
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (_) => RequestMedicationDialog(
                                                                  medicamento: m.nombre,
                                                                  dosis: m.dosis,
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              'Solicitar',
                                                              style: GoogleFonts.archivoNarrow(
                                                                fontSize: 13,
                                                                color: kNGreenDark,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
  }
}

class NurseMed {
  final String nombre;
  final String tipo;
  final String dosis;
  final String frecuencia;

  NurseMed({
    required this.nombre,
    required this.tipo,
    required this.dosis,
    required this.frecuencia,
  });

  factory NurseMed.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NurseMed(
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? '',
      dosis: data['dosis'] ?? '',
      // Puedes guardar "frecuencia" en la receta o en otra colección.
      // Aquí intentamos leerla; si no existe, se muestra "—".
      frecuencia: data['frecuencia'] ?? '',
    );
  }
}

// 🔥 Ya no usamos _dummyMeds, la info viene de Firestore
