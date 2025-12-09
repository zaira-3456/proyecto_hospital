import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

class ReportGeneratorService {
  // Colores del diseño del administrador
  static final _primaryColor = PdfColor.fromHex('#1d9bf0');
  static final _grayColor = PdfColor.fromHex('#757575');
  
  static Future<void> generatePdfReport({
    required String period,
    required String area,
    required String paymentMethod,
    required String amountRange,
    required double totalIncome,
    required double totalExpenses,
    required double cashFlow,
    required List<Map<String, dynamic>> incomeByArea,
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
            // Header con el mismo estilo del admin
            _buildHeader('Reporte Financiero', period, dateStr),
            pw.SizedBox(height: 20),

            // Resumen con el mismo diseño
            _buildSummarySection([
              {'label': 'Total de Ingresos', 'value': '\$${totalIncome.toStringAsFixed(2)}'},
              {'label': 'Total de Gastos', 'value': '\$${totalExpenses.toStringAsFixed(2)}'},
              {'label': 'Flujo de Caja', 'value': '\$${cashFlow.toStringAsFixed(2)}'},
            ]),
            
            pw.SizedBox(height: 20),

            // Filtros aplicados
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _grayColor, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FILTROS APLICADOS',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Período: $period', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                      pw.Text('Área: $area', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Método de pago: $paymentMethod', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                      pw.Text('Monto: $amountRange', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),

            // Ingresos por Área
            pw.Text(
              'INGRESOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildIncomeTable(incomeByArea),
            
            pw.SizedBox(height: 30),

            // Gastos por Área
            pw.Text(
              'GASTOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildExpensesTable(expensesByArea),
          ];
        },
      ),
    );

    // Generar el PDF como bytes
    final Uint8List pdfBytes = await pdf.save();

    // Descargar el archivo en web
    _downloadFile(
      pdfBytes,
      'Reporte_Financiero_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
      'application/pdf',
    );
  }

