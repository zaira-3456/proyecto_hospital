import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseño_enfermeria.dart';
import 'widgets/dialogos_enfermeria.dart';

class NursePatientsScreen extends StatelessWidget {
  const NursePatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = _dummyPatients;

    return NurseLayout(
      selectedIndex: 1,
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
                  'Lista de Pacientes',
                  style: GoogleFonts.archivo(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNLightBlue,
                      foregroundColor: kNBlack,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const RegisterTaskDialog(),
                      );
                    },
                    child: const Text('Registrar Tarea'),
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
                                        kNPrimaryBlue,
                                      ),
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
                                            label: Text('Nombre')),
                                        DataColumn(
                                            label:
                                                Text('Habitación')),
                                        DataColumn(
                                            label: Text('Estado')),
                                        DataColumn(
                                            label: Text('Acción')),
                                      ],
                                      rows: patients
                                          .map(
                                            (p) => DataRow(
                                              cells: [
                                                DataCell(Text(p.nombre)),
                                                DataCell(Text(p.habitacion)),
                                                DataCell(_StatusChip(
                                                    critico:
                                                        p.critico)),
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
                                                            PatientDetailsDialog(
                                                          nombre:
                                                              p.nombre,
                                                          edad:
                                                              p.edad,
                                                          habitacion:
                                                              p.habitacion,
                                                          critico: p
                                                              .critico,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      'Ver',
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

class _StatusChip extends StatelessWidget {
  final bool critico;

  const _StatusChip({required this.critico});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: critico ? kNRedAlert : kNGreenDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        critico ? 'Crítico' : 'Estable',
        style: GoogleFonts.archivoNarrow(
          fontSize: 12,
          color: kNWhite,
        ),
      ),
    );
  }
}

class NursePatient {
  final String nombre;
  final String habitacion;
  final String edad;
  final bool critico;

  NursePatient({
    required this.nombre,
    required this.habitacion,
    required this.edad,
    required this.critico,
  });
}

// Datos de ejemplo
final _dummyPatients = <NursePatient>[
  NursePatient(
    nombre: 'Marcos David Chino Cuamacateco',
    habitacion: '101A',
    edad: '24 años',
    critico: true,
  ),
  NursePatient(
    nombre: 'Zaira Sanchez Castro',
    habitacion: '102B',
    edad: '30 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'Jesús Montiel Valdez',
    habitacion: '103A',
    edad: '37 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'Ana María Torres Gonzales',
    habitacion: '104C',
    edad: '41 años',
    critico: true,
  ),
  NursePatient(
    nombre: 'Carlos Ruíz Najera',
    habitacion: '105A',
    edad: '50 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'Sofia Méndez Aragón',
    habitacion: '106B',
    edad: '29 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'José Manuel Astudillo Carranza',
    habitacion: '107B',
    edad: '34 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'Lorena Sánchez Vargas',
    habitacion: '108C',
    edad: '43 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'Marcela Gutiérrez Suarez',
    habitacion: '119A',
    edad: '39 años',
    critico: false,
  ),
  NursePatient(
    nombre: 'Marina Alexandra Hernández',
    habitacion: '110B',
    edad: '32 años',
    critico: false,
  ),
];
