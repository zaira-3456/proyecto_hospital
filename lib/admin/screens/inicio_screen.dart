import 'package:flutter/material.dart';
import '../widgets/dashboard_principal/stat_card.dart';
import '../widgets/dashboard_principal/urgent_task_item.dart';
import '../widgets/dashboard_principal/small_stat_card.dart';
import '../widgets/dashboard_principal/chart_finanzas.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // === DATOS SIMULADOS — LISTOS PARA BD ===
    final pacientes = "1,250";
    final pacientesCambio = "+12%";

    final citasHoy = "45";
    final citasCambio = "+5";

    final personalActivo = "55";
    final personalDescripcion = "35 médicos";

    final alertas = "3";
    final alertasTipo = "Urgentes";

    // === DATOS GRÁFICA ===
    final ingresos = [120000.0, 135000.0, 150000.0, 145000.0, 160000.0];
    final egresos = [90000.0, 100000.0, 110000.0, 108000.0, 115000.0];
    final meses = ["Ene", "Feb", "Mar", "Abr", "May"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(35),
      child: Column(
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

          const Text(
            "Bienvenido, Dr. Carlos Pérez",
            style: TextStyle(fontSize: 20, color: Colors.black54),
          ),

          const SizedBox(height: 35),

          // === TARJETAS SUPERIORES RESPONSIVAS ===
          LayoutBuilder(builder: (context, constraints) {
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
          }),

          const SizedBox(height: 40),

          // === FINANZAS + TAREAS (RESPONSIVO) ===
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmall = constraints.maxWidth < 900;

              if (isSmall) {
                // 📱 CELULAR
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChartFinanzas(
                      ingresos: ingresos,
                      egresos: egresos,
                      meses: meses,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tareas Urgentes",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 15),
                          UrgentTaskItem(
                            color: Colors.red,
                            title: "Revisión de presupuesto",
                            date: "Vence: Hoy",
                          ),
                          UrgentTaskItem(
                            color: Colors.orange,
                            title: "Evaluación de Desempeño Trimestral",
                            date: "Vence: 1 mes",
                          ),
                          UrgentTaskItem(
                            color: Colors.green,
                            title: "Auditoría de Inventario de Farmacia",
                            date: "Vence: 1 mes",
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // 💻 PC/LAPTOP
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ChartFinanzas(
                      ingresos: ingresos,
                      egresos: egresos,
                      meses: meses,
                    ),
                  ),
                  const SizedBox(width: 30),

                  // ⭐⭐⭐ MODIFICACIÓN EXACTA QUE PEDISTE ⭐⭐⭐
                  SizedBox(
                    width: 360,
                    height: 300, // ⭐ AQUÍ modificas la altura ⭐
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tareas Urgentes",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 15),
                          UrgentTaskItem(
                            color: Colors.red,
                            title: "Revisión de presupuesto",
                            date: "Vence: Hoy",
                          ),
                          UrgentTaskItem(
                            color: Colors.orange,
                            title: "Evaluación de Desempeño Trimestral",
                            date: "Vence: 1 mes",
                          ),
                          UrgentTaskItem(
                            color: Colors.green,
                            title: "Auditoría de Inventario de Farmacia",
                            date: "Vence: 1 mes",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // === ESTADÍSTICAS PERSONAL ===
          Container(
            width: 420,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Estadísticas Personal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                SmallStatCard(label: "Médicos", value: "45"),
                SmallStatCard(label: "Enfermeros", value: "20"),
                SmallStatCard(label: "Administrativos", value: "15"),
              ],
            ),
          ),
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
