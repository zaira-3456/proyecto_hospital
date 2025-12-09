import 'package:flutter/material.dart';
import '../widgets/finance_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/financial_models.dart';
import '../services/database_service.dart';
import '../widgets/finance_sidebar.dart';
import '../widgets/metric_card.dart';
import '../widgets/area_chart_widget.dart';
import '../widgets/urgent_tasks_panel.dart';
import 'income_screen.dart';
import 'expenses_screen.dart';
import 'providers_screen.dart';
import 'reports_screen.dart';
import 'balances_screen.dart';

class FinanceDashboardScreen extends StatefulWidget {
  final User user;

  const FinanceDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  final _databaseService = DatabaseService();
  String _selectedMenu = 'inicio';
  
  FinancialMetrics? _metrics;
  List<AreaData> _incomeData = [];
  List<AreaData> _expensesData = [];
  List<UrgentTask> _urgentTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar datos en paralelo
      final results = await Future.wait([
        _databaseService.getFinancialMetrics(),
        _databaseService.getIncomeByArea(),
        _databaseService.getExpensesByArea(),
        _databaseService.getUrgentTasks(),
      ]);

      final metricsData = results[0] as Map<String, dynamic>;
      final incomeData = results[1] as List<Map<String, dynamic>>;
      final expensesData = results[2] as List<Map<String, dynamic>>;
      final tasksData = results[3] as List<Map<String, dynamic>>;

