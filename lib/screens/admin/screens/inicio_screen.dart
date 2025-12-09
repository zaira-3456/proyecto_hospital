import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tus widgets del dashboard
import '../widgets/dashboard_principal/stat_card.dart';
import '../widgets/dashboard_principal/urgent_task_item.dart';
import '../widgets/dashboard_principal/small_stat_card.dart';
import '../widgets/dashboard_principal/chart_finanzas.dart';

// Database Service
import '../../login/services/database_service.dart';
import '../../../widgets/welcome_message_widget.dart';
import '../widgets/admin_colors.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _dbService.getPatientCount(),
        _dbService.getAppointmentsToday(),
        _dbService.getActivePersonnel(),
        _dbService.getPersonnelByType(),
        _dbService.getUrgentTasks(),
        _dbService.getIncomeByArea(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        // Extracting data from futures
        final patientCount = snapshot.data![0] as int;
        final appointmentsToday = snapshot.data![1] as int;
        final activePersonnel = snapshot.data![2] as int;
        final personnelByType = snapshot.data![3] as Map<String, int>;
        final urgentTasks = snapshot.data![4] as List<Map<String, dynamic>>;
        final incomeByArea = snapshot.data![5] as List<Map<String, dynamic>>;

        // Extract medical staff count
        final medicosCount = personnelByType['medicos'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(35),
          child: _buildDashboardContent(
            patientCount: patientCount,
            appointmentsToday: appointmentsToday,
            activePersonnel: activePersonnel,
            medicosCount: medicosCount,
            urgentTasks: urgentTasks,
            incomeByArea: incomeByArea,
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent({
    required int patientCount,
    required int appointmentsToday,
    required int activePersonnel,
    required int medicosCount,
    required List<Map<String, dynamic>> urgentTasks,
    required List<Map<String, dynamic>> incomeByArea,
  }) {
    // Calculate percentage changes (can be improved with historical data)
    final pacientes = patientCount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    const pacientesCambio = "+12%"; // Placeholder - could calculate from historical data

    final citasHoy = appointmentsToday.toString();
    final citasCambio = "+$appointmentsToday";

    final personalActivo = activePersonnel.toString();
    final personalDescripcion = "$medicosCount médicos";

    final alertas = urgentTasks.length.toString();
    const alertasTipo = "Urgentes";

    // Prepare data for financial chart (using last 5 months of income)
    final ingresos = [120000.0, 135000.0, 150000.0, 145000.0, 160000.0];
    final egresos = [90000.0, 100000.0, 110000.0, 108000.0, 115000.0];
    final meses = ["Ene", "Feb", "Mar", "Abr", "May"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel Administrativo",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                WelcomeMessageWidget(
                  prefix: 'Bienvenido,',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const AdminLogoCircle(),
          ],
        ),

        const SizedBox(height: 35),

        LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;

            if (width >= 1200) {
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: "Pacientes Registrados",
                      value: pacientes,
                      subtext: pacientesCambio,
                      icon: Icons.people_alt,
                      iconBgColor: const Color(0xff4da3ff),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      title: "Citas Hoy",
                      value: citasHoy,
                      subtext: citasCambio,
                      icon: Icons.calendar_month,
                      iconBgColor: const Color(0xff4caf50),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      title: "Personal Activo",
                      value: personalActivo,
                      subtext: personalDescripcion,
                      icon: Icons.medical_services,
                      iconBgColor: const Color(0xffa356e8),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: StatCard(
                      title: "Alertas",
                      value: alertas,
                      subtext: alertasTipo,
                      icon: Icons.error_outline,
                      iconBgColor: const Color(0xffff4d4d),
                    ),
                  ),
                ],
              );
            }

            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                StatCard(
                  title: "Pacientes Registrados",
                  value: pacientes,
                  subtext: pacientesCambio,
                  icon: Icons.people_alt,
                  iconBgColor: const Color(0xff4da3ff),
                ),
                StatCard(
                  title: "Citas Hoy",
                  value: citasHoy,
                  subtext: citasCambio,
                  icon: Icons.calendar_month,
                  iconBgColor: const Color(0xff4caf50),
                ),
                StatCard(
                  title: "Personal Activo",
                  value: personalActivo,
                  subtext: personalDescripcion,
                  icon: Icons.medical_services,
                  iconBgColor: const Color(0xffa356e8),
                ),
                StatCard(
                  title: "Alertas",
                  value: alertas,
                  subtext: alertasTipo,
                  icon: Icons.error_outline,
                  iconBgColor: const Color(0xffff4d4d),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 40),

        LayoutBuilder(builder: (context, constraints) {
          bool isSmall = constraints.maxWidth < 900;

          if (isSmall) {
            return Column(
              children: [
                ChartFinanzas(
                    ingresos: ingresos, egresos: egresos, meses: meses),
                const SizedBox(height: 20),
                _tareasUrgentes(urgentTasks),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: ChartFinanzas(
                    ingresos: ingresos, egresos: egresos, meses: meses),
              ),
              const SizedBox(width: 30),
              SizedBox(width: 360, height: 300, child: _tareasUrgentes(urgentTasks)),
            ],
          );
        }),

        const SizedBox(height: 40),

        Container(
          width: 420,
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Estadísticas Personal",
                style: GoogleFonts.archivo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              SmallStatCard(label: "Médicos", value: medicosCount.toString()),
              SmallStatCard(label: "Enfermeros", value: "20"),
              SmallStatCard(label: "Administrativos", value: "15"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tareasUrgentes(List<Map<String, dynamic>> tasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            "Tareas Urgentes",
            style: GoogleFonts.archivo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          if (tasks.isEmpty)
            const Text("No hay tareas urgentes",
                style: TextStyle(color: Colors.grey)),
          ...tasks.take(3).map((task) {
            // Map priority to color
            Color color = Colors.grey;
            if (task['priority'] == 1) {
              color = Colors.red;
            } else if (task['priority'] == 2) {
              color = Colors.orange;
            } else {
              color = Colors.green;
            }

            return UrgentTaskItem(
              color: color,
              title: task['description'] ?? '',
              date: "Vence: Hoy", // Placeholder - could add date field
            );
          }).toList(),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
