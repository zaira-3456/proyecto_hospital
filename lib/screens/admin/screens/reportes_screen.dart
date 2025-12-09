import 'package:flutter/material.dart';
import '../../../services/pdf_service.dart';
import '../../../utils/pdf_download_helper.dart';

/// =============================================================
///   MODELOS — Preparados para BD/API
/// =============================================================
class ReporteItem {
  final String titulo;
  final String fecha;
  final IconData icono;
  final Color color;

  ReporteItem({
    required this.titulo,
    required this.fecha,
    required this.icono,
    required this.color,
  });
}

/// =============================================================
///   SERVICIO — Generación de PDFs reales
/// =============================================================
class ReportesService {
  static Future<void> descargarPDF(String tipo) async {
    try {
      print('📄 Generando PDF: $tipo');
      
      switch (tipo) {
        case 'Reporte de Personal':
          await PdfService.generatePersonnelReport('Último mes');
          break;
        case 'Reporte Financiero':
          await PdfService.generateFinancialReport('Último mes');
          break;
        case 'Reporte de Citas':
          await PdfService.generateAppointmentsReport('Último mes');
          break;
        case 'Inventario':
          await PdfService.generateInventoryReport('Último mes');
          break;
        default:
          print('⚠️ Tipo de reporte desconocido: $tipo');
      }
      
      print('✅ PDF generado exitosamente');
    } catch (e) {
      print('❌ Error generando PDF: $e');
      rethrow;
    }
  }

  static Future<void> generarReporte(String tipo, String periodo) async {
    try {
      print('📄 Generando reporte personalizado: $tipo - $periodo');
      
      switch (tipo) {
        case 'Personal':
          await PdfService.generatePersonnelReport(periodo);
          break;
        case 'Financiero':
          await PdfService.generateFinancialReport(periodo);
          break;
        case 'Citas':
          await PdfService.generateAppointmentsReport(periodo);
          break;
        case 'Inventario':
          await PdfService.generateInventoryReport(periodo);
          break;
        default:
          print('⚠️ Tipo de reporte desconocido: $tipo');
      }
      
      print('✅ Reporte generado exitosamente');
    } catch (e) {
      print('❌ Error generando reporte: $e');
      rethrow;
    }
  }
}

/// =============================================================
///   PANTALLA — Igual al diseño de Figma
/// =============================================================
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  /// --- LISTA DE REPORTES EXISTENTES ---
  final List<ReporteItem> reportes = [
    ReporteItem(
      titulo: "Reporte Financiero",
      fecha: "Último: 10 Oct 2025",
      icono: Icons.receipt_long,
      color: Colors.blue,
    ),
    ReporteItem(
      titulo: "Reporte de Personal",
      fecha: "Último: 10 Oct 2025",
      icono: Icons.group,
      color: Colors.green,
    ),
    ReporteItem(
      titulo: "Reporte de Citas",
      fecha: "Último: 10 Oct 2025",
      icono: Icons.event_note,
      color: Colors.purple,
    ),
    ReporteItem(
      titulo: "Inventario",
      fecha: "Último: 10 Oct 2025",
      icono: Icons.inventory_2,
      color: Colors.orange,
    ),
  ];

  /// --- FORMULARIO ---
  String tipoReporte = "Financiero";
  String periodo = "Último mes";

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reportes y Análisis",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),

          /// =============================================================
          ///     CONTENEDOR PRINCIPAL RESPONSIVO (dos columnas)
          /// =============================================================
          isMobile
              ? Column(
                  children: [
                    _buildListaReportes(),
                    const SizedBox(height: 40),
                    _buildFormulario(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildListaReportes()),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildFormulario()),
                  ],
                ),
        ],
      ),
    );
  }

  /// =============================================================
///     LISTA DE REPORTES A LA IZQUIERDA (con animación)
/// =============================================================
Widget _buildListaReportes() {
  return Column(
    children: List.generate(reportes.length, (index) {
      final r = reportes[index];

      return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 450 + (index * 120)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)), // slide suave hacia arriba
              child: child,
            ),
          );
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xffe5f3ff), // Fondo azul clarito estilo dashboard
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ÍCONO circular con sombra (idéntico a las otras pantallas)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: r.color.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: r.color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(r.icono, color: r.color, size: 26),
              ),

              const SizedBox(width: 18),

              /// TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      r.fecha,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Botón DESCARGAR PDF
                    Builder(
                      builder: (BuildContext ctx) => InkWell(
                        onTap: () => PdfDownloadHelper.downloadWithFeedback(
                          context: ctx,
                          reportTitle: r.titulo,
                          downloadFunction: () => ReportesService.descargarPDF(r.titulo),
                        ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf,
                              size: 18, color: r.color),
                          const SizedBox(width: 6),
                          Text(
                            "Descargar PDF",
                            style: TextStyle(
                              color: r.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}


  /// =============================================================
  ///     FORMULARIO DE REPORTE PERSONALIZADO
  /// =============================================================
  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Generar Reporte Personalizado",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 30),

          /// Tipo de reporte
          const Text("Tipo de Reporte",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _dropdown(
            value: tipoReporte,
            items: const ["Financiero", "Personal", "Citas", "Inventario"],
            onChanged: (v) => setState(() => tipoReporte = v!),
          ),
          const SizedBox(height: 25),

          /// Periodo
          const Text("Periodo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _dropdown(
            value: periodo,
            items: const [
              "Último mes",
              "Últimos 3 meses",
              "Último año",
            ],
            onChanged: (v) => setState(() => periodo = v!),
          ),
          const SizedBox(height: 35),

          /// Botón Generar
          SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (BuildContext ctx) => ElevatedButton(
                onPressed: () => PdfDownloadHelper.downloadWithFeedback(
                  context: ctx,
                  reportTitle: 'Reporte $tipoReporte - $periodo',
                  downloadFunction: () => ReportesService.generarReporte(tipoReporte, periodo),
                ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Generar Reporte",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              ),  // Cierre ElevatedButton
            ),
          ),
        ],
      ),
    );
  }

  /// =============================================================
  ///     DROPDOWN PERSONALIZADO
  /// =============================================================
  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
