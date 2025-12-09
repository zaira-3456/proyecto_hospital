import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/diseno_medico.dart';
import 'widgets/dialogos_medico.dart';
import '../../login/services/database_service.dart';

class DoctorStudiesScreen extends StatefulWidget {
  const DoctorStudiesScreen({super.key});

  @override
  State<DoctorStudiesScreen> createState() => _DoctorStudiesScreenState();
}

class _DoctorStudiesScreenState extends State<DoctorStudiesScreen> {
  int _tabIndex = 0; // 0 pendientes, 1 proceso, 2 completados
  DoctorStudy? _selected;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  String? _currentMedicoId;

  @override
  void initState() {
    super.initState();
    _loadCurrentDoctor();
  }

  Future<void> _loadCurrentDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    _currentMedicoId = prefs.getString('current_username');
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DoctorStudy> _filterStudies(List<DoctorStudy> list) {
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((s) =>
      s.nombre.toLowerCase().contains(query) ||
      s.paciente.toLowerCase().contains(query)
    ).toList();
  }

  List<DoctorStudy> _convertToStudies(List<Map<String, dynamic>> data) {
    print('🔄 Convirtiendo ${data.length} estudios');
    return data.map((doc) {
      final estado = doc['estado'] as String?;
      print('  - Estudio: ${doc['tipoEstudio']} | Estado: $estado');
      
      StudyEstado estudoEnum;
      switch (estado) {
        case 'en_proceso':
          estudoEnum = StudyEstado.proceso;
          break;
        case 'completado':
          estudoEnum = StudyEstado.completado;
          break;
        default:
          estudoEnum = StudyEstado.pendiente;
      }

      return DoctorStudy(
        nombre: doc['tipoEstudio'] ?? 'Estudio sin nombre',
        paciente: doc['pacienteNombre'] ?? 'Paciente desconocido',
        fecha: _formatTimestamp(doc['fechaSolicitud']),
        estado: estudoEnum,
        resultadoLabel: doc['resultados'] ?? 'Programado',
      );
    }).toList();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Sin fecha';
    try {
      final DateTime date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Sin fecha';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMedicoId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('study_requests')
          .orderBy('fechaSolicitud', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        
        // TEMPORAL: Mostrar todos los estudios sin filtrar por médico
        // para verificar que hay datos
        final allStudiesData = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...data};
        }).toList();
        
        // Debug: imprimir cuántos estudios hay
        print('📊 Total estudios en BD: ${docs.length}');
        print('👨‍⚕️ Médico actual ID: $_currentMedicoId');

        final all = _convertToStudies(allStudiesData);
        List<DoctorStudy> filtered;
        switch (_tabIndex) {
          case 1:
            filtered = all.where((s) => s.estado == StudyEstado.proceso).toList();
            break;
          case 2:
            filtered = all.where((s) => s.estado == StudyEstado.completado).toList();
            break;
          case 0:
          default:
            filtered = all.where((s) => s.estado == StudyEstado.pendiente).toList();
            break;
        }
        // Apply search filter
        filtered = _filterStudies(filtered);

        return _buildStudiesUI(context, filtered, all);
      },
    );
  }

  Widget _buildStudiesUI(BuildContext context, List<DoctorStudy> filtered, List<DoctorStudy> all) {

    return Scaffold(
      backgroundColor: kMWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 980;

          Widget listSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estudios Clínicos',
                    style: GoogleFonts.archivo(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const DoctorLogoCircle(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Información de tus pacientes',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 14,
                  color: kMGreyText,
                ),
              ),
              const SizedBox(height: 18),

              // Buscador + botón
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: kMLightBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar estudios por paciente o tipo...',
                                hintStyle: GoogleFonts.archivoNarrow(
                                  fontSize: 14,
                                  color: kMGreyText,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: GoogleFonts.archivoNarrow(fontSize: 14),
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
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
                    height: 44,
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const RequestStudyDialog(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Solicitar Estudio'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tabs
              _StudyTabs(
                index: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
                allStudies: all,
              ),
              const SizedBox(height: 14),

              // Lista
              ...filtered.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StudyCard(
                    study: s,
                    selected: _selected == s,
                    onTap: () {
                      setState(() {
                        _selected = s;
                      });
                    },
                  ),
                ),
              ),
            ],
          );

          Widget detailSection;
          if (_selected == null) {
            detailSection = Center(
              child: Text(
                'Selecciona un estudio',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 16,
                  color: kMGreyText,
                ),
              ),
            );
          } else {
            detailSection = _StudyDetail(study: _selected!);
          }

          if (!wide) {
            // móvil / tablet: lista + detalle debajo
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  listSection,
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kMLightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 260,
                    child: detailSection,
                  ),
                ],
              ),
            );
          }

          // escritorio: lista izquierda + detalle derecha
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: listSection),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 420,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: kMLightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: detailSection,
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
}

