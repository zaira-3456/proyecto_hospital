import 'package:flutter/material.dart';
import 'finance_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/financial_models.dart';

class UrgentTasksPanel extends StatelessWidget {
  final List<UrgentTask> tasks;

  const UrgentTasksPanel({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tareas Urgentes',
            style: GoogleFonts.archivo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No hay tareas urgentes',
                  style: GoogleFonts.archivoNarrow(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(UrgentTask task) {
    IconData icon;
    Color iconColor;

    switch (task.priority) {
      case 1: // High priority
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        break;
      case 2: // Medium priority
        icon = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      default: // Low priority
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.description,
              style: GoogleFonts.archivoNarrow(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


