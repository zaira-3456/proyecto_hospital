import 'package:flutter/material.dart';
import 'finance_colors.dart';
import '../models/financial_models.dart';
import 'expense_request_details_dialog.dart';

class ExpenseRequestsTable extends StatelessWidget {
  final List<ExpenseRequest> requests;

  const ExpenseRequestsTable({
    super.key,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solicitudes de gastos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(kFLightBlue), // Light Blue
              columns: const [
                DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Montos', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Área', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tipo de gasto', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Detalles', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: requests.map((request) {
                return DataRow(
                  cells: [
                    DataCell(Text('${request.date.day}/${request.date.month}/${request.date.year}')),
                    DataCell(Text('\$${request.amount.toStringAsFixed(2)}')),
                    DataCell(Text(request.area)),
                    DataCell(Text(request.type)),
                    DataCell(
                      InkWell(
                        onTap: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => ExpenseRequestDetailsDialog(
                              request: request,
                            ),
                          );
                          
                          if (result != null) {
                            // Handle approval or rejection
                            // TODO: Update database with the decision
                          }
                        },
                        child: const Text(
                          'Ver',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