class _StudyTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<DoctorStudy> allStudies;

  const _StudyTabs({
    required this.index,
    required this.onChanged,
    required this.allStudies,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate real counts
    final pendientes = allStudies.where((s) => s.estado == StudyEstado.pendiente).length;
    final enProceso = allStudies.where((s) => s.estado == StudyEstado.proceso).length;
    final completados = allStudies.where((s) => s.estado == StudyEstado.completado).length;
    
    Widget chip(String text, int i, Color color) {
      final selected = index == i;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(i),
          child: Container(
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color : kMLightBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: GoogleFonts.archivoNarrow(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Pendientes ($pendientes)', 0, kMRedSoft),
        const SizedBox(width: 8),
        chip('En Proceso ($enProceso)', 1, kMYellow),
        const SizedBox(width: 8),
        chip('Completados ($completados)', 2, kMGreenBright),
      ],
    );
  }
}

class _StudyCard extends StatelessWidget {
  final DoctorStudy study;
  final bool selected;
  final VoidCallback onTap;

  const _StudyCard({
    required this.study,
    required this.selected,
    required this.onTap,
  });

  Color _statusColor() {
    switch (study.estado) {
      case StudyEstado.pendiente:
        return kMYellow;
      case StudyEstado.proceso:
        return kMBlue15;
      case StudyEstado.completado:
        return kMGreenBright;
    }
  }

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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: const Icon(Icons.biotech, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      study.nombre,
                      style: GoogleFonts.archivo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      study.paciente,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
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
                          study.fecha,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      study.estadoTexto,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kMBlue12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      study.resultadoLabel,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyDetail extends StatelessWidget {
  final DoctorStudy study;

  const _StudyDetail({required this.study});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          study.nombre,
          style: GoogleFonts.archivo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          study.paciente,
          style: GoogleFonts.archivoNarrow(fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          'Fecha de solicitud: ${study.fecha}',
          style: GoogleFonts.archivoNarrow(
            fontSize: 13,
            color: kMGreyText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Comentarios del estudio',
          style: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Análisis clínico para control de condición actual. Revisar resultados de laboratorio y parámetros críticos.',
          style: GoogleFonts.archivoNarrow(fontSize: 13),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: study.estado == StudyEstado.completado 
                  ? kMPrimaryBlue 
                  : kMGreyText,
              foregroundColor: kMWhite,
            ),
            onPressed: study.estado == StudyEstado.completado
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Descargando resultados de ${study.nombre}...',
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
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'El estudio aún no está completado',
                          style: GoogleFonts.archivoNarrow(),
                        ),
                        backgroundColor: kMOrange,
                      ),
                    );
                  },
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: Text(
              study.estado == StudyEstado.completado 
                  ? 'Descargar resultados' 
                  : 'Pendiente de resultados',
              style: GoogleFonts.archivoNarrow(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum StudyEstado { pendiente, proceso, completado }

class DoctorStudy {
  final String nombre;
  final String paciente;
  final String fecha;
  final StudyEstado estado;
  final String resultadoLabel;

  const DoctorStudy({
    required this.nombre,
    required this.paciente,
    required this.fecha,
    required this.estado,
    required this.resultadoLabel,
  });

  String get estadoTexto {
    switch (estado) {
      case StudyEstado.pendiente:
        return 'Pendiente';
      case StudyEstado.proceso:
        return 'En proceso';
      case StudyEstado.completado:
        return 'Completado';
    }
  }
}