  static pw.Widget _buildHeader(String title, String period, String dateStr) {
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
                'Período: $period',
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

  static pw.Widget _buildIncomeTable(List<Map<String, dynamic>> incomeByArea) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Área', isHeader: true),
            _buildTableCell('Monto', isHeader: true),
          ],
        ),
        // Data rows
        ...incomeByArea.map((item) {
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

  static pw.Widget _buildExpensesTable(List<Map<String, dynamic>> expensesByArea) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Área', isHeader: true),
            _buildTableCell('Monto', isHeader: true),
          ],
        ),
        // Data rows
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

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Future<void> generateExcelReport({
    required String period,
    required String area,
    required String paymentMethod,
    required String amountRange,
    required double totalIncome,
    required double totalExpenses,
    required double cashFlow,
    required List<Map<String, dynamic>> incomeByArea,
    required List<Map<String, dynamic>> expensesByArea,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Reporte Financiero'];
    
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Definir estilos reutilizables
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      fontColorHex: ExcelColor.blue,
    );

    final sectionTitleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromInt(0xFF1d9bf0), // Azul primario
    );

    final tableHeaderStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.black,
      backgroundColorHex: ExcelColor.fromInt(0xFFe3f2fd), // Azul claro
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final summaryLabelStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.fromInt(0xFF757575),
    );

    final highlightStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromInt(0xFFe7f3ff),
    );

    int currentRow = 0;

    // ==========================================
    // HEADER PRINCIPAL
    // ==========================================
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow),
    );
    var headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    headerCell.value = TextCellValue('HOSPITAL MANAGEMENT SYSTEM');
    headerCell.cellStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.fromInt(0xFF757575),
      horizontalAlign: HorizontalAlign.Center,
    );
    currentRow++;

    // Título principal
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow),
    );
    var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    titleCell.value = TextCellValue('REPORTE FINANCIERO');
    titleCell.cellStyle = headerStyle;
    currentRow++;

    // Fecha de generación
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow),
    );
    var dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    dateCell.value = TextCellValue('Generado: ${dateFormat.format(now)} | Período: $period');
    dateCell.cellStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.fromInt(0xFF757575),
      horizontalAlign: HorizontalAlign.Center,
    );
    currentRow += 2;

    // ==========================================
    // RESUMEN FINANCIERO
    // ==========================================
    var summaryTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    summaryTitleCell.value = TextCellValue('RESUMEN');
    summaryTitleCell.cellStyle = sectionTitleStyle;
    currentRow += 1;

    // Headers de resumen
    var conceptHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    conceptHeader.value = TextCellValue('Concepto');
    conceptHeader.cellStyle = tableHeaderStyle;
    
    var amountHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    amountHeader.value = TextCellValue('Monto');
    amountHeader.cellStyle = tableHeaderStyle;
    currentRow++;

    // Total de Ingresos
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Total de Ingresos');
    var incomeCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    incomeCell.value = TextCellValue('\$${totalIncome.toStringAsFixed(2)}');
    incomeCell.cellStyle = CellStyle(fontColorHex: ExcelColor.fromInt(0xFF4caf50)); // Verde
    currentRow++;

    // Total de Gastos
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Total de Gastos');
    var expenseCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    expenseCell.value = TextCellValue('\$${totalExpenses.toStringAsFixed(2)}');
    expenseCell.cellStyle = CellStyle(fontColorHex: ExcelColor.fromInt(0xFFf44336)); // Rojo
    currentRow++;

    // Flujo de Caja
    var cashFlowLabelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    cashFlowLabelCell.value = TextCellValue('Flujo de Caja');
    cashFlowLabelCell.cellStyle = highlightStyle;
    
    var cashFlowValueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    cashFlowValueCell.value = TextCellValue('\$${cashFlow.toStringAsFixed(2)}');
    cashFlowValueCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: cashFlow >= 0 ? ExcelColor.fromInt(0xFF4caf50) : ExcelColor.fromInt(0xFFf44336),
      backgroundColorHex: ExcelColor.fromInt(0xFFe7f3ff),
    );
    currentRow += 2;

    // ==========================================
    // FILTROS APLICADOS
    // ==========================================
    var filtersTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    filtersTitleCell.value = TextCellValue('FILTROS APLICADOS');
    filtersTitleCell.cellStyle = sectionTitleStyle;
    currentRow++;
    
    // Filtro: Período
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Período:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .cellStyle = summaryLabelStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = TextCellValue(period);
    currentRow++;
    
    // Filtro: Área
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Área:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .cellStyle = summaryLabelStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = TextCellValue(area);
    currentRow++;
    
    // Filtro: Método de pago
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Método de pago:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .cellStyle = summaryLabelStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = TextCellValue(paymentMethod);
    currentRow++;
    
    // Filtro: Rango de monto
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Rango de monto:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .cellStyle = summaryLabelStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = TextCellValue(amountRange);
    currentRow += 2;

    // ==========================================
    // INGRESOS POR ÁREA
    // ==========================================
    var incomeTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    incomeTitleCell.value = TextCellValue('INGRESOS POR ÁREA');
    incomeTitleCell.cellStyle = sectionTitleStyle;
    currentRow++;

    // Headers de tabla
    var incomeAreaHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    incomeAreaHeader.value = TextCellValue('Área');
    incomeAreaHeader.cellStyle = tableHeaderStyle;
    
    var incomeAmountHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    incomeAmountHeader.value = TextCellValue('Monto');
    incomeAmountHeader.cellStyle = tableHeaderStyle;
    currentRow++;

    // Datos de ingresos
    for (var item in incomeByArea) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(item['areaName'] ?? '');
      var valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      valueCell.value = TextCellValue('\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}');
      valueCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
      );
      currentRow++;
    }
    currentRow++;

    // ==========================================
    // GASTOS POR ÁREA
    // ==========================================
    var expensesTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    expensesTitleCell.value = TextCellValue('GASTOS POR ÁREA');
    expensesTitleCell.cellStyle = sectionTitleStyle;
    currentRow++;

    // Headers de tabla
    var expenseAreaHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    expenseAreaHeader.value = TextCellValue('Área');
    expenseAreaHeader.cellStyle = tableHeaderStyle;
    
    var expenseAmountHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    expenseAmountHeader.value = TextCellValue('Monto');
    expenseAmountHeader.cellStyle = tableHeaderStyle;
    currentRow++;

    // Datos de gastos
    for (var item in expensesByArea) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(item['areaName'] ?? '');
      var valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      valueCell.value = TextCellValue('\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}');
      valueCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
      );
      currentRow++;
    }

    // Establecer ancho de columnas
    for (int i = 0; i < 4; i++) {
      sheet.setColumnWidth(i, 30);
    }

    // Guardar el archivo
    final excelBytes = excel.encode();
    if (excelBytes != null) {
      _downloadFile(
        Uint8List.fromList(excelBytes),
        'Reporte_Financiero_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }

  static Future<void> printReport({
    required String period,
    required String area,
    required String paymentMethod,
    required String amountRange,
    required double totalIncome,
    required double totalExpenses,
    required double cashFlow,
    required List<Map<String, dynamic>> incomeByArea,
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
            // Header con el mismo estilo del admin
            _buildHeader('Reporte Financiero', period, dateStr),
            pw.SizedBox(height: 20),

            // Resumen con el mismo diseño
            _buildSummarySection([
              {'label': 'Total de Ingresos', 'value': '\$${totalIncome.toStringAsFixed(2)}'},
              {'label': 'Total de Gastos', 'value': '\$${totalExpenses.toStringAsFixed(2)}'},
              {'label': 'Flujo de Caja', 'value': '\$${cashFlow.toStringAsFixed(2)}'},
            ]),
            
            pw.SizedBox(height: 20),

            // Filtros aplicados
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _grayColor, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FILTROS APLICADOS',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Período: $period', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                      pw.Text('Área: $area', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Método de pago: $paymentMethod', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                      pw.Text('Monto: $amountRange', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),

            // Ingresos por Área
            pw.Text(
              'INGRESOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildIncomeTable(incomeByArea),
            
            pw.SizedBox(height: 30),

            // Gastos por Área
            pw.Text(
              'GASTOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildExpensesTable(expensesByArea),
          ];
        },
      ),
    );

    // Abrir el diálogo de impresión
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

  // ============================================
  // MÉTODOS ESPECÍFICOS PARA REPORTES DE INGRESOS
  // ============================================

  Future<bool> generateIncomePdfReport({
    required double totalIncome,
    required double totalExpenses,
    required List<Map<String, dynamic>> incomeByArea,
    required List<Map<String, dynamic>> expensesByArea,
    required Map<String, dynamic> filterInfo,
    required String generatedDate,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              _buildHeader('Reporte de Ingresos', filterInfo['period'] ?? '', generatedDate),
              pw.SizedBox(height: 20),

              // Resumen solo de ingresos
              _buildSummarySection([
                {'label': 'Total de Ingresos', 'value': '\$${totalIncome.toStringAsFixed(2)}'},
              ]),
              
              pw.SizedBox(height: 20),

              // Filtros aplicados
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _grayColor, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'FILTROS APLICADOS',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _primaryColor),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Período: ${filterInfo['period']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    pw.Text('Área: ${filterInfo['area']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    pw.Text('Método de pago: ${filterInfo['paymentMethod']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    pw.Text('Monto: ${filterInfo['amountRange']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),

              // Ingresos por Área
              pw.Text(
                'INGRESOS POR ÁREA',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              _buildIncomeTable(incomeByArea),
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      final fileName = 'reporte_ingresos_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _downloadFile(bytes, fileName, 'application/pdf');
      return true;
    } catch (e) {
      print('Error generando PDF de ingresos: $e');
      return false;
    }
  }

  Future<bool> generateIncomeExcelReport({
    required double totalIncome,
    required double totalExpenses,
    required List<Map<String, dynamic>> incomeByArea,
    required List<Map<String, dynamic>> expensesByArea,
    required Map<String, dynamic> filterInfo,
    required String generatedDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Reporte de Ingresos'];

      // Definir estilos
      final headerStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final sectionTitleStyle = CellStyle(
        bold: true,
        fontSize: 12,
        textWrapping: TextWrapping.WrapText,
        fontColorHex: ExcelColor.fromInt(0xff1d9bf0),
      );

      final tableHeaderStyle = CellStyle(
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.fromInt(0xffe3f2fd),
      );

      int currentRow = 0;

      // Header
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
                  CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cell.value = TextCellValue('HOSPITAL MANAGEMENT SYSTEM');
      cell.cellStyle = CellStyle(bold: true, fontSize: 10, horizontalAlign: HorizontalAlign.Center);
      currentRow++;

      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
                  CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cell.value = TextCellValue('REPORTE DE INGRESOS');
      cell.cellStyle = headerStyle;
      currentRow++;

      currentRow++;

      // Resumen
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cell.value = TextCellValue('RESUMEN');
      cell.cellStyle = sectionTitleStyle;
      currentRow++;

      currentRow++;

      // Total de Ingresos
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cell.value = TextCellValue('Total de Ingresos:');
      cell.cellStyle = CellStyle(bold: true);
      
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      cell.value = TextCellValue('\$${totalIncome.toStringAsFixed(2)}');
      cell.cellStyle = CellStyle(bold: true, fontColorHex: ExcelColor.fromInt(0xff4caf50));
      currentRow++;

      currentRow++;

      // Tabla de Ingresos por Área
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cell.value = TextCellValue('INGRESOS POR ÁREA');
      cell.cellStyle = sectionTitleStyle;
      currentRow++;

      currentRow++;

      // Headers de tabla
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      cell.value = TextCellValue('Área');
      cell.cellStyle = tableHeaderStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      cell.value = TextCellValue('Monto');
      cell.cellStyle = tableHeaderStyle;
      currentRow++;

      // Datos de ingresos
      for (var item in incomeByArea) {
        cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        cell.value = TextCellValue(item['areaName'] ?? '');

        cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
        cell.value = TextCellValue('\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}');
        cell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);
        currentRow++;
      }

      // Configurar ancho de columnas
      sheet.setColumnWidth(0, 30);
      sheet.setColumnWidth(1, 20);

      // Guardar y descargar
      final bytes = excel.save();
      if (bytes != null) {
        final fileName = 'reporte_ingresos_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        _downloadFile(Uint8List.fromList(bytes), fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        return true;
      }
      return false;
    } catch (e) {
      print('Error generando Excel de ingresos: $e');
      return false;
    }
  }

  Future<bool> printIncomeReport({
    required double totalIncome,
    required double totalExpenses,
    required List<Map<String, dynamic>> incomeByArea,
    required List<Map<String, dynamic>> expensesByArea,
    required Map<String, dynamic> filterInfo,
    required String generatedDate,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader('Reporte de Ingresos', filterInfo['period'] ?? '', generatedDate),
              pw.SizedBox(height: 20),

              _buildSummarySection([
                {'label': 'Total de Ingresos', 'value': '\$${totalIncome.toStringAsFixed(2)}'},
              ]),
              
              pw.SizedBox(height: 20),

              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _grayColor, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'FILTROS APLICADOS',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _primaryColor),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Período: ${filterInfo['period']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    pw.Text('Área: ${filterInfo['area']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    pw.Text('Método de pago: ${filterInfo['paymentMethod']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                    pw.Text('Monto: ${filterInfo['amountRange']}', style: pw.TextStyle(fontSize: 10, color: _grayColor)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),

              pw.Text(
                'INGRESOS POR ÁREA',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              _buildIncomeTable(incomeByArea),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      return true;
    } catch (e) {
      print('Error imprimiendo reporte de ingresos: $e');
      return false;
    }
  }
}

