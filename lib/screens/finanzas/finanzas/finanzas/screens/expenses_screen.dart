import 'package:flutter/material.dart';
import '../widgets/finance_colors.dart';
import '../models/financial_models.dart';
import '../services/database_service.dart';
import '../widgets/expense_table.dart';
import '../widgets/expense_requests_table.dart';
import '../widgets/area_chart_widget.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/export_dialog.dart';
import '../services/expense_export_service.dart';

class ExpensesScreen extends StatefulWidget {
  final User user;

  const ExpensesScreen({
    super.key,
    required this.user,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _databaseService = DatabaseService();
  
  List<ExpenseRecord> _expenseRecords = [];
  List<ExpenseRequest> _expenseRequests = [];
  List<AreaData> _expenseChartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _databaseService.getExpenseRecords(),
        _databaseService.getExpenseRequests(),
        _databaseService.getExpensesByArea(),
      ]);

      final recordsData = results[0] as List<Map<String, dynamic>>;
      final requestsData = results[1] as List<Map<String, dynamic>>;
      final chartData = results[2] as List<Map<String, dynamic>>;

      setState(() {
        _expenseRecords = recordsData
            .map((e) => ExpenseRecord(
                  id: e['id'] ?? '',
                  date: e['date'] is DateTime ? e['date'] : DateTime.now(),
                  amount: e['amount']?.toDouble() ?? 0.0,
                  area: e['area'] ?? '',
                  type: e['type'] ?? '',
                  status: e['status'] ?? '',
                  hasInvoice: e['hasInvoice'] ?? false,
                ))
            .toList();

        _expenseRequests = requestsData
            .map((e) => ExpenseRequest(
                  id: e['id'] ?? '',
                  date: e['date'] is DateTime ? e['date'] : DateTime.now(),
                  amount: e['amount']?.toDouble() ?? 0.0,
                  area: e['area'] ?? '',
                  type: e['type'] ?? '',
                  status: e['status'] ?? 'pending',
                  requestedBy: e['requestedBy'] ?? '',
                  description: e['description'] ?? '',
                  changeHistory: (e['changeHistory'] as List<dynamic>? ?? [])
                      .map((h) => ChangeHistoryEntry(
                            id: h['id'] ?? '',
                            timestamp: h['timestamp'] is DateTime ? h['timestamp'] : DateTime.now(),
                            description: h['description'] ?? '',
                            modifiedBy: h['modifiedBy'] ?? h['user'] ?? '',
                          ))
                      .toList(),
                ))
            .toList();

        _expenseChartData = chartData
            .map((e) => AreaData(
                  areaName: e['areaName'],
                  amount: e['amount'],
                ))
            .toList();
        
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

  Future<void> _showAddExpenseDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result != null) {
      // TODO: Save to database via DatabaseService
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto registrado exitosamente'),
          backgroundColor: kFPrimaryBlue,
        ),
      );
      // Reload data after adding
      _loadData();
    }
  }


  Future<void> _showExportDialog() async {
    final ExportOption? selectedOption = await showDialog<ExportOption>(
      context: context,
      builder: (context) => const ExportDialog(),
    );

    if (selectedOption != null && mounted) {
      try {
        // Calculate total expenses
        final totalExpenses = _expenseRecords.fold<double>(
          0.0,
          (sum, record) => sum + record.amount,
        );

        // Show processing message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generando ${selectedOption.name}...')),
        );

        // Convert expense records to maps
        final expenseRecordsMap = _expenseRecords.map((e) => {
          'id': e.id,
          'date': e.date,
          'amount': e.amount,
          'area': e.area,
          'type': e.type,
          'status': e.status,
        }).toList();

        // Execute export
        switch (selectedOption) {
          case ExportOption.excel:
            await ExpenseExportService.exportToExcel(
              expenseRecords: expenseRecordsMap,
              totalExpenses: totalExpenses,
              expensesByArea: _expenseChartData.map((e) => {
                'areaName': e.areaName,
                'amount': e.amount,
              }).toList(),
            );
            break;
          case ExportOption.pdf:
            await ExpenseExportService.exportToPdf(
              expenseRecords: expenseRecordsMap,
              totalExpenses: totalExpenses,
              expensesByArea: _expenseChartData.map((e) => {
                'areaName': e.areaName,
                'amount': e.amount,
              }).toList(),
            );
            break;
          case ExportOption.print:
            await ExpenseExportService.printExpenses(
              expenseRecords: expenseRecordsMap,
              totalExpenses: totalExpenses,
              expensesByArea: _expenseChartData.map((e) => {
                'areaName': e.areaName,
                'amount': e.amount,
              }).toList(),
            );
            break;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exportación completada'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width >= 1200;
    final isTablet = screenSize.width >= 800;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registro de gastos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const FinanceLogoCircle(),
                  ],
                ),
                const SizedBox(height: 32),

                // Top Section: Table + Chart
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Table Section
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildActionButtons(),
                            const SizedBox(height: 16),
                            ExpenseTable(records: _expenseRecords),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right: Chart
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                             const SizedBox(height: 50), // Align with table top roughly
                             AreaChartWidget(
                              title: 'Reporte de gastos por Área',
                              data: _expenseChartData,
                              barColor: kFPrimaryBlue, // Blue shade
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                      ExpenseTable(records: _expenseRecords),
                      const SizedBox(height: 24),
                      AreaChartWidget(
                        title: 'Reporte de gastos por Área',
                        data: _expenseChartData,
                        barColor: kFPrimaryBlue,
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                // Bottom Section: Requests
                ExpenseRequestsTable(requests: _expenseRequests),
              ],
            ),
          );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _showAddExpenseDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kFPrimaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Registrar gastos'),
              ),
              ElevatedButton(
                onPressed: _showExportDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kFPrimaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Exportar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


