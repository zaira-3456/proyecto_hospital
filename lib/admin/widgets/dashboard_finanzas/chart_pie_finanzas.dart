import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPieFinanzas extends StatefulWidget {
  final double salarios;
  final double equipamiento;
  final double medicamentos;
  final double servicios;

  const ChartPieFinanzas({
    super.key,
    required this.salarios,
    required this.equipamiento,
    required this.medicamentos,
    required this.servicios,
  });

  @override
  State<ChartPieFinanzas> createState() => _ChartPieFinanzasState();
}

class _ChartPieFinanzasState extends State<ChartPieFinanzas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _reveal;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _reveal = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: AnimatedBuilder(
        animation: _reveal,
        builder: (context, _) {
          final bool finished = _reveal.value >= 1;

          // ------------------------------
          // GRAFICA DE PASTEL COMPLETA
          // ------------------------------
          Widget chart = PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  value: widget.salarios,
                  color: const Color(0xFF9C8EFF),
                  radius: 115,
                ),
                PieChartSectionData(
                  value: widget.equipamiento,
                  color: const Color(0xFFFFA7A0),
                  radius: 115,
                ),
                PieChartSectionData(
                  value: widget.medicamentos,
                  color: const Color(0xFF3DCCE1),
                  radius: 115,
                ),
                PieChartSectionData(
                  value: widget.servicios,
                  color: const Color(0xFFFFB54C),
                  radius: 115,
                ),
              ],
            ),
          );

          // 🔥 Si la animación terminó → NO aplicar máscara
          if (finished) {
            return chart;
          }

          // 🔥 Si la animación está en curso → aplicar máscara tipo REVEAL SWEEP
          return ClipPath(
            clipper: _CircularSweepRevealClipper(progress: _reveal.value),
            child: chart,
          );
        },
      ),
    );
  }
}

// =============================================================
//                 CLIPPER PARA EFECTO "REVEAL SWEEP"
// =============================================================
class _CircularSweepRevealClipper extends CustomClipper<Path> {
  final double progress;

  _CircularSweepRevealClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width * 1.2; // margen para evitar cortes

    double sweepAngle = 2 * pi * progress;

    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // inicia arriba
      sweepAngle,
      false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _CircularSweepRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
