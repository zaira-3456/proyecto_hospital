import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_medico.dart';
import '../../login/services/database_service.dart';

class DoctorRecordsScreen extends StatefulWidget {
  const DoctorRecordsScreen({super.key});

  @override
  State<DoctorRecordsScreen> createState() => _DoctorRecordsScreenState();
}

class _DoctorRecordsScreenState extends State<DoctorRecordsScreen> {
  int _tab = 0;
  RecordPatient? _selected;
  List<RecordPatient> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final db = DatabaseService();
    final patientsData = await db.getPatients();

    final List<RecordPatient> loadedPatients = [];

    for (var p in patientsData) {
      loadedPatients.add(RecordPatient(
        nombre: p['nombreCompleto'] ?? 'Sin nombre',
        actualizado: 'Hoy', // Placeholder
        creado: (p['creadoEn'] != null) ? 'Reciente' : 'Desconocido', // Placeholder
        medicamentos: [], // Placeholder
        visitas: [], // Placeholder
      ));
    }

    if (mounted) {
      setState(() {
        _patients = loadedPatients;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorLayout(
      selectedIndex: 3,
      child: LayoutBuilder(
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
                      child: Text(
                        'Buscar paciente',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 13,
                          color: kMGreyText,
                        ),
                      ),
                    ),
                  ],
                ),
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
      ),
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

  // SIGNOS VITALES
  String _bp = '130/85';
  String _hr = '72';
  String _weight = '68 kg';
  String _height = '160 cm';

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

    // General (ejemplo: valores por defecto)
    _bloodType = 'A+';
    _allergyText = 'Penicilina';
    _chronicText = 'Hipertensión arterial';
    _notesText = 'No hay notas adicionales';

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
          labelValue(
            'Tipo de sangre',
            _isEditing
                ? TextField(
                    decoration: _smallDecoration('Tipo de sangre'),
                    controller: TextEditingController(text: _bloodType)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: _bloodType.length),
                      ),
                    onChanged: (v) => _bloodType = v,
                  )
                : Text(
                    _bloodType,
                    style: GoogleFonts.archivoNarrow(fontSize: 13),
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
              decoration: _smallDecoration('Alergias'),
              controller: TextEditingController(text: _allergyText)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _allergyText.length),
                ),
              onChanged: (v) => _allergyText = v,
            )
          else
            Row(
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
            Row(
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
              decoration: _smallDecoration('Notas adicionales'),
              controller: TextEditingController(text: _notesText)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: _notesText.length),
                ),
              onChanged: (v) => _notesText = v,
            )
          else
            Text(
              _notesText,
              style: GoogleFonts.archivoNarrow(fontSize: 13),
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
    Widget vitalCard(String label, String value, IconData icon,
        Color color, Function(String) onChanged) {
      return Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kMWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
            _isEditing
                ? TextField(
                    textAlign: TextAlign.center,
                    decoration: _smallDecoration('Valor'),
                    controller: TextEditingController(text: value)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ),
                    onChanged: onChanged,
                  )
                : Text(
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

    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          vitalCard(
            'Presión Arterial',
            _bp,
            Icons.favorite,
            kMRed,
            (v) => _bp = v,
          ),
          vitalCard(
            'Frecuencia Cardíaca',
            _hr,
            Icons.monitor_heart,
            kMPrimaryBlue,
            (v) => _hr = v,
          ),
          vitalCard(
            'Peso',
            _weight,
            Icons.monitor_weight,
            kMYellow,
            (v) => _weight = v,
          ),
          vitalCard(
            'Altura',
            _height,
            Icons.height,
            kMGreenBright,
            (v) => _height = v,
          ),
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

  const RecordVisit({
    required this.fecha,
    required this.motivo,
    required this.diagnostico,
  });
}
