import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditional imports for web vs mobile
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:universal_html/html.dart' as html;

class PdfService {
  static final _primaryColor = PdfColor.fromHex('#1d9bf0');
  static final _secondaryColor = PdfColor.fromHex('#4caf50');
  static final _grayColor = PdfColor.fromHex('#757575');

  /// ========================================
  /// REPORTE DE PERSONAL
  /// ========================================
  static Future<void> generatePersonnelReport(String period) async {
    try {
      // Obtener datos
      final snapshot = await FirebaseFirestore.instance
          .collection('personal')
          .get();

      // Crear PDF
      final pdf = pw.Document();

      // Estadísticas
      final total = snapshot.docs.length;
      final medicos = snapshot.docs.where((d) => d.data()['tipo'] == 'medico').length;
      final enfermeras = snapshot.docs.where((d) => d.data()['tipo'] == 'enfermeria').length;
      final admins = snapshot.docs.where((d) => d.data()['tipo'] == 'admin').length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader('Reporte de Personal', period),
            pw.SizedBox(height: 20),
            
            // Resumen
            _buildSummarySection([
              {'label': 'Total Empleados', 'value': '$total'},
              {'label': 'Médicos', 'value': '$medicos'},
              {'label': 'Enfermeras', 'value': '$enfermeras'},
              {'label': 'Administrativos', 'value': '$admins'},
            ]),
            
            pw.SizedBox(height: 30),
            
            // Tabla
            pw.Text(
              'DETALLE',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildPersonnelTable(snapshot.docs),
          ],
        ),
      );