      setState(() {
        _metrics = FinancialMetrics(
          dailyIncome: metricsData['dailyIncome'],
          dailyExpenses: metricsData['dailyExpenses'],
          cashFlow: metricsData['cashFlow'],
          incomePercentageChange: metricsData['incomePercentageChange'],
          expensesPercentageChange: metricsData['expensesPercentageChange'],
          cashFlowPercentageChange: metricsData['cashFlowPercentageChange'],
        );

        _incomeData = incomeData
            .map((e) => AreaData(
                  areaName: e['areaName'],
                  amount: e['amount'],
                ))
            .toList();

        _expensesData = expensesData
            .map((e) => AreaData(
                  areaName: e['areaName'],
                  amount: e['amount'],
                ))
            .toList();

        _urgentTasks = tasksData
            .map((e) => UrgentTask(
                  description: e['description'],
                  priority: e['priority'],
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

  void _handleLogout() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: isSmallScreen
          ? AppBar(
              title: Text(
                'Panel Financiero',
                style: GoogleFonts.archivo(),
              ),
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
            )
          : null,
      drawer: isSmallScreen
          ? Drawer(
              child: FinanceSidebar(
                selectedMenu: _selectedMenu,
                onMenuSelected: (menu) {
                  setState(() {
                    _selectedMenu = menu;
                  });
                  Navigator.of(context).pop(); // Close drawer
                },
                onLogout: _handleLogout,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for desktop
          if (!isSmallScreen)
            FinanceSidebar(
              selectedMenu: _selectedMenu,
              onMenuSelected: (menu) {
                setState(() {
                  _selectedMenu = menu;
                });
              },
              onLogout: _handleLogout,
            ),

          // Main content
          Expanded(
            child: _selectedMenu == 'ingresos'
                ? IncomeScreen(user: widget.user)
                : _selectedMenu == 'gasto'
                    ? ExpensesScreen(user: widget.user)
                    : _selectedMenu == 'proveedores'
                        ? const ProvidersScreen()
                        : _selectedMenu == 'reportes'
                            ? const ReportsScreen()
                            : _selectedMenu == 'saldos'
                                ? const BalancesScreen()
                                : _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                'Panel Financiero',
                                style: GoogleFonts.archivo(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                                const SizedBox(height: 4),
                              Text(
                                'Bienvenido, ${widget.user.name}',
                                style: GoogleFonts.archivoNarrow(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              ],
                            ),
                            const FinanceLogoCircle(),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Metrics Cards and Urgent Tasks - Fully Responsive
                        if (_metrics != null)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive breakpoints
                              final isExtraWide = constraints.maxWidth >= 1200;
                              final isWide = constraints.maxWidth >= 900;
                              final isTablet = constraints.maxWidth >= 600;

                              if (isExtraWide) {
                                // Extra Wide Screen: All 4 cards in a single row
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: MetricCard(
                                        title: 'Ingresos del día',
                                        amount: _metrics!.dailyIncome,
                                        percentageChange:
                                            _metrics!.incomePercentageChange,
                                        backgroundColor: const Color(0xFFE3F2FD),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: MetricCard(
                                        title: 'Gastos del día',
                                        amount: _metrics!.dailyExpenses,
                                        percentageChange:
                                            _metrics!.expensesPercentageChange,
                                        backgroundColor: const Color(0xFFFCE4EC),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: MetricCard(
                                        title: 'Flujo de caja',
                                        amount: _metrics!.cashFlow,
                                        percentageChange:
                                            _metrics!.cashFlowPercentageChange,
                                        backgroundColor: const Color(0xFFF3E5F5),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: UrgentTasksPanel(tasks: _urgentTasks),
                                    ),
                                  ],
                                );
                              } else if (isWide) {
                                // Wide Screen: 2x2 grid with tasks on the side
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          SizedBox(
                                            width: (constraints.maxWidth * 0.65 - 24) / 2,
                                            child: MetricCard(
                                              title: 'Ingresos del día',
                                              amount: _metrics!.dailyIncome,
                                              percentageChange:
                                                  _metrics!.incomePercentageChange,
                                              backgroundColor: const Color(0xFFE3F2FD),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (constraints.maxWidth * 0.65 - 24) / 2,
                                            child: MetricCard(
                                              title: 'Gastos del día',
                                              amount: _metrics!.dailyExpenses,
                                              percentageChange:
                                                  _metrics!.expensesPercentageChange,
                                              backgroundColor: const Color(0xFFFCE4EC),
                                            ),
                                          ),
                                          SizedBox(
                                            width: (constraints.maxWidth * 0.65 - 24) / 2,
                                            child: MetricCard(
                                              title: 'Flujo de caja',
                                              amount: _metrics!.cashFlow,
                                              percentageChange:
                                                  _metrics!.cashFlowPercentageChange,
                                              backgroundColor: const Color(0xFFF3E5F5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 1,
                                      child: UrgentTasksPanel(tasks: _urgentTasks),
                                    ),
                                  ],
                                );
                              } else if (isTablet) {
                                // Tablet: 2 columns
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MetricCard(
                                            title: 'Ingresos del día',
                                            amount: _metrics!.dailyIncome,
                                            percentageChange:
                                                _metrics!.incomePercentageChange,
                                            backgroundColor: const Color(0xFFE3F2FD),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: MetricCard(
                                            title: 'Gastos del día',
                                            amount: _metrics!.dailyExpenses,
                                            percentageChange:
                                                _metrics!.expensesPercentageChange,
                                            backgroundColor: const Color(0xFFFCE4EC),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MetricCard(
                                            title: 'Flujo de caja',
                                            amount: _metrics!.cashFlow,
                                            percentageChange:
                                                _metrics!.cashFlowPercentageChange,
                                            backgroundColor: const Color(0xFFF3E5F5),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: UrgentTasksPanel(tasks: _urgentTasks),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                // Mobile: Single column
                                return Column(
                                  children: [
                                    MetricCard(
                                      title: 'Ingresos del día',
                                      amount: _metrics!.dailyIncome,
                                      percentageChange:
                                          _metrics!.incomePercentageChange,
                                      backgroundColor: const Color(0xFFE3F2FD),
                                    ),
                                    const SizedBox(height: 16),
                                    MetricCard(
                                      title: 'Gastos del día',
                                      amount: _metrics!.dailyExpenses,
                                      percentageChange:
                                          _metrics!.expensesPercentageChange,
                                      backgroundColor: const Color(0xFFFCE4EC),
                                    ),
                                    const SizedBox(height: 16),
                                    MetricCard(
                                      title: 'Flujo de caja',
                                      amount: _metrics!.cashFlow,
                                      percentageChange:
                                          _metrics!.cashFlowPercentageChange,
                                      backgroundColor: const Color(0xFFF3E5F5),
                                    ),
                                    const SizedBox(height: 16),
                                    UrgentTasksPanel(tasks: _urgentTasks),
                                  ],
                                );
                              }
                            },
                          ),
                        const SizedBox(height: 24),

                        // Charts Section
                        if (isSmallScreen)
                          Column(
                            children: [
                              AreaChartWidget(
                                title: 'Ingresos por Área',
                                data: _incomeData,
                                barColor: Colors.blue.shade600,
                              ),
                              const SizedBox(height: 16),
                              AreaChartWidget(
                                title: 'Gastos por Área',
                                data: _expensesData,
                                barColor: Colors.red.shade600,
                              ),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AreaChartWidget(
                                  title: 'Ingresos por Área',
                                  data: _incomeData,
                                  barColor: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AreaChartWidget(
                                  title: 'Gastos por Área',
                                  data: _expensesData,
                                  barColor: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}



