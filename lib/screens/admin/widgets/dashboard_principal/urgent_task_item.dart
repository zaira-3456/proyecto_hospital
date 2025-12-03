import 'package:flutter/material.dart';

/// ------------------------------------------------------
///  MODELO (PREPARADO PARA BASE DE DATOS)
/// ------------------------------------------------------
class UrgentTask {
  final String title;
  final String date;
  final String priority; // high, medium, low
  final int? id;         // ← FUTURA BD

  UrgentTask({
    required this.title,
    required this.date,
    required this.priority,
    this.id,
  });
}

/// ------------------------------------------------------
///  ITEM VISUAL INDIVIDUAL
/// ------------------------------------------------------
class UrgentTaskItem extends StatelessWidget {
  final Color color;
  final String title;
  final String date;

  const UrgentTaskItem({
    super.key,
    required this.color,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bolita de color
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12),

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.2)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  WIDGET LISTA (AQUÍ LLEGARÁ LA BD LUEGO)
/// ------------------------------------------------------
class UrgentTaskList extends StatelessWidget {
  final List<UrgentTask> tasks;

  const UrgentTaskList({super.key, required this.tasks});

  Color _priorityColor(String priority) {
    switch (priority) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // --------------------------------------------------
      // 🔥 AQUÍ AJUSTAS LA ALTURA DE LA TARJETA (IMPORTANTE)
      // --------------------------------------------------
      constraints: const BoxConstraints(
        minHeight: 500, // ⬅ CAMBIA AQUÍ para hacerla más grande o pequeña
      ),

      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            "Tareas Urgentes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 15),

          // Lista de tareas
          for (final task in tasks)
            UrgentTaskItem(
              color: _priorityColor(task.priority),
              title: task.title,
              date: task.date,
            ),

          // Espacio extra abajo para que la tarjeta no quede cortada
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  DATOS SIMULADOS — FUTURA BD
/// ------------------------------------------------------
List<UrgentTask> getSimulatedUrgentTasks() {
  return [
    UrgentTask(
      id: 1,
      title: "Revisión de presupuesto",
      date: "Vence: Hoy",
      priority: "high",
    ),
    UrgentTask(
      id: 2,
      title: "Evaluación de Desempeño Trimestral",
      date: "Vence: 1 mes",
      priority: "medium",
    ),
    UrgentTask(
      id: 3,
      title: "Auditoría de Inventario de Farmacia",
      date: "Vence: 1 mes",
      priority: "low",
    ),
  ];
}
