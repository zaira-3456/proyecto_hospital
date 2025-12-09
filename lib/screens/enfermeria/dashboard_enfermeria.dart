import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <= NUEVO

import 'widgets/diseno_enfermeria.dart';
import 'widgets/dialogos_enfermeria.dart';
import 'pacientes.dart';
import 'medicamentos.dart';

class NurseDashboardScreen extends StatelessWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final bool narrow = constraints.maxWidth < 1050;

          Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'ENFERMERA',
                            style: GoogleFonts.archivo(
                              fontSize: 18,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ARLETH AQUINO POCHOLT',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.archivoNarrow(
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const NurseLogoCircle(),
                ],
              ),
              const SizedBox(height: 26),

              // Zona superior: tarjetas + gráfico
              if (narrow)
                Column(
                  children: const [
                    _CardPacientesAsignados(),
                    SizedBox(height: 14),
                    _CardAlertas(),
                    SizedBox(height: 14),
                    _CardTareasPendientes(),
                    SizedBox(height: 20),
                    _CardEstadoPacientes(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                      flex: 3,
                      child: _TopCardsColumn(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _CardEstadoPacientes(),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Accesos inferiores
              if (narrow)
                Column(
                  children: [
                    _BigAccessButton(
                      icon: Icons.people,
                      text: 'Ver Pacientes',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NursePatientsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _BigAccessButton(
                      icon: Icons.medical_services_outlined,
                      text: 'Administrar Medicamento',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NurseMedicationsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _BigAccessButton(
                      icon: Icons.pending_actions_outlined,
                      text: 'Registrar Tarea',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const RegisterTaskDialog(),
                        );
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _BigAccessButton(
                        icon: Icons.people,
                        text: 'Ver Pacientes',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NursePatientsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _BigAccessButton(
                        icon: Icons.medical_services_outlined,
                        text: 'Administrar Medicamento',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NurseMedicationsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _BigAccessButton(
                        icon: Icons.pending_actions_outlined,
                        text: 'Registrar Tarea',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                const RegisterTaskDialog(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: content,
            ),
          );
        },
      );
  }
}

class _TopCardsColumn extends StatelessWidget {
  const _TopCardsColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _CardPacientesAsignados(),
        SizedBox(height: 14),
        _CardAlertas(),
        SizedBox(height: 14),
        _CardTareasPendientes(),
      ],
    );
  }
}

/// ─────────────────────────────
///   Pacientes asignados
/// ─────────────────────────────

class _CardPacientesAsignados extends StatelessWidget {
  const _CardPacientesAsignados();

  Future<Map<String, int>> _loadData() async {
    final snap =
        await FirebaseFirestore.instance.collection('pacientes').get();

    int total = snap.docs.length;
    int criticos = 0;
    int estables = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final estado = (data['estado'] ?? '').toString().toLowerCase();
      if (estado.contains('critico') || estado.contains('crítico')) {
        criticos++;
      } else {
        estables++;
      }
    }

    return {
      'total': total,
      'criticos': criticos,
      'estables': estables,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadData(),
      builder: (context, snapshot) {
        int total = 0;
        int criticos = 0;
        int estables = 0;

        if (snapshot.hasData) {
          total = snapshot.data!['total'] ?? 0;
          criticos = snapshot.data!['criticos'] ?? 0;
          estables = snapshot.data!['estables'] ?? 0;
        }

        return Container(
          decoration: BoxDecoration(
            color: kNLightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pacientes Asignados',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '$total',
                  style: GoogleFonts.archivo(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kNRedAlert,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$criticos En estado crítico',
                      style: GoogleFonts.archivoNarrow(
                        color: kNWhite,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kNGreenDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$estables Estables',
                      style: GoogleFonts.archivoNarrow(
                        color: kNWhite,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─────────────────────────────
///   Alertas
/// ─────────────────────────────

class _CardAlertas extends StatelessWidget {
  const _CardAlertas();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tareas_enfermeria')
          .where('estado', isEqualTo: 'pendiente')
          .orderBy('creadaEn', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String mensaje =
            'No hay alertas pendientes por el momento.';

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final paciente = data['pacienteNombre'] ?? 'paciente';
          final desc = data['descripcion'] ?? 'Tarea pendiente';
          mensaje = '$desc a $paciente';
        }

        return Container(
          decoration: BoxDecoration(
            color: kNLightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alertas y notificaciones',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: kNRed, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      mensaje,
                      style: GoogleFonts.archivoNarrow(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─────────────────────────────
///   Tareas pendientes
/// ─────────────────────────────

class _CardTareasPendientes extends StatefulWidget {
  const _CardTareasPendientes();

  @override
  State<_CardTareasPendientes> createState() =>
      _CardTareasPendientesState();
}

class _CardTareasPendientesState extends State<_CardTareasPendientes> {
  Future<void> _toggleTask(DocumentSnapshot doc, bool done) async {
    final newEstado = done ? 'completada' : 'pendiente';
    try {
      await doc.reference.update({'estado': newEstado});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar tarea: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.archivoNarrow(fontSize: 13);

    return Container(
      decoration: BoxDecoration(
        color: kNLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tareas Pendientes',
            style: GoogleFonts.archivo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tareas_enfermeria')
                .orderBy('fechaProgramada')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Error al cargar tareas',
                  style: style,
                );
              }
              if (!snapshot.hasData) {
                return Text(
                  'Cargando tareas...',
                  style: style,
                );
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Text(
                  'No hay tareas registradas.',
                  style: style,
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final desc =
                      data['descripcion'] ?? 'Tarea sin descripción';
                  final paciente = data['pacienteNombre'] ?? '';
                  final estado = (data['estado'] ?? 'pendiente')
                      .toString()
                      .toLowerCase();
                  final done = estado == 'completada';

                  return Row(
                    children: [
                      Checkbox(
                        value: done,
                        onChanged: (v) {
                          _toggleTask(doc, v ?? false);
                        },
                      ),
                      Expanded(
                        child: Text(
                          paciente.isEmpty
                              ? desc
                              : '$desc a $paciente',
                          style: style,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────
///   Estado de pacientes (gráfico)
/// ─────────────────────────────

class _CardEstadoPacientes extends StatelessWidget {
  const _CardEstadoPacientes();

  Future<Map<String, int>> _loadEstado() async {
    final snap =
        await FirebaseFirestore.instance.collection('pacientes').get();

    int criticos = 0;
    int estables = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final estado = (data['estado'] ?? '').toString().toLowerCase();
      if (estado.contains('critico') || estado.contains('crítico')) {
        criticos++;
      } else {
        estables++;
      }
    }

    return {
      'criticos': criticos,
      'estables': estables,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadEstado(),
      builder: (context, snapshot) {
        int criticos = 0;
        int estables = 0;

        if (snapshot.hasData) {
          criticos = snapshot.data!['criticos'] ?? 0;
          estables = snapshot.data!['estables'] ?? 0;
        }

        final total = (criticos + estables).clamp(1, 9999);
        final criticosFrac = criticos / total;
        final establesFrac = estables / total;

        return Container(
          decoration: BoxDecoration(
            color: kNLightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado de Pacientes',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // gráfico simple estilo pastel
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        criticosFrac: criticosFrac,
                        establesFrac: establesFrac,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: kNRedAlert,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Críticos   $criticos',
                            style:
                                GoogleFonts.archivoNarrow(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: kNGreenDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Estables   $estables',
                            style:
                                GoogleFonts.archivoNarrow(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double criticosFrac;
  final double establesFrac;

  const _PieChartPainter({
    required this.criticosFrac,
    required this.establesFrac,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    // Arco críticos
    final startAngle = -1.57; // -90°
    final criticosSweep = 2 * 3.1416 * criticosFrac;
    final establesSweep = 2 * 3.1416 * establesFrac;

    paint.color = kNRedAlert;
    canvas.drawArc(rect, startAngle, criticosSweep, true, paint);

    // Arco estables
    paint.color = kNGreenDark;
    canvas.drawArc(
        rect, startAngle + criticosSweep, establesSweep, true, paint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.criticosFrac != criticosFrac ||
        oldDelegate.establesFrac != establesFrac;
  }
}

class _BigAccessButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _BigAccessButton({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: kNLightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 36, color: kNBlack),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.archivo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
