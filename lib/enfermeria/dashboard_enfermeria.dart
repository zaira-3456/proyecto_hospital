import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseño_enfermeria.dart';
import 'widgets/dialogos_enfermeria.dart';
import 'pacientes.dart';
import 'medicamentos.dart';

class NurseDashboardScreen extends StatelessWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NurseLayout(
      selectedIndex: 0,
      child: LayoutBuilder(
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
                            builder: (_) => const NurseMedicationsScreen(),
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
      ),
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

class _CardPacientesAsignados extends StatelessWidget {
  const _CardPacientesAsignados();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              '10',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kNRedAlert,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2 En estado crítico',
                  style: GoogleFonts.archivoNarrow(
                    color: kNWhite,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kNGreenDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '8 Estables',
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
  }
}

class _CardAlertas extends StatelessWidget {
  const _CardAlertas();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                  'Medicamento no administrado a Jesús Montiel',
                  style: GoogleFonts.archivoNarrow(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardTareasPendientes extends StatefulWidget {
  const _CardTareasPendientes();

  @override
  State<_CardTareasPendientes> createState() => _CardTareasPendientesState();
}

class _CardTareasPendientesState extends State<_CardTareasPendientes> {
  bool _task1 = false;
  bool _task2 = false;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.archivoNarrow(fontSize: 13);

    return Container(
      decoration: BoxDecoration(
        color: kNLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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

          /// Tarea 1
          Row(
            children: [
              Checkbox(
                value: _task1,
                onChanged: (v) {
                  setState(() => _task1 = v ?? false);
                },
              ),
              Expanded(
                child: Text(
                  'Administrar medicamento a Marcos David Chino Cuamacateco',
                  style: style,
                ),
              ),
            ],
          ),

          /// Tarea 2
          Row(
            children: [
              Checkbox(
                value: _task2,
                onChanged: (v) {
                  setState(() => _task2 = v ?? false);
                },
              ),
              Expanded(
                child: Text(
                  'Cambiar vendaje a Zaira Sánchez Castro',
                  style: style,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _CardEstadoPacientes extends StatelessWidget {
  const _CardEstadoPacientes();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                  painter: _PieChartPainter(),
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
                        'Críticos   2',
                        style: GoogleFonts.archivoNarrow(fontSize: 14),
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
                        'Estables   8',
                        style: GoogleFonts.archivoNarrow(fontSize: 14),
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
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    // 2 críticos (20%) en rojo
    paint.color = kNRedAlert;
    canvas.drawArc(rect, -1.57, 2 * 3.1416 * 0.2, true, paint);

    // 8 estables (80%) en verde
    paint.color = kNGreenDark;
    canvas.drawArc(rect, -1.57 + 2 * 3.1416 * 0.2,
        2 * 3.1416 * 0.8, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
