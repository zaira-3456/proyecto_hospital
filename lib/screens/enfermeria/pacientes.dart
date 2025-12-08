import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 NUEVO

import 'widgets/diseno_enfermeria.dart';
import 'widgets/dialogos_enfermeria.dart';

class NursePatientsScreen extends StatelessWidget {
  const NursePatientsScreen({super.key});

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
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('pacientes')
                                        .orderBy('nombreCompleto')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'Error al cargar pacientes',
                                            style:
                                                GoogleFonts.archivoNarrow(),
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
                                            'No hay pacientes registrados.',
                                            style:
                                                GoogleFonts.archivoNarrow(),
                                          ),
                                        );
                                      }

                                      final patients = docs
                                          .map((d) =>
                                              NursePatient.fromFirestore(d))
                                          .toList();

                                      return DataTableTheme(
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
                                                    DataCell(
                                                        Text(p.nombre)),
                                                    DataCell(
                                                        Text(p.habitacion)),
                                                    DataCell(
                                                      _StatusChip(
                                                        critico:
                                                            p.critico,
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
                                                                builder: (_) => PatientDetailsDialog(
                                                                  nombre: p.nombre,
                                                                  edad: p.edad,
                                                                  habitacion: p.habitacion,
                                                                  critico: p.critico,
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              'Ver',
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
                                                            onPressed: () async {
                                                              final nuevoEstado = p.critico ? 'estable' : 'critico';
                                                              try {
                                                                await FirebaseFirestore.instance
                                                                    .collection('pacientes')
                                                                    .doc(p.id)
                                                                    .update({'estado': nuevoEstado});
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Estado de ${p.nombre} cambiado a ${nuevoEstado.toUpperCase()}',
                                                                      style: GoogleFonts.archivoNarrow(),
                                                                    ),
                                                                    backgroundColor: nuevoEstado == 'critico' 
                                                                        ? kNRedAlert 
                                                                        : kNGreenDark,
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Error al cambiar estado: $e',
                                                                      style: GoogleFonts.archivoNarrow(),
                                                                    ),
                                                                    backgroundColor: kNRedAlert,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Text(
                                                              p.critico ? 'Estabilizar' : 'Marcar Crítico',
                                                              style: GoogleFonts.archivoNarrow(
                                                                fontSize: 13,
                                                                color: p.critico ? kNGreenDark : kNRedAlert,
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
  final String id;
  final String nombre;
  final String habitacion;
  final String edad;
  final bool critico;

  NursePatient({
    required this.id,
    required this.nombre,
    required this.habitacion,
    required this.edad,
    required this.critico,
  });

  factory NursePatient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Nombre
    final nombre = (data['nombreCompleto'] ??
            data['nombre'] ??
            'Paciente sin nombre')
        .toString();

    // Habitación
    final habitacion = (data['habitacion'] ?? '—').toString();

    // Estado -> crítico o estable
    final estadoStr =
        (data['estado'] ?? '').toString().toLowerCase().trim();
    final critico = estadoStr.contains('critico') ||
        estadoStr.contains('crítico') ||
        estadoStr == 'critico' ||
        estadoStr == 'crítico';

    // Edad
    String edadTexto = 'Edad no especificada';

    final fechaNac = data['fechaNacimiento'];
    if (fechaNac is Timestamp) {
      final dob = fechaNac.toDate();
      final now = DateTime.now();
      int years = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        years--;
      }
      if (years >= 0) {
        edadTexto = '$years años';
      }
    } else if (data['edad'] != null) {
      edadTexto = data['edad'].toString();
    }

    return NursePatient(
      id: doc.id,
      nombre: nombre,
      habitacion: habitacion,
      edad: edadTexto,
      critico: critico,
    );
  }
}

// 🔥 Ya no usamos _dummyPatients; los datos vienen de Firestore
