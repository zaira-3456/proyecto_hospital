import 'package:flutter/material.dart';
import '../models/financial_models.dart';

class ExpenseTable extends StatelessWidget {
  final List<ExpenseRecord> records;

  const ExpenseTable({
    super.key,
    required this.records,
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
            'Registro de gastos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF81D4FA)), // Light Blue
              columns: const [
                DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Montos', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Área', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tipo de gasto', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Facturas', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: records.map((record) {
                return DataRow(
                  cells: [
                    DataCell(Text('${record.date.day}/${record.date.month}/${record.date.year}')),
                    DataCell(Text('\$${record.amount.toStringAsFixed(2)}')),
                    DataCell(Text(record.area)),
                    DataCell(Text(record.type)),
                    DataCell(
                      record.hasInvoice
                          ? const Icon(Icons.receipt_long, color: Colors.grey)
                          : const SizedBox(),
                    ),
                    DataCell(
                      Text(
                        record.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: record.status == 'Aprobado' ? Colors.green : Colors.red,
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
