import 'package:flutter/material.dart';

/// Helper para manejar descarga de PDFs con feedback visual
class PdfDownloadHelper {
  static Future<void> downloadWithFeedback({
    required BuildContext context,
    required String reportTitle,
    required Future<void> Function() downloadFunction,
  }) async {
    // Mostrar loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Ejecutar descarga
      await downloadFunction();
      
      // Cerrar loading
      if (context.mounted) Navigator.pop(context);
      
      // Mostrar éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF generado: $reportTitle'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      // Log completo del error
      print('❌ Error generando PDF:');
      print('  Reporte: $reportTitle');
      print('  Error: $e');
      print('  Stack: $stackTrace');
      
      // Cerrar loading
      if (context.mounted) Navigator.pop(context);
      
      // Mostrar error detallado
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'CERRAR',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        
        // También mostrar dialog con más detalles
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error generando PDF'),
            content: SingleChildScrollView(
              child: Text('Reporte: $reportTitle\n\nError: $e\n\nVerifica console logs para más detalles.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CERRAR'),
              ),
            ],
          ),
        );
      }
    }
  }
}
