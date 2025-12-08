import 'package:flutter/material.dart';
import '../widgets/finance_colors.dart';
import '../models/financial_models.dart';
import '../services/database_service.dart';
import '../widgets/income_table.dart';
import '../widgets/income_bar_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/add_income_dialog.dart';
import '../widgets/export_dialog.dart';

class IncomeScreen extends StatefulWidget {
  final User user;

  const IncomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _databaseService = DatabaseService();
  
  List<IncomeRecord> _incomeRecords = [];
  List<Map<String, dynamic>> _chartData = [];
  List<Map<String, dynamic>> _areaReportData = [];
  double _dailyIncomeAmount = 0;
  double _dailyIncomeChange = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncomeData();
  }

  Future<void> _loadIncomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _databaseService.getIncomeRecords(),
        _databaseService.getIncomeChartData(),
        _databaseService.getDailyIncomeMetric(),
        _databaseService.getIncomeByArea(),
      ]);

      final recordsData = results[0] as List<Map<String, dynamic>>;
      final chartData = results[1] as List<Map<String, dynamic>>;
      final metricData = results[2] as Map<String, dynamic>;
      final areaData = results[3] as List<Map<String, dynamic>>;

      setState(() {
        _incomeRecords = recordsData
            .map((e) => IncomeRecord(
                  id: e['id'] ?? '',
                  date: e['date'] is DateTime ? e['date'] : DateTime.now(),
                  client: e['client'] ?? '',
                  amount: e['amount']?.toDouble() ?? 0.0,
                  paymentMethod: e['paymentMethod'] ?? '',
                  area: e['area'] ?? '',
                ))
            .toList();

        _chartData = chartData;
        // Map areaName to category for the chart
        _areaReportData = areaData.map((e) => {
          'category': e['areaName'],
          'amount': e['amount'],
        }).toList();
        
        _dailyIncomeAmount = metricData['amount'];
        _dailyIncomeChange = metricData['percentageChange'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddIncomeDialog() async {
    final IncomeRecord? newRecord = await showDialog<IncomeRecord>(
      context: context,
      builder: (context) => const AddIncomeDialog(),
    );

    if (newRecord != null) {
      setState(() {
        _incomeRecords.add(newRecord);
        // Update daily income metric locally for immediate feedback
        if (newRecord.date == 'Hoy' || newRecord.date == DateTime.now().toString().substring(0, 10)) {
           _dailyIncomeAmount += newRecord.amount;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingreso agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showExportDialog() async {
    final ExportOption? selectedOption = await showDialog<ExportOption>(
      context: context,
      builder: (context) => const ExportDialog(),
    );

    if (selectedOption != null) {
      String message = '';
      switch (selectedOption) {
        case ExportOption.excel:
          message = 'Exportando a Excel...';
          break;
        case ExportOption.pdf:
          message = 'Generando PDF...';
          break;
        case ExportOption.print:
          message = 'Enviando a imprimir...';
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kFPrimaryBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width >= 1200;
    final isTablet = screenSize.width >= 600;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ingresos',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // TODO: Implementar filtros
                      },
                      color: kFPrimaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Content Layout
                if (isWide)
                  // Desktop: 2 columns
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: Table + Charts
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            IncomeTable(
                              records: _incomeRecords,
                              onAddIncome: _showAddIncomeDialog,
                              onExport: _showExportDialog,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: IncomeBarChart(
                                    title: 'Ingresos',
                                    data: _chartData,
                                    barColor: kFPrimaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: IncomeBarChart(
                                    title: 'Reporte de Ingresos por Área',
                                    data: _areaReportData,
                                    barColor: kFPrimaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right column: Metric card
                      Expanded(
                        flex: 2,
                        child: MetricCard(
                          title: 'Ingresos del día',
                          amount: _dailyIncomeAmount,
                          percentageChange: _dailyIncomeChange,
                          backgroundColor: kFBgLight,
                        ),
                      ),
                    ],
                  )
                else
                  // Tablet/Mobile: Stacked
                  Column(
                    children: [
                      IncomeTable(
                        records: _incomeRecords,
                        onAddIncome: _showAddIncomeDialog,
                        onExport: _showExportDialog,
                      ),
                      const SizedBox(height: 24),
                      MetricCard(
                        title: 'Ingresos del día',
                        amount: _dailyIncomeAmount,
                        percentageChange: _dailyIncomeChange,
                        backgroundColor: kFBgLight,
                      ),
                      const SizedBox(height: 24),
                      if (isTablet)
                        Row(
                          children: [
                            Expanded(
                              child: IncomeBarChart(
                                title: 'Ingresos',
                                data: _chartData,
                                barColor: kFPrimaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: IncomeBarChart(
                                title: 'Reporte de Ingresos por Área',
                                data: _areaReportData,
                                barColor: kFPrimaryBlue,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            IncomeBarChart(
                              title: 'Ingresos',
                              data: _chartData,
                              barColor: kFPrimaryBlue,
                            ),
                            const SizedBox(height: 16),
                            IncomeBarChart(
                              title: 'Reporte de Ingresos por Área',
                              data: _areaReportData,
                              barColor: kFPrimaryBlue,
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          );
  }
}


