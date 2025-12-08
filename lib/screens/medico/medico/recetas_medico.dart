import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/diseno_medico.dart';
import 'widgets/dialogos_medico.dart';

class DoctorPrescriptionsScreen extends StatefulWidget {
  const DoctorPrescriptionsScreen({super.key});

  @override
  State<DoctorPrescriptionsScreen> createState() =>
      _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState
    extends State<DoctorPrescriptionsScreen> {
  int _tab = 0; // 0 recientes, 1 borradores
  List<PrescriptionItem> _prescriptions = [];
  List<PrescriptionItem> _drafts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    try {
      // Get current username from SharedPreferences (not FirebaseAuth)
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('current_username');
      
      debugPrint('🔍 Iniciando carga de recetas...');
      debugPrint('👤 Usuario actual: ${currentUsername ?? "NO AUTENTICADO"}');
      
      if (currentUsername == null || !mounted) {
        debugPrint('❌ Usuario no autenticado o widget desmontado');
        setState(() => _isLoading = false);
        return;
      }

      // Load prescriptions from Firestore using username as medicoId
      debugPrint('📥 Consultando recetas activas...');
      final prescriptionsSnapshot = await FirebaseFirestore.instance
          .collection('recetas')
          .where('medicoId', isEqualTo: currentUsername)
          .where('estado', isEqualTo: 'activa')
          .get();

      debugPrint('📊 Documentos encontrados (activas): ${prescriptionsSnapshot.docs.length}');
      
      if (prescriptionsSnapshot.docs.isNotEmpty) {
        debugPrint('📄 Primera receta encontrada:');
        final firstDoc = prescriptionsSnapshot.docs.first.data();
        debugPrint('   - medicoId: ${firstDoc['medicoId']}');
        debugPrint('   - pacienteNombre: ${firstDoc['pacienteNombre']}');
        debugPrint('   - estado: ${firstDoc['estado']}');
        debugPrint('   - diagnostico: ${firstDoc['diagnostico']}');
      }

      final List<PrescriptionItem> loadedPrescriptions = prescriptionsSnapshot.docs.map((doc) {
        final data = doc.data();
        final medicamentosRaw = data['medicamentos'] as List<dynamic>? ?? [];
        final medicamentos = medicamentosRaw.map((m) {
          final med = m as Map<String, dynamic>;
          return '${med['nombre']} - ${med['dosis']} - ${med['frecuencia']}';
        }).toList();

        final fecha = data['fecha'] as Timestamp?;
        final fechaStr = fecha != null 
            ? '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}'
            : 'Sin fecha';

        return PrescriptionItem(
          documentId: doc.id,  // Agregar ID del documento
          paciente: data['pacienteNombre'] ?? 'Sin nombre',
          diagnostico: data['diagnostico'] ?? 'Sin diagnóstico',
          fecha: fechaStr,
          medicamentos: medicamentos,
          indicaciones: data['instrucciones'] ?? '',
          timestamp: fecha,
        );
      }).toList();

      // Sort by timestamp descending (most recent first)
      loadedPrescriptions.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      // Load drafts
      debugPrint('📥 Consultando borradores...');
      final draftsSnapshot = await FirebaseFirestore.instance
          .collection('recetas')
          .where('medicoId', isEqualTo: currentUsername)
          .where('estado', isEqualTo: 'borrador')
          .get();

      debugPrint('📊 Documentos encontrados (borradores): ${draftsSnapshot.docs.length}');

      final List<PrescriptionItem> loadedDrafts = draftsSnapshot.docs.map((doc) {
        final data = doc.data();
        final medicamentosRaw = data['medicamentos'] as List<dynamic>? ?? [];
        final medicamentos = medicamentosRaw.map((m) {
          final med = m as Map<String, dynamic>;
          return '${med['nombre']} - ${med['dosis']} - ${med['frecuencia']}';
        }).toList();

        final fecha = data['fecha'] as Timestamp?;
        final fechaStr = fecha != null 
            ? '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}'
            : 'Sin fecha';

        return PrescriptionItem(
          documentId: doc.id,  // Agregar ID del documento
          paciente: data['pacienteNombre'] ?? 'Sin nombre',
          diagnostico: data['diagnostico'] ?? 'Sin diagnóstico',
          fecha: fechaStr,
          medicamentos: medicamentos,
          indicaciones: data['instrucciones'] ?? '',
          timestamp: fecha,
        );
      }).toList();

      // Sort drafts by timestamp descending
      loadedDrafts.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      if (mounted) {
        setState(() {
          _prescriptions = loadedPrescriptions;
          _drafts = loadedDrafts;
          _isLoading = false;
        });
        debugPrint('✅ RESUMEN:');
        debugPrint('   - Recetas activas cargadas: ${loadedPrescriptions.length}');
        debugPrint('   - Borradores cargados: ${loadedDrafts.length}');
        if (loadedPrescriptions.isNotEmpty) {
          debugPrint('   - Primera receta: ${loadedPrescriptions.first.paciente}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR al cargar recetas:');
      debugPrint('   Mensaje: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<PrescriptionItem> _filterList(List<PrescriptionItem> list) {
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((item) =>
      item.paciente.toLowerCase().contains(query) ||
      item.diagnostico.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recientes = _filterList(_prescriptions);
    final borradores = _filterList(_drafts);

    debugPrint('🎨 BUILD - Renderizando UI:');
    debugPrint('   _prescriptions.length: ${_prescriptions.length}');
    debugPrint('   _drafts.length: ${_drafts.length}');
    debugPrint('   recientes (filtradas).length: ${recientes.length}');
    debugPrint('   borradores (filtradas).length: ${borradores.length}');
    debugPrint('   _searchQuery: "$_searchQuery"');
    debugPrint('   _tab: $_tab (0=recientes, 1=borradores)');
    debugPrint('   _isLoading: $_isLoading');

    return Scaffold(
      backgroundColor: kMWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth < 1200 ? constraints.maxWidth : 1200.0;
          final wide = constraints.maxWidth > 1100;

          List<PrescriptionItem> list =
              _tab == 0 ? recientes : borradores;

          debugPrint('   📋 Lista a mostrar: ${list.length} items');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recetas Electrónicas',
                      style: GoogleFonts.archivo(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Genera y gestiona recetas médicas digitales',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buscador + botón
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: kMLightBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar recetas por paciente o diagnóstico...',
                                      hintStyle: GoogleFonts.archivoNarrow(
                                        fontSize: 13,
                                        color: kMGreyText,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: GoogleFonts.archivoNarrow(fontSize: 13),
                                    onChanged: (value) {
                                      setState(() => _searchQuery = value);
                                    },
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMPrimaryBlue,
                              foregroundColor: kMWhite,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NewPrescriptionScreen(),
                                ),
                              );
                              // Reload list after returning
                              _loadPrescriptions();
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nueva Receta'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tabs Recientes/Borradores
                    Row(
                      children: [
                        _prescriptionTab(
                          text: 'Recientes (${recientes.length})',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        const SizedBox(width: 8),
                        _prescriptionTab(
                          text: 'Borradores (${borradores.length})',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lista
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (list.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.description_outlined, size: 64, color: kMGreyText),
                              const SizedBox(height: 16),
                              Text(
                                _tab == 0 ? 'No hay recetas enviadas' : 'No hay borradores',
                                style: GoogleFonts.archivo(
                                  fontSize: 16,
                                  color: kMGreyText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Crea una nueva receta usando el botón "Nueva Receta"',
                                style: GoogleFonts.archivoNarrow(
                                  fontSize: 14,
                                  color: kMGreyText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...list.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PrescriptionCard(
                            item: p,
                            isDraft: _tab == 1,
                            wide: wide,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _prescriptionTab({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kMPrimaryBlue : kMBlue12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              color: selected ? kMWhite : kMBlack,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final PrescriptionItem item;
  final bool isDraft;
  final bool wide;

  const _PrescriptionCard({
    required this.item,
    required this.isDraft,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    Widget statusChip(Color color, String text) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: GoogleFonts.archivoNarrow(fontSize: 11),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: kMLightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kMBlue12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.paciente,
                      style: GoogleFonts.archivo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.diagnostico,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.event, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          item.fecha,
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              statusChip(
                isDraft ? kMYellow : kMBlue15,
                isDraft ? 'Borrador' : 'Enviada',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Medicamentos:',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...item.medicamentos.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $m',
                style: GoogleFonts.archivoNarrow(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.indicaciones,
            style: GoogleFonts.archivoNarrow(fontSize: 13),
          ),
          const SizedBox(height: 10),
          // Solo borradores tienen botones de acción
          if (isDraft)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Botón Completar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMPrimaryBlue,
                    foregroundColor: kMWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: GoogleFonts.archivoNarrow(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    // Convertir borrador a receta activa
                    try {
                      await FirebaseFirestore.instance
                          .collection('recetas')
                          .doc(item.documentId)
                          .update({'estado': 'activa'});
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Receta de ${item.paciente} marcada como activa',
                              style: GoogleFonts.archivoNarrow(),
                            ),
                            backgroundColor: kMGreenBright,
                          ),
                        );
                        // Recargar lista
                        (context.findAncestorStateOfType<_DoctorPrescriptionsScreenState>())?._loadPrescriptions();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: kMRed,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Completar'),
                ),
                // Botón Editar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMPrimaryBlue,
                    foregroundColor: kMWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: GoogleFonts.archivoNarrow(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    // Cargar datos del borrador desde Firestore
                    try {
                      final doc = await FirebaseFirestore.instance
                          .collection('recetas')
                          .doc(item.documentId)
                          .get();
                      
                      if (doc.exists && context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewPrescriptionScreen(
                              prescriptionId: item.documentId,
                              existingData: doc.data(),
                            ),
                          ),
                        );
                        
                        // Recargar lista después de editar
                        if (context.mounted) {
                          (context.findAncestorStateOfType<_DoctorPrescriptionsScreenState>())?._loadPrescriptions();
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cargar borrador: $e'),
                            backgroundColor: kMRed,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Editar'),
                ),
                // Botón Eliminar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMRed,
                    foregroundColor: kMWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: GoogleFonts.archivoNarrow(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          'Eliminar borrador',
                          style: GoogleFonts.archivo(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          '¿Seguro que deseas eliminar este borrador?',
                          style: GoogleFonts.archivoNarrow(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('recetas')
                                    .doc(item.documentId)
                                    .delete();
                                
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Borrador eliminado'),
                                      backgroundColor: kMRed,
                                    ),
                                  );
                                  // Recargar lista
                                  (context.findAncestorStateOfType<_DoctorPrescriptionsScreenState>())?._loadPrescriptions();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: kMRed,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          // Las recetas activas NO tienen botones de acción
        ],
      ),
    );
  }
}

class PrescriptionItem {
  final String documentId;
  final String paciente;
  final String diagnostico;
  final String fecha;
  final List<String> medicamentos;
  final String indicaciones;
  final Timestamp? timestamp;

  const PrescriptionItem({
    required this.documentId,
    required this.paciente,
    required this.diagnostico,
    required this.fecha,
    required this.medicamentos,
    required this.indicaciones,
    this.timestamp,
  });
}
