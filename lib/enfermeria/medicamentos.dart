import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseño_enfermeria.dart';
import 'widgets/dialogos_enfermeria.dart';

class NurseMedicationsScreen extends StatelessWidget {
  const NurseMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meds = _dummyMeds;

    return NurseLayout(
      selectedIndex: 2,
      child: Padding(
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
                                  child: DataTableTheme(
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
                                        DataColumn(label: Text('Tipo')),
                                        DataColumn(label: Text('Dosis')),
                                        DataColumn(
                                            label: Text('Frecuencia')),
                                        DataColumn(label: Text('Acción')),
                                      ],
                                      rows: meds
                                          .map(
                                            (m) => DataRow(
                                              cells: [
                                                DataCell(Text(m.nombre)),
                                                DataCell(Text(m.tipo)),
                                                DataCell(Text(m.dosis)),
                                                DataCell(
                                                    Text(m.frecuencia)),
                                                DataCell(
                                                  TextButton(
                                                    style:
                                                        TextButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.zero,
                                                      minimumSize:
                                                          const Size(0, 0),
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                        context:
                                                            context,
                                                        builder: (_) =>
                                                            const AdministerMedicationDialog(),
                                                      );
                                                    },
                                                    child: Text(
                                                      'Administrar',
                                                      style: GoogleFonts
                                                          .archivoNarrow(
                                                        fontSize: 13,
                                                        color:
                                                            kNPrimaryBlue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                ),
              ],
            );
          },
        ),
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
}

final _dummyMeds = <NurseMed>[
  NurseMed(
    nombre: 'Paracetamol',
    tipo: 'Analgésico',
    dosis: '500mg',
    frecuencia: 'Cada 8 horas',
  ),
  NurseMed(
    nombre: 'Ibuprofeno',
    tipo: 'Antiinflamatorio',
    dosis: '400mg',
    frecuencia: 'Cada 6 horas',
  ),
  NurseMed(
    nombre: 'Amoxicilina',
    tipo: 'Antibiótico',
    dosis: '250mg',
    frecuencia: 'Cada 12 horas',
  ),
  NurseMed(
    nombre: 'Omeprazol',
    tipo: 'Protector gástrico',
    dosis: '20mg',
    frecuencia: 'Cada 24 horas',
  ),
  NurseMed(
    nombre: 'Losartán',
    tipo: 'Antihipertensivo',
    dosis: '50mg',
    frecuencia: 'Cada 24 horas',
  ),
];
