import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'datos_finanzas_service.dart';  // correcto, están en la misma carpeta

class ChartLineFinanzas extends StatefulWidget {
  final DatosFinancieros datos;

  const ChartLineFinanzas({super.key, required this.datos});

  @override
  State<ChartLineFinanzas> createState() => _ChartLineFinanzasState();
}

class _ChartLineFinanzasState extends State<ChartLineFinanzas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _anim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutExpo,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> animarSpots(List<double> valores) {
    return valores.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        e.value * _anim.value, // ← ANIMACIÓN LINE-DRAW
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return SizedBox(
          height: 350,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: 250000,

              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 50000,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withOpacity(0.15),
                  strokeWidth: 1,
                ),
              ),

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) {
                      const meses = [
                        "Abril", "Mayo", "Jun", "Jul", "Ago", "Sept"
                      ];
                      return Text(
                        meses[value.toInt()],
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 50000,
                    getTitlesWidget: (value, _) => Text(
                      "${value ~/ 1000}k",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),

              lineBarsData: [
                //===============================
                //     LÍNEA DE EGRESOS
                //===============================
                LineChartBarData(
                  spots: animarSpots(widget.datos.historialEgresos),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) =>
                        FlDotCirclePainter(
                          radius: 4 * _anim.value, // animación del punto
                          color: Colors.blue,
                          strokeWidth: 0,
                        ),
                  ),
                ),

                //===============================
                //     LÍNEA DE INGRESOS
                //===============================
                LineChartBarData(
                  spots: animarSpots(widget.datos.historialIngresos),
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) =>
                        FlDotCirclePainter(
                          radius: 4 * _anim.value,
                          color: Colors.red,
                          strokeWidth: 0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
