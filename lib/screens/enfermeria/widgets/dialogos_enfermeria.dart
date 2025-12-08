import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'diseno_enfermeria.dart';

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.archivoNarrow(fontSize: 14),
    hintStyle: GoogleFonts.archivoNarrow(
      fontSize: 13,
      color: Colors.grey[600],
    ),
    border: const OutlineInputBorder(),
    isDense: true,
  );
}

/// ========== DIALOG: REGISTRAR NUEVA TAREA ==========

class RegisterTaskDialog extends StatefulWidget {
  const RegisterTaskDialog({super.key});

  @override
  State<RegisterTaskDialog> createState() => _RegisterTaskDialogState();
}

class _RegisterTaskDialogState extends State<RegisterTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tareaController = TextEditingController();
  final _habitacionController = TextEditingController();
  
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isLoading = false;

  @override
  void dispose() {
    _tareaController.dispose();
    _habitacionController.dispose();
    super.dispose();
  }

  Future<void> _registrarTarea() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleccione un paciente', style: GoogleFonts.archivoNarrow()),
          backgroundColor: kNRedAlert,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('tareas_enfermeria').add({
        'pacienteId': _selectedPatientId,
        'pacienteNombre': _selectedPatientName,
        'tarea': _tareaController.text.trim(),
        'habitacion': _habitacionController.text.trim(),
        'enfermeraNombre': 'Arleth Danae Aquino Pochotl', // TODO: Get from auth
        'estado': 'pendiente',
        'creadaEn': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tarea registrada para ${_selectedPatientName}',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kNGreenDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar tarea: $e', style: GoogleFonts.archivoNarrow()),
            backgroundColor: kNRedAlert,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Registrar Nueva Tarea',
                          style: GoogleFonts.archivo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown de pacientes desde Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pacientes')
                        .orderBy('nombreCompleto')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error al cargar pacientes', style: GoogleFonts.archivoNarrow());
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      
                      return DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Paciente'),
                        value: _selectedPatientId,
                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nombre = data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre';
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(nombre, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final doc = docs.firstWhere((d) => d.id == value);
                            final data = doc.data() as Map<String, dynamic>;
                            setState(() {
                              _selectedPatientId = value;
                              _selectedPatientName = data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre';
                              // Auto-llenar habitación si existe
                              if (data['habitacion'] != null && _habitacionController.text.isEmpty) {
                                _habitacionController.text = data['habitacion'].toString();
                              }
                            });
                          }
                        },
                        validator: (value) => value == null ? 'Seleccione un paciente' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _tareaController,
                    decoration: _fieldDecoration(
                      'Tarea',
                      hint: 'Descripción de la tarea',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese la descripción de la tarea';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _habitacionController,
                    decoration: _fieldDecoration(
                      'Habitación',
                      hint: 'Número de la habitación',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNPrimaryBlue,
                        foregroundColor: kNWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: GoogleFonts.archivo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: _isLoading ? null : _registrarTarea,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Registrar Tarea'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ========== DIALOG: REGISTRAR MEDICAMENTO ==========

class RegisterMedicationDialog extends StatelessWidget {
  const RegisterMedicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Registrar Medicamento',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Medicamento'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paracetamol',
                            child: Text('Paracetamol'),
                          ),
                          DropdownMenuItem(
                            value: 'Ibuprofeno',
                            child: Text('Ibuprofeno'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Paciente'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Paciente 1',
                            child: Text('Paciente 1'),
                          ),
                          DropdownMenuItem(
                            value: 'Paciente 2',
                            child: Text('Paciente 2'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNPrimaryBlue,
                            foregroundColor: kNWhite,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Administrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ========== DIALOG: DETALLES DEL PACIENTE ==========

class PatientDetailsDialog extends StatelessWidget {
  final String nombre;
  final String edad;
  final String habitacion;
  final bool critico;

  const PatientDetailsDialog({
    super.key,
    required this.nombre,
    required this.edad,
    required this.habitacion,
    required this.critico,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Detalles del Paciente',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        decoration: _fieldDecoration('Nombre completo')
                            .copyWith(
                          hintText: nombre,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        decoration:
                            _fieldDecoration('Edad').copyWith(
                          hintText: edad,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        readOnly: true,
                        decoration: _fieldDecoration(
                          'Habitación/Cama',
                        ).copyWith(
                          hintText: habitacion,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Estado',
                        style: GoogleFonts.archivoNarrow(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              critico ? kNRedAlert : kNGreenDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          critico ? 'Crítico' : 'Estable',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 13,
                            color: kNWhite,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4D4D4),
                            foregroundColor: kNBlack,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ========== DIALOG: ADMINISTRAR MEDICAMENTO ==========

class AdministerMedicationDialog extends StatefulWidget {
  const AdministerMedicationDialog({super.key});

  @override
  State<AdministerMedicationDialog> createState() => _AdministerMedicationDialogState();
}

class _AdministerMedicationDialogState extends State<AdministerMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMedicamentoId;
  String? _selectedMedicamentoNombre;
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isLoading = false;

  Future<void> _administrarMedicamento() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedMedicamentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleccione un medicamento', style: GoogleFonts.archivoNarrow()),
          backgroundColor: kNRedAlert,
        ),
      );
      return;
    }
    
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleccione un paciente', style: GoogleFonts.archivoNarrow()),
          backgroundColor: kNRedAlert,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Registrar la administración del medicamento en Firestore
      await FirebaseFirestore.instance.collection('administraciones_medicamentos').add({
        'medicamentoId': _selectedMedicamentoId,
        'medicamentoNombre': _selectedMedicamentoNombre,
        'pacienteId': _selectedPatientId,
        'pacienteNombre': _selectedPatientName,
        'enfermeraNombre': 'Arleth Danae Aquino Pochotl', // TODO: Get from auth
        'fechaAdministracion': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Medicamento "$_selectedMedicamentoNombre" administrado a $_selectedPatientName',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kNGreenDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar administración: $e', style: GoogleFonts.archivoNarrow()),
            backgroundColor: kNRedAlert,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Administrar Medicamento',
                          style: GoogleFonts.archivo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown de medicamentos desde Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('medicamentos_inventario')
                        .orderBy('nombre')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error al cargar medicamentos', style: GoogleFonts.archivoNarrow());
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Text('No hay medicamentos disponibles', style: GoogleFonts.archivoNarrow());
                      }
                      
                      return DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Medicamento'),
                        value: _selectedMedicamentoId,
                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nombre = data['nombre'] ?? 'Sin nombre';
                          final dosis = data['dosis'] ?? '';
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text('$nombre${dosis.isNotEmpty ? " - $dosis" : ""}', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final doc = docs.firstWhere((d) => d.id == value);
                            final data = doc.data() as Map<String, dynamic>;
                            setState(() {
                              _selectedMedicamentoId = value;
                              _selectedMedicamentoNombre = data['nombre'] ?? 'Sin nombre';
                            });
                          }
                        },
                        validator: (value) => value == null ? 'Seleccione un medicamento' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Dropdown de pacientes desde Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pacientes')
                        .orderBy('nombreCompleto')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error al cargar pacientes', style: GoogleFonts.archivoNarrow());
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Text('No hay pacientes registrados', style: GoogleFonts.archivoNarrow());
                      }
                      
                      return DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Paciente'),
                        value: _selectedPatientId,
                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nombre = data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre';
                          final habitacion = data['habitacion'] ?? '';
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text('$nombre${habitacion.isNotEmpty ? " (Hab: $habitacion)" : ""}', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final doc = docs.firstWhere((d) => d.id == value);
                            final data = doc.data() as Map<String, dynamic>;
                            setState(() {
                              _selectedPatientId = value;
                              _selectedPatientName = data['nombreCompleto'] ?? data['nombre'] ?? 'Sin nombre';
                            });
                          }
                        },
                        validator: (value) => value == null ? 'Seleccione un paciente' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNPrimaryBlue,
                        foregroundColor: kNWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: GoogleFonts.archivo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: _isLoading ? null : _administrarMedicamento,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Administrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ========== DIALOG: SOLICITAR MEDICAMENTO A FARMACIA ==========

class RequestMedicationDialog extends StatefulWidget {
  final String medicamento;
  final String dosis;

  const RequestMedicationDialog({
    super.key,
    required this.medicamento,
    required this.dosis,
  });

  @override
  State<RequestMedicationDialog> createState() => _RequestMedicationDialogState();
}

class _RequestMedicationDialogState extends State<RequestMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController(text: '1');
  final _pacienteController = TextEditingController();
  final _habitacionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _pacienteController.dispose();
    _habitacionController.dispose();
    super.dispose();
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('solicitudes_medicamentos').add({
        'medicamento': widget.medicamento,
        'dosis': widget.dosis,
        'cantidad': int.tryParse(_cantidadController.text) ?? 1,
        'pacienteNombre': _pacienteController.text.trim(),
        'habitacion': _habitacionController.text.trim(),
        'enfermeraNombre': 'Arleth Danae Aquino Pochotl', // TODO: Get from auth
        'estado': 'pendiente',
        'creadaEn': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitud de ${widget.medicamento} enviada a Farmacia',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kNGreenDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al enviar solicitud: $e',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kNRedAlert,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Solicitar Medicamento',
                          style: GoogleFonts.archivo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Medicamento (solo lectura)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicamento',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${widget.medicamento} - ${widget.dosis}',
                          style: GoogleFonts.archivo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cantidad
                  TextFormField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration('Cantidad (unidades)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la cantidad';
                      }
                      final cantidad = int.tryParse(value);
                      if (cantidad == null || cantidad < 1) {
                        return 'Ingrese una cantidad válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Paciente
                  TextFormField(
                    controller: _pacienteController,
                    decoration: _fieldDecoration(
                      'Nombre del Paciente',
                      hint: 'Nombre completo del paciente',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el nombre del paciente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Habitación
                  TextFormField(
                    controller: _habitacionController,
                    decoration: _fieldDecoration(
                      'Habitación',
                      hint: 'Ej: 201-A',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón enviar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNPrimaryBlue,
                        foregroundColor: kNWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: GoogleFonts.archivo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: _isLoading ? null : _enviarSolicitud,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enviar Solicitud a Farmacia'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
