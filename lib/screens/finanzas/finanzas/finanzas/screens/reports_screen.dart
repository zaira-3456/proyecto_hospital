import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/export_dialog.dart';
import '../models/financial_models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Ultimo mes';
  String _selectedArea = 'Todas';
  String _selectedPaymentMethod = 'Todos';
  String _selectedAmount = 'Todos';

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

  // Filtered data based on selections
  Map<String, double> get _filteredIncomeByArea {
    // Base data
    final data = {
      'Farmacia': 650.0,
      'Laboratorio': 450.0,
      'Consultas': 1400.0,
      'Emergencia': 450.0,
    };
    
    if (_selectedArea != 'Todas') {
      return {_selectedArea: data[_selectedArea] ?? 0};
    }
    return data;
  }

  Map<String, double> get _filteredExpensesByArea {
    final data = {
      'Farmacia': 400.0,
      'Laboratorio': 80.0,
      'Consultas': 100.0,
      'Emergencia': 200.0,
    };
    
    if (_selectedArea != 'Todas') {
      return {_selectedArea: data[_selectedArea] ?? 0};
    }
    return data;
  }

  List<FlSpot> get _filteredCashFlow {
    return [
      const FlSpot(0, 10000),
      const FlSpot(1, 9000),
      const FlSpot(2, 8000),
      const FlSpot(3, 7000),
      const FlSpot(4, 6500),
      const FlSpot(5, 8000),
    ];
  }

  double get _totalIncome {
    return _filteredIncomeByArea.values.fold(0, (sum, val) => sum + val);
  }

  double get _totalExpenses {
    return _filteredExpensesByArea.values.fold(0, (sum, val) => sum + val);
  }

  double get _cashFlow {
    return _totalIncome - _totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          _buildHeader(),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metric Cards
                  _buildMetricCards(),
                  const SizedBox(height: 32),

                  // Charts
                  _buildCharts(),
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
        final isSmallScreen = constraints.maxWidth < 900;

        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reportes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilters(isSmallScreen: true),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildGenerateButton(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildFilters(isSmallScreen: false),
            ),
            const SizedBox(width: 16),
            _buildGenerateButton(),
          ],
        );
      },
    );
  }

  Widget _buildFilters({required bool isSmallScreen}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildDropdown('Ultimo mes', _selectedPeriod, ['Ultimo mes', 'Ultimo trimestre', 'Ultimo año'], (val) {
          setState(() => _selectedPeriod = val!);
        }),
        _buildDropdown('Areas', _selectedArea, ['Todas', 'Farmacia', 'Laboratorio', 'Consultas', 'Emergencia'], (val) {
          setState(() => _selectedArea = val!);
        }),
        _buildDropdown('Método de pago', _selectedPaymentMethod, ['Todos', 'Efectivo', 'Tarjeta', 'Transferencia'], (val) {
          setState(() => _selectedPaymentMethod = val!);
        }),
        _buildDropdown('Monto', _selectedAmount, ['Todos', '\$0-\$500', '\$500-\$1000', '\$1000+'], (val) {
          setState(() => _selectedAmount = val!);
        }),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await showDialog<ExportOption>(
          context: context,
          builder: (context) => const ExportDialog(),
        );
        
        if (result != null) {
          // Handle export
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exportando en ${result.name}...')),
            );
          }
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
        'Generar reporte',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetricCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 700;

        if (isSmallScreen) {
          return Column(
            children: [
              _buildMetricCard('Total de ingresos', '\$${_totalIncome.toStringAsFixed(0)}', '+6.7%', Colors.green),
              const SizedBox(height: 16),
              _buildMetricCard('Total de gastos', '\$${_totalExpenses.toStringAsFixed(0)}', '-1.2%', Colors.red),
              const SizedBox(height: 16),
              _buildMetricCard('Flujo de caja', '\$${_cashFlow.toStringAsFixed(0)}', '+0.6%', Colors.green),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildMetricCard('Total de ingresos', '\$${_totalIncome.toStringAsFixed(0)}', '+6.7%', Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Total de gastos', '\$${_totalExpenses.toStringAsFixed(0)}', '-1.2%', Colors.red)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Flujo de caja', '\$${_cashFlow.toStringAsFixed(0)}', '+0.6%', Colors.green)),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, String percentage, Color percentageColor) {
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
            value,
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

  Widget _buildCharts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;

        return Column(
          children: [
            // Income and Cash Flow charts
            isSmallScreen
                ? Column(
                    children: [
                      _buildIncomeChart(),
                      const SizedBox(height: 24),
                      _buildCashFlowChart(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildIncomeChart()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildCashFlowChart()),
                    ],
                  ),
            const SizedBox(height: 24),
            // Expenses chart
            _buildExpensesChart(),
          ],
        );
      },
    );
  }

  Widget _buildIncomeChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingresos por Area',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1500,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final areas = _filteredIncomeByArea.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < areas.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  areas[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 200,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _filteredIncomeByArea.entries.toList().asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value * _animation.value,
                            color: const Color(0xFF0288D1),
                            width: 40,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flujo de caja',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
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
                            const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo'];
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
                            return Text('\$${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _filteredCashFlow.map((spot) {
                          return FlSpot(spot.x, spot.y * _animation.value);
                        }).toList(),
                        isCurved: true,
                        color: const Color(0xFF0288D1),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF0288D1).withOpacity(0.3),
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
    );
  }

  Widget _buildExpensesChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por Area',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 450,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final areas = _filteredExpensesByArea.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < areas.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  areas[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _filteredExpensesByArea.entries.toList().asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value * _animation.value,
                            color: Colors.red,
                            width: 40,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
