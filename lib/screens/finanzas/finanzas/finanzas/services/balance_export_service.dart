import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

class BalanceExportService {
  // Colores del diseño consistente con ReportGeneratorService
  static final _primaryColor = PdfColor.fromHex('#1d9bf0');
  static final _grayColor = PdfColor.fromHex('#757575');
  
  /// Exportar saldos a PDF
  static Future<void> exportToPdf({
    required List<Map<String, dynamic>> balancesByArea,
    required double saldoDisponible,
    required double saldoComprometido,
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
            // Header con el mismo estilo
            _buildHeader('Reporte de Saldos', dateStr),
            pw.SizedBox(height: 20),

            // Resumen de saldos
            _buildSummarySection([
              {'label': 'Saldo Disponible', 'value': '\$${saldoDisponible.toStringAsFixed(2)}'},
              {'label': 'Saldo Comprometido', 'value': '\$${saldoComprometido.toStringAsFixed(2)}'},
              {'label': 'Diferencia', 'value': '\$${(saldoDisponible - saldoComprometido).toStringAsFixed(2)}'},
            ]),
            
            pw.SizedBox(height: 30),

            // Tabla de Saldos por Área
            pw.Text(
              'SALDOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildBalancesTable(balancesByArea),
          ];
        },
      ),
    );

    // Generar el PDF como bytes
    final Uint8List pdfBytes = await pdf.save();

    // Descargar el archivo en web
    _downloadFile(
      pdfBytes,
      'Reporte_Saldos_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
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

  static pw.Widget _buildBalancesTable(List<Map<String, dynamic>> balancesByArea) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Área', isHeader: true),
            _buildTableCell('Presupuesto', isHeader: true),
            _buildTableCell('Gastos', isHeader: true),
            _buildTableCell('Diferencia', isHeader: true),
            _buildTableCell('% Ejecución', isHeader: true),
          ],
        ),
        // Data rows
        ...balancesByArea.map((balance) {
          return pw.TableRow(
            children: [
              _buildTableCell(balance['area'] ?? ''),
              _buildTableCell('\$${(balance['presupuesto'] ?? 0.0).toStringAsFixed(2)}'),
              _buildTableCell('\$${(balance['gastos'] ?? 0.0).toStringAsFixed(2)}'),
              _buildTableCell('\$${(balance['diferencia'] ?? 0.0).toStringAsFixed(2)}'),
              _buildTableCell('${balance['ejecucion'] ?? 0}%'),
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

  /// Exportar saldos a Excel
  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> balancesByArea,
    required double saldoDisponible,
    required double saldoComprometido,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Reporte de Saldos'];
    
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
      fontColorHex: ExcelColor.fromInt(0xFF1d9bf0),
    );

    final tableHeaderStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.black,
      backgroundColorHex: ExcelColor.fromInt(0xFFe3f2fd),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final summaryLabelStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.fromInt(0xFF757575),
    );

    int currentRow = 0;

    // HEADER PRINCIPAL
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
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
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
    );
    var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    titleCell.value = TextCellValue('REPORTE DE SALDOS');
    titleCell.cellStyle = headerStyle;
    currentRow++;

    // Fecha de generación
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
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

    // Saldo Disponible
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Saldo Disponible');
    var disponibleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    disponibleCell.value = TextCellValue('\$${saldoDisponible.toStringAsFixed(2)}');
    disponibleCell.cellStyle = CellStyle(fontColorHex: ExcelColor.fromInt(0xFF4caf50));
    currentRow++;

    // Saldo Comprometido
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('Saldo Comprometido');
    var comprometidoCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    comprometidoCell.value = TextCellValue('\$${saldoComprometido.toStringAsFixed(2)}');
    comprometidoCell.cellStyle = CellStyle(fontColorHex: ExcelColor.fromInt(0xFFf44336));
    currentRow += 2;

    // TABLA DE SALDOS POR ÁREA
    var balancesTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    balancesTitleCell.value = TextCellValue('SALDOS POR ÁREA');
    balancesTitleCell.cellStyle = sectionTitleStyle;
    currentRow++;

    // Headers de tabla
    List<String> headers = ['Área', 'Presupuesto', 'Gastos', 'Diferencia', '% Ejecución'];
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = tableHeaderStyle;
    }
    currentRow++;

    // Datos de saldos
    for (var balance in balancesByArea) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(balance['area'] ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = TextCellValue('\$${(balance['presupuesto'] ?? 0.0).toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .value = TextCellValue('\$${(balance['gastos'] ?? 0.0).toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = TextCellValue('\$${(balance['diferencia'] ?? 0.0).toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = TextCellValue('${balance['ejecucion'] ?? 0}%');
      currentRow++;
    }

    // Establecer ancho de columnas
    for (int i = 0; i < 5; i++) {
      sheet.setColumnWidth(i, 25);
    }

    // Guardar el archivo
    final excelBytes = excel.encode();
    if (excelBytes != null) {
      _downloadFile(
        Uint8List.fromList(excelBytes),
        'Reporte_Saldos_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }

  /// Función de impresión
  static Future<void> printBalances({
    required List<Map<String, dynamic>> balancesByArea,
    required double saldoDisponible,
    required double saldoComprometido,
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
            _buildHeader('Reporte de Saldos', dateStr),
            pw.SizedBox(height: 20),
            _buildSummarySection([
              {'label': 'Saldo Disponible', 'value': '\$${saldoDisponible.toStringAsFixed(2)}'},
              {'label': 'Saldo Comprometido', 'value': '\$${saldoComprometido.toStringAsFixed(2)}'},
            ]),
            pw.SizedBox(height: 30),
            pw.Text(
              'SALDOS POR ÁREA',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _buildBalancesTable(balancesByArea),
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
}
