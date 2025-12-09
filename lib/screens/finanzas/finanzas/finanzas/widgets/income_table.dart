import 'package:flutter/material.dart';
import 'finance_colors.dart';
import '../models/financial_models.dart';

class IncomeTable extends StatelessWidget {
  final List<IncomeRecord> records;
  final VoidCallback? onAddIncome;
  final VoidCallback? onExport;

  const IncomeTable({
    super.key,
    required this.records,
    this.onAddIncome,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile: Stack vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro de ingresos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (onAddIncome != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onAddIncome,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Agregar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kFPrimaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(fontSize: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          if (onExport != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onExport,
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Exportar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kFPrimaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(fontSize: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                } else {
                  // Desktop/Tablet: Row
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Registro de ingresos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Row(
                        children: [
                          if (onAddIncome != null)
                            ElevatedButton.icon(
                              onPressed: onAddIncome,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Agregar ingresos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kFPrimaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          if (onExport != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: onExport,
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Exportar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kFPrimaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                kFPrimaryBlue.withValues(alpha: 0.1),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Fecha',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Cliente',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Montos',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Método de pago',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Área',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              rows: records.map((record) {
                return DataRow(
                  cells: [
                    DataCell(Text('${record.date.day}/${record.date.month}/${record.date.year}')),
                    DataCell(Text(record.client)),
                    DataCell(
                      Text(
                        '\$${record.amount.toStringAsFixed(0).replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(record.paymentMethod)),
                    DataCell(Text(record.area)),
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


