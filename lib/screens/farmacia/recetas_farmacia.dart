import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/diseno_farmacia.dart';

class RecetasFarmaciaScreen extends StatelessWidget {
  const RecetasFarmaciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recetas Médicas',
                style: GoogleFonts.archivo(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: kBlack,
                ),
              ),
              const HospitalLogoCircle(),
            ],
          ),
          const SizedBox(height: 20),

          // Banda de título
          Container(
            width: double.infinity,
            color: const Color(0xFFE1E1E1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Text(
              'Recetas Pendientes de Dispensar',
              style: GoogleFonts.archivo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kOrange,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Lista de recetas
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recetas')
                  .where('estado', isEqualTo: 'activa')
                  .orderBy('creadoEn', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar recetas: ${snapshot.error}',
                      style: GoogleFonts.archivoNarrow(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay recetas pendientes de dispensar',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _RecetaCard(
                      doc: doc,
                      data: data,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecetaCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Map<String, dynamic> data;

  const _RecetaCard({
    required this.doc,
    required this.data,
  });

  Future<void> _dispensarReceta(BuildContext context) async {
    try {
      // Obtener medicamentos de la receta
      final medicamentos = data['medicamentos'] as List<dynamic>? ?? [];

      // Verificar stock disponible
      bool stockSuficiente = true;
      final stockProblems = <String>[];

      for (var med in medicamentos) {
        final medicamentoNombre = med['medicamento'] ?? '';
        final cantidadRequerida = (med['cantidad'] ?? 1) as int;

        // Buscar en inventario
        final inventarioSnapshot = await FirebaseFirestore.instance
            .collection('medicamentos_inventario')
            .where('nombre', isEqualTo: medicamentoNombre)
            .limit(1)
            .get();

        if (inventarioSnapshot.docs.isEmpty) {
          stockSuficiente = false;
          stockProblems.add('$medicamentoNombre no encontrado en inventario');
          continue;
        }

        final stockActual = inventarioSnapshot.docs.first.data()['stock'] as int;
        if (stockActual < cantidadRequerida) {
          stockSuficiente = false;
          stockProblems.add(
              '$medicamentoNombre insuficiente (requiere $cantidadRequerida, hay $stockActual)');
        }
      }

      // Si no hay stock suficiente, mostrar error
      if (!stockSuficiente) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Stock Insuficiente',
                style: GoogleFonts.archivo(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No se puede dispensar la receta por:',
                    style: GoogleFonts.archivoNarrow()),
                const SizedBox(height: 8),
                ...stockProblems.map((problem) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text('• $problem',
                          style: GoogleFonts.archivoNarrow(color: Colors.red)),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
        return;
      }

      // Confirmar dispensación
      if (!context.mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirmar Dispensación',
              style: GoogleFonts.archivo(fontWeight: FontWeight.bold)),
          content: Text(
            '¿Desea dispensar esta receta? Se reducirá el stock automáticamente.',
            style: GoogleFonts.archivoNarrow(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              child: const Text('Dispensar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Reducir stock y marcar receta como dispensada
      final batch = FirebaseFirestore.instance.batch();

      for (var med in medicamentos) {
        final medicamentoNombre = med['medicamento'] ?? '';
        final cantidadRequerida = (med['cantidad'] ?? 1) as int;

        final inventarioSnapshot = await FirebaseFirestore.instance
            .collection('medicamentos_inventario')
            .where('nombre', isEqualTo: medicamentoNombre)
            .limit(1)
            .get();

        if (inventarioSnapshot.docs.isNotEmpty) {
          final medicamentoDoc = inventarioSnapshot.docs.first;
          final stockActual = medicamentoDoc.data()['stock'] as int;
          batch.update(medicamentoDoc.reference, {
            'stock': stockActual - cantidadRequerida,
            'actualizadoEn': FieldValue.serverTimestamp(),
          });
        }
      }

      // Actualizar estado de receta
      batch.update(doc.reference, {
        'estado': 'dispensada',
        'fechaDispensacion': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receta dispensada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al dispensar receta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pacienteNombre =
        data['pacienteNombre'] ?? data['paciente'] ?? 'Paciente desconocido';
    final medicoNombre =
        data['medicoNombre'] ?? data['medico'] ?? 'Médico desconocido';
    final medicamentos = data['medicamentos'] as List<dynamic>? ?? [];

    // Formatear fecha
    String fechaStr = 'Sin fecha';
    final creadoEn = data['creadoEn'];
    if (creadoEn is Timestamp) {
      final fecha = creadoEn.toDate();
      fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con paciente y médico
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paciente: $pacienteNombre',
                      style: GoogleFonts.archivo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Médico: $medicoNombre',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kDarkGray,
                      ),
                    ),
                    Text(
                      'Fecha: $fechaStr',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kDarkGray,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _dispensarReceta(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: kWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Dispensar',
                  style: GoogleFonts.archivoNarrow(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Medicamentos
          Text(
            'Medicamentos:',
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 8),

          ...medicamentos.map((med) {
            final medicamento = med['medicamento'] ?? 'Sin nombre';
            final dosis = med['dosis'] ?? '';
            final frecuencia = med['frecuencia'] ?? '';
            final duracion = med['duracion'] ?? '';
            final cantidad = med['cantidad'] ?? 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medicamento,
                          style: GoogleFonts.archivo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kBlack,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimaryBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$cantidad unidades',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (dosis.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dosis: $dosis',
                      style: GoogleFonts.archivoNarrow(
                          fontSize: 12, color: kDarkGray),
                    ),
                  ],
                  if (frecuencia.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Frecuencia: $frecuencia',
                      style: GoogleFonts.archivoNarrow(
                          fontSize: 12, color: kDarkGray),
                    ),
                  ],
                  if (duracion.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Duración: $duracion',
                      style: GoogleFonts.archivoNarrow(
                          fontSize: 12, color: kDarkGray),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
