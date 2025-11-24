import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_medico.dart';
import 'expedientes_medico.dart';
import 'resultados_medico.dart';
import 'recetas_medico.dart'; 


class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DoctorLayout(
      selectedIndex: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 1050;

          Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido de nuevo, Dr.David',
                          style: GoogleFonts.archivo(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resumen de actividades médicas del día',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 14,
                            color: kMGreyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const DoctorLogoCircle(),
                ],
              ),
              const SizedBox(height: 24),

              // Tarjetas de resumen
              if (narrow)
                Column(
                  children: const [
                    _SummaryCard(
                      title: 'Pacientes Activos',
                      value: '248',
                      subtitle: '+ 12% vs mes anterior',
                      icon: Icons.groups,
                      chipColor: kMGreenBright,
                    ),
                    SizedBox(height: 10),
                    _SummaryCard(
                      title: 'Citas de Hoy',
                      value: '18',
                      subtitle: '+ 5% vs mes anterior',
                      icon: Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: 10),
                    _SummaryCard(
                      title: 'Estudios Pendientes',
                      value: '3',
                      subtitle: '+ 2% vs mes anterior',
                      icon: Icons.biotech_outlined,
                      chipColor: kMYellow,
                    ),
                    SizedBox(height: 10),
                    _SummaryCard(
                      title: 'Recetas del mes',
                      value: '77',
                      subtitle: '+ 8% vs mes anterior',
                      icon: Icons.receipt_long_outlined,
                      chipColor: kMBlue15,
                    ),
                  ],
                )
              else
                Row(
                  children: const [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Pacientes Activos',
                        value: '248',
                        subtitle: '+ 12% vs mes anterior',
                        icon: Icons.groups,
                        chipColor: kMGreenBright,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Citas de Hoy',
                        value: '18',
                        subtitle: '+ 5% vs mes anterior',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Estudios Pendientes',
                        value: '3',
                        subtitle: '+ 2% vs mes anterior',
                        icon: Icons.biotech_outlined,
                        chipColor: kMYellow,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Recetas del mes',
                        value: '77',
                        subtitle: '+ 8% vs mes anterior',
                        icon: Icons.receipt_long_outlined,
                        chipColor: kMBlue15,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              Text(
                'Acciones Rápidas',
                style: GoogleFonts.archivo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              if (narrow)
                Column(
                  children: [
                    _QuickAction(
                      icon: Icons.folder_shared_outlined,
                      title: 'Consultar y actualizar expediente',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorRecordsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _QuickAction(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Consultar resultados clínicos',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorResultsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _QuickAction(
                      icon: Icons.receipt_long_outlined,
                      title: 'Generar recetas electrónicas',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DoctorPrescriptionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.folder_shared_outlined,
                        title: 'Consultar y actualizar expediente',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorRecordsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.monitor_heart_outlined,
                        title: 'Consultar resultados clínicos',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorResultsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.receipt_long_outlined,
                        title: 'Generar recetas electrónicas',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DoctorPrescriptionsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
              Text(
                'Actividad Reciente',
                style: GoogleFonts.archivo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Lista de actividad
              _ActivityItem(
                color: kMGreenBright,
                title: 'Nueva cita programada',
                subtitle:
                    'Eduardo Carranza Carranza · Consulta general · 14:30 pm',
                time: 'Hace 5 min',
              ),
              const SizedBox(height: 8),
              _ActivityItem(
                color: kMLightBlue,
                title: 'Resultado de laboratorio disponible',
                subtitle:
                    'Carlos Ruiz · Análisis de sangre completo',
                time: 'Hace 15 min',
              ),
              const SizedBox(height: 8),
              _ActivityItem(
                color: kMBlue15,
                title: 'Receta electrónica enviada',
                subtitle:
                    'Ana Martínez · Antibiótico prescrito',
                time: 'Hace 1 hora',
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? chipColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kMLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kMBlue15,
            child: Icon(icon, color: kMWhite),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.archivo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 12,
                    color: kMGreenDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
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
              color: kMLightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 28, color: kMPrimaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.archivo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kMLightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 13,
                    color: kMGreyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: GoogleFonts.archivoNarrow(
              fontSize: 12,
              color: kMGreyText,
            ),
          ),
        ],
      ),
    );
  }
}
