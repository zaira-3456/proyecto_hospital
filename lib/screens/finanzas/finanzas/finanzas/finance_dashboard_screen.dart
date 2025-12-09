import 'package:flutter/material.dart';
import 'models/financial_models.dart';
import '../../../login/services/database_service.dart';
import 'widgets/finance_sidebar.dart';
import 'widgets/finance_colors.dart';
import 'widgets/metric_card.dart';
import 'widgets/area_chart_widget.dart';
import 'widgets/urgent_tasks_panel.dart';
import 'screens/income_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/balances_screen.dart';
import 'screens/providers_screen.dart';
import 'screens/reports_screen.dart';


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
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _getSelectedScreen() {
    switch (_selectedMenu) {
      case 'inicio':
        return _buildDashboardContent();
      case 'ingresos':
        return IncomeScreen(user: widget.user);
      case 'gasto':
        return ExpensesScreen(user: widget.user);
      case 'proveedores':
        return const ProvidersScreen();
      case 'reportes':
        return const ReportsScreen();
      case 'saldos':
        return const BalancesScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 900 ? 16 : 24),
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
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 900 ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bienvenido, ${widget.user.name}',
                    style: TextStyle(
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

          // Metrics Cards and Urgent Tasks
          if (_metrics != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth >= 900;

                if (isWideScreen) {
                  // Desktop: Metrics in row + Urgent tasks on the right
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.5,
                          children: [
                            MetricCard(
                              title: 'Ingresos del día',
                              amount: _metrics!.dailyIncome,
                              percentageChange: _metrics!.incomePercentageChange,
                              backgroundColor: kFBgLight,
                            ),
                            MetricCard(
                              title: 'Gastos del día',
                              amount: _metrics!.dailyExpenses,
                              percentageChange: _metrics!.expensesPercentageChange,
                              backgroundColor: kFBgLight,
                            ),
                            MetricCard(
                              title: 'Flujo de caja',
                              amount: _metrics!.cashFlow,
                              percentageChange: _metrics!.cashFlowPercentageChange,
                              backgroundColor: kFBgLight,
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
                } else {
                  // Mobile/Tablet: Stack vertically
                  return Column(
                    children: [
                      GridView.count(
                        crossAxisCount: constraints.maxWidth < 600 ? 1 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          MetricCard(
                            title: 'Ingresos del día',
                            amount: _metrics!.dailyIncome,
                            percentageChange: _metrics!.incomePercentageChange,
                            backgroundColor: const Color(0xFFE3F2FD),
                          ),
                          MetricCard(
                            title: 'Gastos del día',
                            amount: _metrics!.dailyExpenses,
                            percentageChange: _metrics!.expensesPercentageChange,
                            backgroundColor: const Color(0xFFFCE4EC),
                          ),
                          MetricCard(
                            title: 'Flujo de caja',
                            amount: _metrics!.cashFlow,
                            percentageChange: _metrics!.cashFlowPercentageChange,
                            backgroundColor: const Color(0xFFF3E5F5),
                          ),
                        ],
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
          if (MediaQuery.of(context).size.width < 900)
            Column(
              children: [
                AreaChartWidget(
                  title: 'Ingresos por Área',
                  data: _incomeData,
                  barColor: kFPrimaryBlue,
                ),
                const SizedBox(height: 16),
                AreaChartWidget(
                  title: 'Gastos por Área',
                  data: _expensesData,
                  barColor: kFRed,
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
                    barColor: kFPrimaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AreaChartWidget(
                    title: 'Gastos por Área',
                    data: _expensesData,
                    barColor: kFRed,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: isSmallScreen
          ? AppBar(
              title: const Text('Panel Financiero'),
              backgroundColor: kFPrimaryBlue,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _getSelectedScreen(),
          ),
        ],
      ),
    );
  }
}

