import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_medico.dart';
import '../../login/services/database_service.dart';
import 'nueva_visita_medico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorRecordsScreen extends StatefulWidget {
  const DoctorRecordsScreen({super.key});

  @override
  State<DoctorRecordsScreen> createState() => _DoctorRecordsScreenState();
}

class _DoctorRecordsScreenState extends State<DoctorRecordsScreen> {
  int _tab = 0;
  RecordPatient? _selected;
  List<RecordPatient> _patients = [];
  List<RecordPatient> _allPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _patients = List.from(_allPatients);
      } else {
        final lowerQuery = query.toLowerCase();
        _patients = _allPatients.where((p) =>
          p.nombre.toLowerCase().contains(lowerQuery) ||
          p.visitas.any((v) => v.diagnostico.toLowerCase().contains(lowerQuery)) ||
          p.visitas.any((v) => v.motivo.toLowerCase().contains(lowerQuery))
        ).toList();
      }
    });
  }

  Future<void> _loadPatients() async {
    try {
      // Cargar todas las visitas desde Firestore
      final visitsSnapshot = await FirebaseFirestore.instance
          .collection('visits')
          .orderBy('fecha', descending: true)
          .get();
      
      // Agrupar visitas por paciente
      final Map<String, List<Map<String, dynamic>>> visitsByPatient = {};
      
      for (var doc in visitsSnapshot.docs) {
        final data = doc.data();
        final pacienteId = data['pacienteId'] as String;
        
        if (!visitsByPatient.containsKey(pacienteId)) {
          visitsByPatient[pacienteId] = [];
        }
        
        visitsByPatient[pacienteId]!.add({
          'id': doc.id,
          ...data,
        });
      }
      
      // Crear RecordPatient para cada paciente con visitas
      final List<RecordPatient> loadedPatients = [];
      
      for (var entry in visitsByPatient.entries) {
        final visits = entry.value;
        if (visits.isEmpty) continue;
        
        final firstVisit = visits.first;
        final patientName = firstVisit['pacienteNombre'] ?? 'Sin nombre';
        
        // Convertir visitas a RecordVisit
        final recordVisits = visits.map((v) {
          final fecha = v['fecha'] as Timestamp?;
          final proximaVisita = v['proximaVisita'] as Timestamp?;
          final signosVitales = v['signosVitales'] as Map<String, dynamic>?;
          final medicamentos = v['medicamentos'] as List<dynamic>?;
          
          return RecordVisit(
            fecha: fecha != null 
                ? '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}'
                : 'Sin fecha',
            motivo: v['motivo'] ?? 'Sin motivo',
            diagnostico: v['diagnostico'] ?? 'Sin diagnóstico',
            notas: v['notas'] as String?,
            signosVitales: signosVitales != null
                ? Map<String, String>.from(signosVitales.map(
                    (key, value) => MapEntry(key, value.toString())))
                : null,
            medicamentos: medicamentos != null
                ? medicamentos.map((m) {
                    final med = m as Map<String, dynamic>;
                    return Map<String, String>.from(med.map(
                        (key, value) => MapEntry(key, value.toString())));
                  }).toList()
                : null,
            planTratamiento: v['planTratamiento'] as String?,
            proximaVisita: proximaVisita != null
                ? '${proximaVisita.toDate().day}/${proximaVisita.toDate().month}/${proximaVisita.toDate().year}'
                : null,
          );
        }).toList();
        
        // Extraer medicamentos de la visita más reciente
        final recentMeds = visits.first['medicamentos'] as List<dynamic>? ?? [];
        final recordMeds = recentMeds.map((m) {
          final med = m as Map<String, dynamic>;
          return RecordMed(
            nombre: med['nombre'] ?? 'Sin nombre',
            detalle: '${med['dosis'] ?? ''} - ${med['frecuencia'] ?? ''}',
          );
        }).toList();
        
        final lastUpdate = visits.first['fecha'] as Timestamp?;
        final createdDate = visits.last['creadoEn'] as Timestamp?;
        
        loadedPatients.add(RecordPatient(
          nombre: patientName,
          actualizado: lastUpdate != null
              ? _formatDate(lastUpdate.toDate())
              : 'Desconocido',
          creado: createdDate != null
              ? _formatDate(createdDate.toDate())
              : 'Desconocido',
          medicamentos: recordMeds,
          visitas: recordVisits,
        ));
      }
      
      if (mounted) {
        setState(() {
          _allPatients = loadedPatients;
          _patients = List.from(loadedPatients);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando visitas: $e');
      if (mounted) {
        setState(() {
          _allPatients = [];
          _patients = [];
          _isLoading = false;
        });
      }
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _showNewVisitDialog(BuildContext context) async {
    final db = DatabaseService();
    final patientsData = await db.getPatients();

    if (!context.mounted) return;

    String? selectedPatientId;
    Map<String, dynamic>? selectedPatientData;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: kMSidebarBlue.withValues(alpha: 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva Entrada de Visita',
                      style: GoogleFonts.archivo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona un paciente para crear un nuevo registro de visita',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Paciente',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Seleccionar paciente',
                        hintStyle: GoogleFonts.archivoNarrow(fontSize: 13),
                        filled: true,
                        fillColor: kMLightBlue,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      initialValue: selectedPatientId,
                      items: patientsData.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['id'],
                          child: Text(
                            patient['nombreCompleto'] ?? 'Sin nombre',
                            style: GoogleFonts.archivoNarrow(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPatientId = value;
                          selectedPatientData = patientsData.firstWhere(
                            (p) => p['id'] == value,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'Cancelar',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed: selectedPatientId == null
                              ? null
                              : () async {
                                  Navigator.pop(dialogContext);
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NuevaVisitaMedicoScreen(
                                        patientData: selectedPatientData!,
                                      ),
                                    ),
                                  );
                                  
                                  // Reload if visit was created successfully
                                  if (result == true) {
                                    _loadPatients();
                                  }
                                },
                          child: Text(
                            'Crear Visita',
                            style: GoogleFonts.archivoNarrow(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 1020;

        Widget leftList = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expedientes Médicos',
                style: GoogleFonts.archivo(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Expediente de tus pacientes',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 14,
                  color: kMGreyText,
                ),
              ),
              const SizedBox(height: 18),
              // Search bar + New Visit button
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                              onChanged: _filterPatients,
                              decoration: InputDecoration(
                                hintText: 'Buscar paciente por nombre o condición...',
                                hintStyle: GoogleFonts.archivoNarrow(
                                  fontSize: 13,
                                  color: kMGreyText,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: GoogleFonts.archivoNarrow(fontSize: 13),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                _filterPatients('');
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
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: GoogleFonts.archivoNarrow(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _showNewVisitDialog(context);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nueva Visita'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ...List.generate(
                  _patients.length,
                  (index) {
                    final p = _patients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecordPatientTile(
                        patient: p,
                        selected: _selected == p,
                        onTap: () {
                          setState(() {
                            _selected = p;
                            _tab = 0;
                          });
                        },
                      ),
                    );
                  },
                ),
            ],
          );

          Widget rightPanel;
          if (_selected == null) {
            rightPanel = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined,
                      size: 48, color: kMGreyText),
                  const SizedBox(height: 12),
                  Text(
                    'Selecciona un paciente',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 16,
                      color: kMGreyText,
                    ),
                  ),
                ],
              ),
            );
          } else {
            rightPanel = _RecordDetail(
              key: ValueKey(_selected!.nombre),
              patient: _selected!,
              initialTab: _tab,
              onTabChanged: (i) => setState(() => _tab = i),
            );
          }

          if (!wide) {
            // móvil: lista arriba, detalle abajo
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  leftList,
                  const SizedBox(height: 18),
                  Container(
                    height: 420,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kMLightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: rightPanel,
                  ),
                ],
              ),
            );
          }

          // escritorio: lista izquierda, detalle derecha
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1220),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320,
                      child: leftList,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        height: 520,
                        decoration: BoxDecoration(
                          color: kMLightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: rightPanel,
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


class _RecordPatientTile extends StatelessWidget {
  final RecordPatient patient;
  final bool selected;
  final VoidCallback onTap;

  const _RecordPatientTile({
    required this.patient,
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
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: kMLightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kMBlue15,
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: kMWhite,
                  child: const Icon(Icons.person, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nombre,
                      style: GoogleFonts.archivo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actualizado: ${patient.actualizado}',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 11,
                        color: kMGreyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= DETALLE (CON EDICIÓN) =================

class _RecordDetail extends StatefulWidget {
  final RecordPatient patient;
  final int initialTab;
  final ValueChanged<int> onTabChanged;

  const _RecordDetail({
    super.key,
    required this.patient,
    required this.initialTab,
    required this.onTabChanged,
  });

  @override
  State<_RecordDetail> createState() => _RecordDetailState();
}

class _RecordDetailState extends State<_RecordDetail> {
  late int _tab;
  bool _isEditing = false;

  // GENERAL
  late String _bloodType;
  late String _allergyText;
  late String _chronicText;
  late String _notesText;

  // MEDICAMENTOS
  late List<RecordMed> _meds;

  // VISITAS
  late List<RecordVisit> _visits;

  // Las variables de signos vitales ya no se necesitan - se leen de las visitas

  @override
  void initState() {
    super.initState();
    _initFromPatient();
  }

  @override
  void didUpdateWidget(covariant _RecordDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.nombre != widget.patient.nombre) {
      _isEditing = false;
      _initFromPatient();
    }
  }

  void _initFromPatient() {
    _tab = widget.initialTab;

    // General - Campos vacíos para que el médico los complete
    _bloodType = '';
    _allergyText = '';
    _chronicText = '';
    _notesText = '';

    // Listas a partir del modelo
    _meds = List<RecordMed>.from(widget.patient.medicamentos);
    _visits = List<RecordVisit>.from(widget.patient.visitas);
  }

  void _changeTab(int index) {
    setState(() {
      _tab = index;
    });
    widget.onTabChanged(index);
  }

  InputDecoration _smallDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: GoogleFonts.archivoNarrow(
        fontSize: 12,
        color: kMGreyText,
      ),
      filled: true,
      fillColor: kMWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildChip(String text, int index) {
      final selected = _tab == index;
      return InkWell(
        onTap: () => _changeTab(index),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? kMPrimaryBlue : kMBlue12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 11,
              color: selected ? kMWhite : kMBlack,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    Widget content;
    switch (_tab) {
      case 1:
        content = _buildMedications();
        break;
      case 2:
        content = _buildVisits();
        break;
      case 3:
        content = _buildVitals();
        break;
      case 0:
      default:
        content = _buildGeneral();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.patient.nombre,
                style: GoogleFonts.archivo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isEditing ? kMBlue12 : kMPrimaryBlue,
                foregroundColor:
                    _isEditing ? kMBlack : kMWhite,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              icon: Icon(
                _isEditing ? Icons.save : Icons.edit,
                size: 16,
              ),
              label: Text(
                _isEditing ? 'Guardar' : 'Editar',
                style: GoogleFonts.archivoNarrow(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Expediente creado: ${widget.patient.creado}',
          style: GoogleFonts.archivoNarrow(
            fontSize: 12,
            color: kMGreyText,
          ),
        ),
        const SizedBox(height: 10),

        // Chips
        Row(
          children: [
            buildChip('General', 0),
            const SizedBox(width: 6),
            buildChip('Medicamentos', 1),
            const SizedBox(width: 6),
            buildChip('Visitas', 2),
            const SizedBox(width: 6),
            buildChip('Signos vitales', 3),
          ],
        ),
        const SizedBox(height: 14),

        Expanded(child: content),
      ],
    );
  }

  // =============== GENERAL ===============

  Widget _buildGeneral() {
    Widget labelValue(String label, Widget valueWidget) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: GoogleFonts.archivoNarrow(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: valueWidget),
          ],
        ),
      );
    }

    Widget chip(String text, Color color) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: GoogleFonts.archivoNarrow(
            fontSize: 11,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje informativo si no hay datos
          if (!_isEditing && _bloodType.isEmpty && _allergyText.isEmpty && _chronicText.isEmpty && _notesText.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: kMLightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: kMPrimaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Click en "Editar" para agregar información general del paciente',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 12,
                        color: kMBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          labelValue(
            'Tipo de sangre',
            _isEditing
                ? TextField(
                    decoration: _smallDecoration('Tipo de sangre (ej: A+, O-, AB+)'),
                    controller: TextEditingController(text: _bloodType)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: _bloodType.length),
                      ),
                    onChanged: (v) => _bloodType = v,
                  )
                : Text(
                    _bloodType.isEmpty ? 'No especificado' : _bloodType,
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 13,
                      color: _bloodType.isEmpty ? kMGreyText : kMBlack,
                      fontStyle: _bloodType.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            'Alergias',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (_isEditing)
            TextField(
              decoration: _smallDecoration('Alergias conocidas'),
              controller: TextEditingController(text: _allergyText)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _allergyText.length),
                ),
              onChanged: (v) => _allergyText = v,
            )
          else
            _allergyText.isEmpty
                ? Text(
                    'Sin alergias registradas',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 13,
                      color: kMGreyText,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Row(
                    children: [
                      chip(_allergyText, kMRedSoft),
                    ],
                  ),
          const SizedBox(height: 10),
          Text(
            'Condiciones Crónicas',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (_isEditing)
            TextField(
              decoration: _smallDecoration('Condiciones crónicas'),
              controller: TextEditingController(text: _chronicText)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _chronicText.length),
                ),
              onChanged: (v) => _chronicText = v,
            )
          else
            _chronicText.isEmpty
                ? Text(
                    'Sin condiciones crónicas registradas',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 13,
                      color: kMGreyText,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Row(
                    children: [
                      chip(_chronicText, kMBlue15),
                    ],
                  ),
          const SizedBox(height: 10),
          Text(
            'Notas Adicionales',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (_isEditing)
            TextField(
              maxLines: 3,
              decoration: _smallDecoration('Notas adicionales del expediente'),
              controller: TextEditingController(text: _notesText)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _notesText.length),
                ),
              onChanged: (v) => _notesText = v,
            )
          else
            Text(
              _notesText.isEmpty ? 'Sin notas adicionales' : _notesText,
              style: GoogleFonts.archivoNarrow(
                fontSize: 13,
                color: _notesText.isEmpty ? kMGreyText : kMBlack,
                fontStyle: _notesText.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
        ],
      ),
    );
  }

  // =============== MEDICAMENTOS ===============

  Widget _buildMedications() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _meds.length,
            itemBuilder: (context, index) {
              final m = _meds[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kMWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _isEditing
                          ? Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration: _smallDecoration(
                                      'Nombre del medicamento'),
                                  controller:
                                      TextEditingController(text: m.nombre)
                                        ..selection =
                                            TextSelection.fromPosition(
                                          TextPosition(
                                              offset: m.nombre.length),
                                        ),
                                  onChanged: (v) {
                                    _meds[index] = RecordMed(
                                      nombre: v,
                                      detalle: m.detalle,
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  decoration:
                                      _smallDecoration('Detalle'),
                                  controller:
                                      TextEditingController(text: m.detalle)
                                        ..selection =
                                            TextSelection.fromPosition(
                                          TextPosition(
                                              offset: m.detalle.length),
                                        ),
                                  onChanged: (v) {
                                    _meds[index] = RecordMed(
                                      nombre: m.nombre,
                                      detalle: v,
                                    );
                                  },
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.nombre,
                                  style: GoogleFonts.archivo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  m.detalle,
                                  style: GoogleFonts.archivoNarrow(
                                    fontSize: 12,
                                    color: kMGreyText,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.medication_outlined, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
        if (_isEditing)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _meds.add(
                    const RecordMed(
                        nombre: 'Nuevo medicamento',
                        detalle: 'Detalle'),
                  );
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Agregar medicamento',
                style: GoogleFonts.archivoNarrow(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // =============== VISITAS ===============

  Widget _buildVisits() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _visits.length,
            itemBuilder: (context, index) {
              final v = _visits[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kMWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isEditing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: _smallDecoration('Fecha'),
                            controller: TextEditingController(text: v.fecha)
                              ..selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: v.fecha.length),
                              ),
                            onChanged: (val) {
                              _visits[index] = RecordVisit(
                                fecha: val,
                                motivo: v.motivo,
                                diagnostico: v.diagnostico,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            decoration: _smallDecoration('Motivo'),
                            controller: TextEditingController(text: v.motivo)
                              ..selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: v.motivo.length),
                              ),
                            onChanged: (val) {
                              _visits[index] = RecordVisit(
                                fecha: v.fecha,
                                motivo: val,
                                diagnostico: v.diagnostico,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            decoration: _smallDecoration('Diagnóstico'),
                            controller:
                                TextEditingController(text: v.diagnostico)
                                  ..selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: v.diagnostico.length),
                                  ),
                            onChanged: (val) {
                              _visits[index] = RecordVisit(
                                fecha: v.fecha,
                                motivo: v.motivo,
                                diagnostico: val,
                              );
                            },
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event_note, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                v.fecha,
                                style: GoogleFonts.archivoNarrow(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.motivo,
                            style: GoogleFonts.archivoNarrow(
                              fontSize: 13,
                              color: kMBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dx: ${v.diagnostico}',
                            style: GoogleFonts.archivoNarrow(
                              fontSize: 12,
                              color: kMGreyText,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
        if (_isEditing)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _visits.add(
                    const RecordVisit(
                      fecha: 'Hoy',
                      motivo: 'Consulta',
                      diagnostico: 'Pendiente',
                    ),
                  );
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Agregar visita',
                style: GoogleFonts.archivoNarrow(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // =============== SIGNOS VITALES ===============

  Widget _buildVitals() {
    // Obtener signos vitales de la visita más reciente
    final latestVisit = _visits.isNotEmpty ? _visits.first : null;
    final vitals = latestVisit?.signosVitales;
    
    final bp = vitals?['presion'] ?? 'N/A';
    final hr = vitals?['frecuenciaCardiaca'] ?? 'N/A';
    final temp = vitals?['temperatura'] ?? 'N/A';
    final weight = vitals?['peso'] ?? 'N/A';
    final height = vitals?['altura'] ?? 'N/A';
    
    Widget vitalCard(String label, String value, IconData icon,
        Color color) {
      return Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kMWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.archivoNarrow(
                fontSize: 12,
                color: kMGreyText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.archivo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (latestVisit == null || vitals == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monitor_heart_outlined, size: 48, color: kMGreyText),
            const SizedBox(height: 12),
            Text(
              'No hay signos vitales registrados',
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                color: kMGreyText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una nueva visita para registrar signos vitales',
              style: GoogleFonts.archivoNarrow(
                fontSize: 12,
                color: kMGreyText,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar de qué visita son estos datos
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kMLightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: kMPrimaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Signos vitales de la visita del ${latestVisit.fecha}',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 12,
                      color: kMBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tarjetas de signos vitales
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              vitalCard(
                'Presión Arterial',
                bp,
                Icons.favorite,
                kMRed,
              ),
              vitalCard(
                'Frecuencia Cardíaca',
                hr,
                Icons.monitor_heart,
                kMPrimaryBlue,
              ),
              vitalCard(
                'Temperatura',
                temp,
                Icons.thermostat,
                kMYellow,
              ),
              vitalCard(
                'Peso',
                weight,
                Icons.monitor_weight,
                kMGreenBright,
              ),
              vitalCard(
                'Altura',
                height,
                Icons.height,
                Colors.purple,
              ),
            ],
          ),
          // Información adicional
          if (latestVisit.notas != null && latestVisit.notas!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Notas de la visita',
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kMWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                latestVisit.notas!,
                style: GoogleFonts.archivoNarrow(fontSize: 13),
              ),
            ),
          ],
          if (latestVisit.planTratamiento != null && latestVisit.planTratamiento!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Plan de Tratamiento',
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kMWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                latestVisit.planTratamiento!,
                style: GoogleFonts.archivoNarrow(fontSize: 13),
              ),
            ),
          ],
          if (latestVisit.proximaVisita != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: kMPrimaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Próxima visita programada: ${latestVisit.proximaVisita}',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: kMPrimaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// ================= MODELOS =================

class RecordPatient {
  final String nombre;
  final String actualizado;
  final String creado;
  final List<RecordMed> medicamentos;
  final List<RecordVisit> visitas;

  const RecordPatient({
    required this.nombre,
    required this.actualizado,
    required this.creado,
    required this.medicamentos,
    required this.visitas,
  });
}

class RecordMed {
  final String nombre;
  final String detalle;

  const RecordMed({required this.nombre, required this.detalle});
}

class RecordVisit {
  final String fecha;
  final String motivo;
  final String diagnostico;
  final String? notas;
  final Map<String, String>? signosVitales;
  final List<Map<String, String>>? medicamentos;
  final String? planTratamiento;
  final String? proximaVisita;

  const RecordVisit({
    required this.fecha,
    required this.motivo,
    required this.diagnostico,
    this.notas,
    this.signosVitales,
    this.medicamentos,
    this.planTratamiento,
    this.proximaVisita,
  });
}
