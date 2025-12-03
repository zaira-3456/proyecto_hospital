import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/export_dialog.dart';
import '../models/financial_models.dart';

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key});

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _balancesByArea = [
    {'area': 'Hospital', 'presupuesto': 20000.00, 'gastos': 15000.00, 'diferencia': 5000.00, 'ejecucion': -2.3},
    {'area': 'Consulta', 'presupuesto': 20000.00, 'gastos': 15000.00, 'diferencia': 5000.00, 'ejecucion': -2.3},
    {'area': 'Emergencia', 'presupuesto': 15000.00, 'gastos': 13000.00, 'diferencia': 2000.00, 'ejecucion': -2.3},
    {'area': 'Laboratorio', 'presupuesto': 70000.00, 'gastos': 65000.00, 'diferencia': 5000.00, 'ejecucion': -2.3},
    {'area': 'consulta', 'presupuesto': 35000.00, 'gastos': 30000.00, 'diferencia': 5000.00, 'ejecucion': -2.3},
  ];

  final List<FlSpot> _movementHistory = [
    const FlSpot(0, 3500000),
    const FlSpot(1, 4000000),
    const FlSpot(2, 4200000),
    const FlSpot(3, 4100000),
    const FlSpot(4, 4300000),
    const FlSpot(5, 4500000),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCards(),
                  const SizedBox(height: 32),
                  _buildBalancesTable(),
                  const SizedBox(height: 32),
                  _buildMovementHistoryChart(),
                  const SizedBox(height: 24),
                  _buildProjectionSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saldos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isSmallScreen)
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<ExportOption>(
                    context: context,
                    builder: (context) => const ExportDialog(),
                  );

                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exportando en ${result.name}...')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Exportar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        if (isSmallScreen) {
          return Column(
            children: [
              _buildBalanceCard('Saldo disponible', '\$4,500,000', '+7.5%', Colors.green),
              const SizedBox(height: 16),
              _buildBalanceCard('Saldo comprometido', '\$750,000', '-1.3%', Colors.red),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildBalanceCard('Saldo disponible', '\$4,500,000', '+7.5%', Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildBalanceCard('Saldo comprometido', '\$750,000', '-1.3%', Colors.red)),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(String title, String amount, String percentage, Color percentageColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 14,
              color: percentageColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saldos por Area',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFB3E5FC)),
              columns: const [
                DataColumn(label: Text('Área', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Presupuesto', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Gastos', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Diferencia', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('% Ejecución', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _balancesByArea.map((balance) {
                return DataRow(
                  cells: [
                    DataCell(Text(balance['area'])),
                    DataCell(Text('\$${balance['presupuesto'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${balance['gastos'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${balance['diferencia'].toStringAsFixed(2)}')),
                    DataCell(
                      Text(
                        '${balance['ejecucion']}%',
                        style: TextStyle(
                          color: balance['ejecucion'] < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovementHistoryChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isSmallScreen ? 1 : 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de movimientos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            months[value.toInt()],
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '\$${(value / 1000000).toStringAsFixed(1)}M',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _movementHistory.map((spot) {
                                    return FlSpot(spot.x, spot.y * _animation.value);
                                  }).toList(),
                                  isCurved: true,
                                  color: const Color(0xFF0288D1),
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFF0288D1).withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proyección',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Últimos 6 meses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildWarningItem('⚠️ Saldo por agotarse', Colors.orange),
          const SizedBox(height: 8),
          _buildWarningItem('⚠️ Gasto no registrado', Colors.orange),
          const SizedBox(height: 8),
          _buildWarningItem('🔴 Desviaciones del presupuesto', Colors.red),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