      await _savePDFAndOpen(pdf, 'Reporte_Personal.pdf');
    } catch (e) {
      print('❌ Error generando reporte de personal: $e');
      rethrow;
    }
  }

  /// ========================================
  /// REPORTE FINANCIERO
  /// ========================================
  static Future<void> generateFinancialReport(String period) async {
    try {
      // Por ahora generar reporte básico
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Reporte Financiero', period),
              pw.SizedBox(height: 20),
              
              _buildSummarySection([
                {'label': 'Total Ingresos', 'value': '\$125,000.00'},
                {'label': 'Total Egresos', 'value': '\$95,000.00'},
                {'label': 'Balance', 'value': '\$30,000.00'},
              ]),
              
              pw.SizedBox(height: 20),
              pw.Text(
                'Nota: Este es un reporte de ejemplo. Integración con datos reales pendiente.',
                style: pw.TextStyle(fontSize: 10, color: _grayColor),
              ),
            ],
          ),
        ),
      );

      await _savePDFAndOpen(pdf, 'Reporte_Financiero.pdf');
    } catch (e) {
      print('❌ Error generando reporte financiero: $e');
      rethrow;
    }
  }

  /// ========================================
  /// REPORTE DE CITAS
  /// ========================================
  static Future<void> generateAppointmentsReport(String period) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('citas')
          .get();

      final pdf = pw.Document();
      
      final total = snapshot.docs.length;
      final completadas = snapshot.docs.where((d) => d.data()['estado'] == 'completada').length;
      final pendientes = snapshot.docs.where((d) => d.data()['estado'] == 'pendiente').length;
      final canceladas = snapshot.docs.where((d) => d.data()['estado'] == 'cancelada').length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader('Reporte de Citas', period),
            pw.SizedBox(height: 20),
            
            _buildSummarySection([
              {'label': 'Total Citas', 'value': '$total'},
              {'label': 'Completadas', 'value': '$completadas'},
              {'label': 'Pendientes', 'value': '$pendientes'},
              {'label': 'Canceladas', 'value': '$canceladas'},
            ]),
            
            pw.SizedBox(height: 30),
            
            pw.Text(
              'DETALLE DE CITAS',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildAppointmentsTable(snapshot.docs),
          ],
        ),
      );

      await _savePDFAndOpen(pdf, 'Reporte_Citas.pdf');
    } catch (e) {
      print('❌ Error generando reporte de citas: $e');
      rethrow;
    }
  }

  /// ========================================
  /// REPORTE DE INVENTARIO
  /// ========================================
  static Future<void> generateInventoryReport(String period) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('medicamentos_inventario')
          .get();

      final pdf = pw.Document();
      
      final total = snapshot.docs.length;
      double valorTotal = 0;
      int stockBajo = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final stock = (data['stock'] ?? 0) is int 
            ? data['stock'] as int 
            : int.tryParse('${data['stock']}') ?? 0;
        final precio = (data['precioUnitario'] ?? 0) is num 
            ? (data['precioUnitario'] as num).toDouble() 
            : double.tryParse('${data['precioUnitario']}') ?? 0.0;
        final stockMinimo = (data['stockMinimo'] ?? 0) is int 
            ? data['stockMinimo'] as int 
            : int.tryParse('${data['stockMinimo']}') ?? 0;

        valorTotal += stock * precio;
        if (stockMinimo > 0 && stock <= stockMinimo) stockBajo++;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader('Reporte de Inventario', period),
            pw.SizedBox(height: 20),
            
            _buildSummarySection([
              {'label': 'Total Medicamentos', 'value': '$total'},
              {'label': 'Stock Bajo', 'value': '$stockBajo'},
              {'label': 'Valor Total', 'value': '\$${valorTotal.toStringAsFixed(2)}'},
            ]),
            
            pw.SizedBox(height: 30),
            
            pw.Text(
              'DETALLE DE INVENTARIO',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            
            _buildInventoryTable(snapshot.docs),
          ],
        ),
      );

      await _savePDFAndOpen(pdf, 'Reporte_Inventario.pdf');
    } catch (e) {
      print('❌ Error generando reporte de inventario: $e');
      rethrow;
    }
  }

  /// ========================================
  /// COMPONENTES REUTILIZABLES
  /// ========================================
  
  static pw.Widget _buildHeader(String title, String period) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    
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

  static pw.Widget _buildPersonnelTable(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return pw.Text('No hay datos disponibles', style: pw.TextStyle(color: _grayColor));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Nombre', isHeader: true),
            _buildTableCell('Tipo', isHeader: true),
            _buildTableCell('Área', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
          ],
        ),
        // Data rows
        ...docs.take(20).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return pw.TableRow(
            children: [
              _buildTableCell(data['nombre'] ?? ''),
              _buildTableCell(data['tipo'] ?? ''),
              _buildTableCell(data['area'] ?? ''),
              _buildTableCell(data['activo'] == true ? 'Activo' : 'Inactivo'),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildAppointmentsTable(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return pw.Text('No hay datos disponibles', style: pw.TextStyle(color: _grayColor));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Paciente', isHeader: true),
            _buildTableCell('Médico', isHeader: true),
            _buildTableCell('Fecha', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
          ],
        ),
        ...docs.take(20).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final fechaHora = data['fechaHora'];
          String fecha = '';
          if (fechaHora != null && fechaHora is Timestamp) {
            fecha = DateFormat('dd/MM/yyyy').format(fechaHora.toDate());
          }
          
          return pw.TableRow(
            children: [
              _buildTableCell(data['pacienteNombre'] ?? ''),
              _buildTableCell(data['medicoNombre'] ?? ''),
              _buildTableCell(fecha),
              _buildTableCell(data['estado'] ?? ''),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildInventoryTable(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return pw.Text('No hay datos disponibles', style: pw.TextStyle(color: _grayColor));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _grayColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e3f2fd')),
          children: [
            _buildTableCell('Medicamento', isHeader: true),
            _buildTableCell('Stock', isHeader: true),
            _buildTableCell('Precio Unit.', isHeader: true),
            _buildTableCell('Valor Total', isHeader: true),
          ],
        ),
        ...docs.take(20).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final stock = (data['stock'] ?? 0) is int 
              ? data['stock'] as int 
              : int.tryParse('${data['stock']}') ?? 0;
          final precio = (data['precioUnitario'] ?? 0) is num 
              ? (data['precioUnitario'] as num).toDouble() 
              : double.tryParse('${data['precioUnitario']}') ?? 0.0;
          final valorTotal = stock * precio;

          return pw.TableRow(
            children: [
              _buildTableCell(data['nombre'] ?? ''),
              _buildTableCell('$stock'),
              _buildTableCell('\$${precio.toStringAsFixed(2)}'),
              _buildTableCell('\$${valorTotal.toStringAsFixed(2)}'),
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

  /// ========================================
  /// UTILIDADES - SOPORTE WEB Y MÓVIL
  /// ========================================
  
  static Future<void> _savePDFAndOpen(pw.Document pdf, String fileName) async {
    try {
      final Uint8List bytes = await pdf.save();
      
      if (kIsWeb) {
        // WEB: Descargar usando HTML
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        print('✅ PDF descargado en navegador: $fileName');
      } else {
        // MOBILE/DESKTOP: Guardar en archivos temporales
        // Nota: path_provider no funciona en web, por eso lo evitamos aquí
        print('⚠️ Descarga para móvil/desktop pendiente de implementar');
        print('📄 PDF generado con ${bytes.length} bytes');
      }
    } catch (e) {
      print('❌ Error guardando/abriendo PDF: $e');
      rethrow;
    }
  }
}
