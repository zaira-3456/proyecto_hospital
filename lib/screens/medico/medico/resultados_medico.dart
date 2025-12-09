import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_medico.dart';
import 'widgets/dialogos_medico.dart';
import '../../login/services/database_service.dart';

class DoctorResultsScreen extends StatefulWidget {
  const DoctorResultsScreen({super.key});

  @override
  State<DoctorResultsScreen> createState() => _DoctorResultsScreenState();
}

class _DoctorResultsScreenState extends State<DoctorResultsScreen> {
  ResultItem? _selected;
  List<ResultItem> _results = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseService();
    // Cargar estudios completados desde Firestore
    final studyRequests = await db.getStudyRequests(estado: 'completado');

    final List<ResultItem> loadedResults = [];

    for (var study in studyRequests) {
      // Formatear fecha
      String fechaStr = 'N/A';
      if (study['fechaCompletado'] != null) {
        final date = (study['fechaCompletado'] as dynamic).toDate();
        fechaStr = '${date.day}/${date.month}/${date.year}';
      } else if (study['fechaSolicitud'] != null) {
        final date = (study['fechaSolicitud'] as dynamic).toDate();
        fechaStr = '${date.day}/${date.month}/${date.year}';
      }

      loadedResults.add(ResultItem(
        id: study['id'] ?? '',
        titulo: study['tipoEstudio'] ?? 'Estudio',
        paciente: study['pacienteNombre'] ?? 'Sin nombre',
        fecha: fechaStr,
        estado: 'Completado',
        observaciones: study['observaciones'] ?? '',
        prioridad: study['prioridad'] ?? 'normal',
        medicoNombre: study['medicoNombre'] ?? '',
      ));
    }

    if (mounted) {
      setState(() {
        _results = loadedResults;
        if (_results.isNotEmpty) {
          _selected = _results.first;
        }
        _isLoading = false;
      });
    }
  }

  List<ResultItem> get _filteredResults {
    if (_searchQuery.isEmpty) return _results;
    final query = _searchQuery.toLowerCase();
    return _results.where((item) =>
      item.paciente.toLowerCase().contains(query) ||
      item.titulo.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 1100;

          // ================= COLUMNA IZQUIERDA: LISTA =================
          Widget listColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultados Clínicos',
                style: GoogleFonts.archivo(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consultar los resultados',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 14,
                  color: kMGreyText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: kMLightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por paciente o tipo de estudio...',
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
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_filteredResults.isEmpty)
                Center(
                  child: Text(
                    _searchQuery.isNotEmpty 
                      ? 'No se encontraron resultados para "$_searchQuery"'
                      : 'No hay resultados disponibles',
                    style: GoogleFonts.archivoNarrow(color: kMGreyText),
                  ),
                )
              else
                ..._filteredResults.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ResultCard(
                      item: r,
                      selected: _selected == r,
                      onTap: () => setState(() => _selected = r),
                    ),
                  ),
                ),
            ],
          );

          // ================= COLUMNA DETALLE =================
          Widget detailColumn;
          if (_selected == null) {
            detailColumn = Center(
              child: Text(
                'Selecciona un resultado',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 16,
                  color: kMGreyText,
                ),
              ),
            );
          } else {
            detailColumn = _ResultDetail(item: _selected!);
          }

          // ============== LAYOUT MÓVIL / TABLET ==============
          if (!wide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  listColumn,
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kMLightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: detailColumn,
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMPrimaryBlue,
                        foregroundColor: kMWhite,
                      ),
                      onPressed: () {
                        if (_selected != null) {
                          _showScheduleDialog(
                            context,
                            _selected!.paciente,
                          );
                        }
                      },
                      child: Text(
                        'Programar Seguimiento',
                        style: GoogleFonts.archivoNarrow(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ============== LAYOUT ESCRITORIO ==============
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1350),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: listColumn),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        // Altura base para que el detalle respire
                        height: 520,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: kMLightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: detailColumn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }
}

/// ======= CARD RESULTADO EN LA LISTA =======

class _ResultCard extends StatelessWidget {
  final ResultItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ResultCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kMLightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
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
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: GoogleFonts.archivo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.paciente,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: kMGreyText),
                        const SizedBox(width: 4),
                        Text(
                          item.fecha,
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 12,
                            color: kMGreyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kMGreenBright,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.estado,
                  style: GoogleFonts.archivoNarrow(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======= PANEL DETALLE RESULTADO =======

class _ResultDetail extends StatelessWidget {
  final ResultItem item;

  const _ResultDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.titulo,
          style: GoogleFonts.archivo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.paciente,
          style: GoogleFonts.archivoNarrow(fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 4),
            Text(
              'Fecha de estudio: ${item.fecha}',
              style: GoogleFonts.archivoNarrow(fontSize: 13),
            ),
          ],
        ),
        if (item.medicoNombre.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                'Médico solicitante: ${item.medicoNombre}',
                style: GoogleFonts.archivoNarrow(fontSize: 13),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.flag_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              'Prioridad: ${item.prioridad}',
              style: GoogleFonts.archivoNarrow(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Observaciones del Laboratorio',
          style: GoogleFonts.archivo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kMWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            item.observaciones.isNotEmpty 
                ? item.observaciones 
                : 'Sin observaciones del laboratorio',
            style: GoogleFonts.archivoNarrow(
              fontSize: 14,
              color: item.observaciones.isNotEmpty ? kMBlack : kMGreyText,
              fontStyle: item.observaciones.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMBlue15,
                foregroundColor: kMBlack,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Compartiendo resultado de ${item.paciente}...',
                      style: GoogleFonts.archivoNarrow(),
                    ),
                    backgroundColor: kMPrimaryBlue,
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: kMWhite,
                      onPressed: () {},
                    ),
                  ),
                );
              },
              child: Text(
                'Compartir',
                style: GoogleFonts.archivoNarrow(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMPrimaryBlue,
                foregroundColor: kMWhite,
              ),
              onPressed: () {
                _showScheduleDialog(context, item.paciente);
              },
              child: Text(
                'Programar Seguimiento',
                style: GoogleFonts.archivoNarrow(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ======= MODELO DE DATOS =======

class ResultItem {
  final String id;
  final String titulo;
  final String paciente;
  final String fecha;
  final String estado;
  final String observaciones;
  final String prioridad;
  final String medicoNombre;

  const ResultItem({
    required this.id,
    required this.titulo,
    required this.paciente,
    required this.fecha,
    required this.estado,
    this.observaciones = '',
    this.prioridad = 'normal',
    this.medicoNombre = '',
  });
}

/// ======= FUNCIÓN PARA MOSTRAR POPUP CON ANIMACIÓN =======

Future<void> _showScheduleDialog(
  BuildContext context,
  String patientName,
) {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'Programar seguimiento',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (_, __, ___) {
      return ScheduleFollowUpDialog(patientName: patientName);
    },
    transitionBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
