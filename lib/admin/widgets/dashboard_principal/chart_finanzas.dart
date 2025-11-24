import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartFinanzas extends StatefulWidget {
  final List<double> ingresos;
  final List<double> egresos;
  final List<String> meses;

  const ChartFinanzas({
    super.key,
    required this.ingresos,
    required this.egresos,
    required this.meses,
  });

  @override
  State<ChartFinanzas> createState() => _ChartFinanzasState();
}

class _ChartFinanzasState extends State<ChartFinanzas>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    controller.forward(); // ← ANIMAR AL CARGAR
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 600;
    final bool isMedium = width >= 600 && width < 1000;
    int step = isSmall ? 2 : 1;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: isSmall ? 260 : 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Finanzas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: widget.ingresos.reduce((a, b) => a > b ? a : b) * 1.2,

                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 50000,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 0.8,
                      ),
                    ),

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index % step != 0) return const SizedBox();
                            if (index < 0 || index >= widget.meses.length) {
                              return const SizedBox();
                            }
                            return Text(
                              widget.meses[index],
                              style: TextStyle(
                                fontSize: isSmall ? 11 : 13,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50000,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text("0");
                            return Text(
                              "${(value / 1000).round()}K",
                              style: TextStyle(
                                fontSize: isSmall ? 11 : 12,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),

                    // ===============================
                    //      ANIMACIÓN REAL DE CARGA
                    // ===============================
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          widget.ingresos.length,
                          (i) => FlSpot(
                            i.toDouble(),
                            widget.ingresos[i] * animation.value,
                          ),
                        ),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.15),
                        ),
                      ),

                      LineChartBarData(
                        spots: List.generate(
                          widget.egresos.length,
                          (i) => FlSpot(
                            i.toDouble(),
                            widget.egresos[i] * animation.value,
                          ),
                        ),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
