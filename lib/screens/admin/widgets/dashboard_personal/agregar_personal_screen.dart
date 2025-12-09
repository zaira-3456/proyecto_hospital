import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'pantalla_asignar_usuario.dart';


class AgregarPersonalScreen extends StatefulWidget {
  const AgregarPersonalScreen({super.key});

  @override
  State<AgregarPersonalScreen> createState() => _AgregarPersonalScreenState();
}

class _AgregarPersonalScreenState extends State<AgregarPersonalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de textos
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController nacimientoCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController(); // Nuevo
  final TextEditingController curpCtrl = TextEditingController();
  final TextEditingController rfcCtrl = TextEditingController();
  final TextEditingController generoCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController direccionCtrl = TextEditingController();
  final TextEditingController puestoCtrl = TextEditingController();

  String? selectedArea;
  String? selectedTipo;
  String? selectedTurno;
  DateTime? _selectedDate;

  // Áreas del hospital - completas
  final List<String> areas = [
    'Urgencias',
    'Farmacia',
    'Consulta Externa',
    'Administración',
    'Finanzas',
    'Cardiología',
    'Pediatría',
    'Ginecología',
    'Laboratorio',
    'Recepción',
    'Enfermería',
    'Medicina General',
    'Traumatología',
    'Neurología',
    'Dermatología',
    'Oftalmología',
    'Nutrición',
    'Psicología',
    'Radiología',
    'Rehabilitación',
  ];
  
  // Tipos de personal - correspondientes a módulos del sistema
  final List<String> tipos = [
    'medico',
    'enfermeria',
    'administrativo',
    'farmacia',
    'recepcion',
    'finanzas',
    'laboratorio',
  ];
  
  final List<String> turnos = ['Matutino', 'Vespertino', 'Nocturno'];

  // Archivos
  final List<PlatformFile?> _files = List.generate(7, (_) => null);

  @override
  void dispose() {
    nombreCtrl.dispose();
    nacimientoCtrl.dispose();
    edadCtrl.dispose();
    curpCtrl.dispose();
    rfcCtrl.dispose();
    generoCtrl.dispose();
    telefonoCtrl.dispose();
    correoCtrl.dispose();
    direccionCtrl.dispose();
    puestoCtrl.dispose();
    super.dispose();
  }

  // CALCULAR EDAD
  void _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    edadCtrl.text = age.toString();
  }

  // SELECCIONAR FECHA
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        nacimientoCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
        _calculateAge(picked);
      });
    }
  }

  // ===================================================
  //              FILE PICKER
  // ===================================================
  Future<void> _pickFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        setState(() => _files[index] = result.files.first);
      }
    } catch (e) {
      print("ERROR AL SELECCIONAR ARCHIVO: $e");
    }
  }

  // ===================================================
  //              POPUP CONFIRMACIÓN GUARDAR
  // ===================================================
  Future<void> _confirmGuardar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete los campos obligatorios')),
      );
      return;
    }

    if (selectedArea == null || selectedTipo == null || selectedTurno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione Área, Tipo y Turno')),
      );
      return;
    }

    final bool? resultado = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar acción"),
          content: const Text("¿Deseas guardar el registro?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sí, guardar"),
            )
          ],
        );
      },
    );

    if (resultado == true) {
      _registroGuardadoCorrectamente();
    }
  }

  // ===================================================
  //      POPUP GUARDADO EXITOSO → REDIRIGE
  // ===================================================
  Future<void> _registroGuardadoCorrectamente() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("¡Registro exitoso!"),
          content: const Text("El registro se guardó correctamente."),
          actions: [
            ElevatedButton(
              child: const Text("Aceptar"),
              onPressed: () {
                Navigator.pop(context); // cierra el dialogo

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaAsignarUsuario(
                        personalData: {
                          'nombre': nombreCtrl.text,
                          'fechaNacimiento': _selectedDate, 
                          'curp': curpCtrl.text,
                          'rfc': rfcCtrl.text,
                          'genero': generoCtrl.text,
                          'telefono': telefonoCtrl.text,
                          'correo': correoCtrl.text,
                          'direccion': direccionCtrl.text,
                          'puesto': puestoCtrl.text,
                          'area': selectedArea ?? '',
                          'tipo': selectedTipo ?? '',
                          'turno': selectedTurno ?? '',
                          'estado': 'Activo',
                        },
                      ),
                    ),
                  );
              },
            ),
          ],
        );
      },
    );
  }


  // ===================================================
  //              POPUP CANCELAR REGISTRO
  // ===================================================
  Future<void> _confirmCancelar() async {
    final bool? resultado = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancelar registro"),
          content:
              const Text("¿Realmente deseas cancelar el registro?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sí, cancelar"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (resultado == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffbbddf7),
      appBar: AppBar(
        backgroundColor: const Color(0xff2196f3),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Registro de personal Hospitalario",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          width: width > 1100 ? 900 : width * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
                      "Datos personales",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  buildInput("Nombre completo", nombreCtrl, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("Fecha de nacimiento", nacimientoCtrl, isReadOnly: true, onTap: () => _selectDate(context), suffixIcon: Icons.calendar_today, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("Edad", edadCtrl, isReadOnly: true),
                  buildInput("CURP", curpCtrl, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("RFC", rfcCtrl, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("Género", generoCtrl, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("Teléfono de contacto", telefonoCtrl, inputType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("Correo electrónico", correoCtrl, inputType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  buildInput("Dirección", direccionCtrl, validator: (v) => v!.isEmpty ? 'Requerido' : null),

                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Datos Laborales",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 25),
                  buildInput("Puesto", puestoCtrl, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  _buildDropdown("Área", areas, selectedArea, (val) => setState(() => selectedArea = val)),
                  _buildDropdown("Tipo de Personal", tipos, selectedTipo, (val) => setState(() => selectedTipo = val)),
                  _buildDropdown("Turno", turnos, selectedTurno, (val) => setState(() => selectedTurno = val)),

                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Documentación requerida",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 25),

                  buildUploadRow("Identificación oficial vigente", 0),
                  buildUploadRow("CURP", 1),
                  buildUploadRow("Comprobante de domicilio", 2),
                  buildUploadRow(
                      "Certificado de estudios o título profesional", 3),

                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Formación y experiencia",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 25),

                  buildUploadRow("Curriculum vitae", 4),
                  buildUploadRow("Carta de presentación", 5),
                  buildUploadRow("Referencias laborales", 6),

                  const SizedBox(height: 40),

                  // BOTONES FINALES - RESPONSIVOS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _confirmGuardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                              ),
                              child: const Text(
                                "Guardar",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _confirmCancelar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                              ),
                              child: const Text(
                                "Cancelar registro",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      }
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // CANCELAR
                          ElevatedButton(
                            onPressed: _confirmCancelar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                            ),
                            child: const Text(
                              "Cancelar registro",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),

                          // GUARDAR
                          ElevatedButton(
                            onPressed: _confirmGuardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                            ),
                            child: const Text(
                              "Guardar",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // INPUT DE TEXTO
  // ===============================
  Widget buildInput(String label, TextEditingController ctrl, {
    bool isReadOnly = false,
    VoidCallback? onTap,
    TextInputType inputType = TextInputType.text,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            readOnly: isReadOnly,
            onTap: onTap,
            keyboardType: inputType,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // TRAYECTORIA DE LOS BOTONES SUBIR ARCHIVO
  // ===============================
  Widget buildUploadRow(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),

          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 220),
                child: _files[index] != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _files[index]!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => _pickFile(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Subir Archivo"),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text("Seleccione $label"),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
