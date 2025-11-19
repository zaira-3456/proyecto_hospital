import 'package:flutter/material.dart';
import '../admin/widgets/side_menu.dart';
import '../admin/widgets/stat_card.dart';
import '../admin/widgets/small_stat_card.dart';
import '../admin/widgets/urgent_task_item.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // PANEL IZQUIERDO (MENÚ)
          const SideMenu(),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Panel Administrativo",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Bienvenido, Dr. Carlos Pérez",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),

                  const SizedBox(height: 30),

                  // TARJETAS SUPERIORES
                  Row(
                    children: const [
                      StatCard(
                        title: "Pacientes Registrados",
                        value: "1,250",
                        subtext: "+12%",
                        icon: Icons.people_alt,
                      ),
                      SizedBox(width: 20),
                      StatCard(
                        title: "Citas Hoy",
                        value: "45",
                        subtext: "+5",
                        icon: Icons.calendar_month,
                      ),
                      SizedBox(width: 20),
                      StatCard(
                        title: "Personal Activo",
                        value: "55",
                        subtext: "35 médicos",
                        icon: Icons.medical_services,
                      ),
                      SizedBox(width: 20),
                      StatCard(
                        title: "Alertas",
                        value: "3",
                        subtext: "Urgentes",
                        icon: Icons.error_outline,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // FINANZAS + TAREAS URGENTES
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FINANZAS (AÚN SIN GRÁFICA)
                      Expanded(
                        child: Container(
                          height: 260,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Gráfica de Finanzas (pendiente)",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 30),

                      // TAREAS URGENTES
                      Container(
                        width: 350,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Tareas Urgentes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                  ),

                  const SizedBox(height: 40),

                  // ESTADÍSTICAS PERSONAL
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Estadísticas Personal",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
            ),
          ),
        ],
      ),
    );
  }
}
