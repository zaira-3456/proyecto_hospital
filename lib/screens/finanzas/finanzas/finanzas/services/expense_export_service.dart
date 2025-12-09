import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

class ExpenseExportService {
  // Colores del diseño consistente
  static final _primaryColor = PdfColor.fromHex('#1d9bf0');
  static final _grayColor = PdfColor.fromHex('#757575');
  
  /// Exportar gastos a PDF
  static Future<void> exportToPdf({
    required List<Map<String, dynamic>> expenseRecords,
    required double totalExpenses,
    required List<Map<String, dynamic>> expensesByArea,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader('Reporte de Gastos', dateStr),
            pw.SizedBox(height: 20),

            // Resumen
            _buildSummarySection([
              {'label': 'Total de Gastos', 'value': '\$${totalExpenses.toStringAsFixed(2)}'},
              {'label': 'Número de Registros', 'value': '${expenseRecords.length}'},
            ]),
            
            pw.SizedBox(height: 30),

            // Gastos por Área
            pw.Text(
              'GASTOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildExpensesByAreaTable(expensesByArea),
            
            pw.SizedBox(height: 30),

            // Detalle de Gastos
            pw.Text(
              'DETALLE DE GASTOS',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildExpensesTable(expenseRecords),
          ];
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    _downloadFile(
      pdfBytes,
      'Reporte_Gastos_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
      'application/pdf',
    );
  }

  static pw.Widget _buildHeader(String title, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#e3f2fd'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'HOSPITAL MANAGEMENT SYSTEM',
            style: pw.TextStyle(
              fontSize: 12,
              color: _grayColor,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Módulo: Finanzas',
                style: pw.TextStyle(fontSize: 12, color: _grayColor),
              ),
              pw.Text(
                'Generado: $dateStr',
                style: pw.TextStyle(fontSize: 12, color: _grayColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(List<Map<String, String>> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _grayColor, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 30,
            runSpacing: 10,
            children: items.map((item) => pw.Container(
              width: 150,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item['label']!,
                    style: pw.TextStyle(fontSize: 10, color: _grayColor),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    item['value']!,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExpensesByAreaTable(List<Map<String, dynamic>> expensesByArea) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Área', isHeader: true),
            _buildTableCell('Monto', isHeader: true),
          ],
        ),
        ...expensesByArea.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item['areaName'] ?? ''),
              _buildTableCell('\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}'),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildExpensesTable(List<Map<String, dynamic>> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('ID', isHeader: true),
            _buildTableCell('Fecha', isHeader: true),
            _buildTableCell('Área', isHeader: true),
            _buildTableCell('Tipo', isHeader: true),
            _buildTableCell('Monto', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
          ],
        ),
        ...expenses.map((expense) {
          final date = expense['date'];
          final dateStr = date != null 
              ? DateFormat('dd/MM/yyyy').format(date)
              : '';
          return pw.TableRow(
            children: [
              _buildTableCell(expense['id'] ?? ''),
              _buildTableCell(dateStr),
              _buildTableCell(expense['area'] ?? ''),
              _buildTableCell(expense['type'] ?? ''),
              _buildTableCell('\$${(expense['amount'] ?? 0.0).toStringAsFixed(2)}'),
              _buildTableCell(expense['status'] ?? ''),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Exportar gastos a Excel
  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> expenseRecords,
    required double totalExpenses,
    required List<Map<String, dynamic>> expensesByArea,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Reporte de Gastos'];
    
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
      fontColorHex: ExcelColor.blue,
    );

    final sectionTitleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromInt(0xFF1d9bf0),
    );

    final tableHeaderStyle = CellStyle(
      bold: true,
      fontSize: 11,
      backgroundColorHex: ExcelColor.fromInt(0xFFe3f2fd),
      horizontalAlign: HorizontalAlign.Center,
    );

    int currentRow = 0;

    // HEADER
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow),
    );
    var headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    headerCell.value = TextCellValue('HOSPITAL MANAGEMENT SYSTEM');
    headerCell.cellStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.fromInt(0xFF757575),
      horizontalAlign: HorizontalAlign.Center,
    );
    currentRow++;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow),
    );
    var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    titleCell.value = TextCellValue('REPORTE DE GASTOS');
    titleCell.cellStyle = headerStyle;
    currentRow++;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow),
    );
    var dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    dateCell.value = TextCellValue('Generado: ${dateFormat.format(now)}');
    dateCell.cellStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.fromInt(0xFF757575),
      horizontalAlign: HorizontalAlign.Center,
    );
    currentRow += 2;

    // RESUMEN
    var summaryTitle = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    summaryTitle.value = TextCellValue('RESUMEN');
    summaryTitle.cellStyle = sectionTitleStyle;
    currentRow++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Total de Gastos:');
    var totalCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    totalCell.value = TextCellValue('\$${totalExpenses.toStringAsFixed(2)}');
    totalCell.cellStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromInt(0xFFf44336),
    );
    currentRow += 2;

    // GASTOS POR ÁREA
    var areaTitle = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    areaTitle.value = TextCellValue('GASTOS POR ÁREA');
    areaTitle.cellStyle = sectionTitleStyle;
    currentRow++;

    var areaHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    areaHeader.value = TextCellValue('Área');
    areaHeader.cellStyle = tableHeaderStyle;
    
    var amountHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    amountHeader.value = TextCellValue('Monto');
    amountHeader.cellStyle = tableHeaderStyle;
    currentRow++;

    for (var item in expensesByArea) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(item['areaName'] ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = TextCellValue('\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}');
      currentRow++;
    }
    currentRow++;

    // DETALLE DE GASTOS
    var detailTitle = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    detailTitle.value = TextCellValue('DETALLE DE GASTOS');
    detailTitle.cellStyle = sectionTitleStyle;
    currentRow++;

    List<String> headers = ['ID', 'Fecha', 'Área', 'Tipo', 'Monto', 'Estado'];
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = tableHeaderStyle;
    }
    currentRow++;

    for (var expense in expenseRecords) {
      final date = expense['date'];
      final dateStr = date != null 
          ? DateFormat('dd/MM/yyyy').format(date)
          : '';
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(expense['id'] ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = TextCellValue(dateStr);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .value = TextCellValue(expense['area'] ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = TextCellValue(expense['type'] ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = TextCellValue('\$${(expense['amount'] ?? 0.0).toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow))
          .value = TextCellValue(expense['status'] ?? '');
      currentRow++;
    }

    // Establecer ancho de columnas
    for (int i = 0; i < 6; i++) {
      sheet.setColumnWidth(i, 20);
    }

    final excelBytes = excel.encode();
    if (excelBytes != null) {
      _downloadFile(
        Uint8List.fromList(excelBytes),
        'Reporte_Gastos_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }

  /// Imprimir gastos
  static Future<void> printExpenses({
    required List<Map<String, dynamic>> expenseRecords,
    required double totalExpenses,
    required List<Map<String, dynamic>> expensesByArea,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader('Reporte de Gastos', dateStr),
            pw.SizedBox(height: 20),
            _buildSummarySection([
              {'label': 'Total de Gastos', 'value': '\$${totalExpenses.toStringAsFixed(2)}'},
              {'label': 'Número de Registros', 'value': '${expenseRecords.length}'},
            ]),
            pw.SizedBox(height: 30),
            pw.Text(
              'GASTOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _buildExpensesByAreaTable(expensesByArea),
            pw.SizedBox(height: 30),
            pw.Text(
              'DETALLE DE GASTOS',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _buildExpensesTable(expenseRecords),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static void _downloadFile(Uint8List bytes, String fileName, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
