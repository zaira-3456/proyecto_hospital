import 'package:flutter/material.dart';
import '../../login/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPacientePage extends StatefulWidget {
  final Widget returnRoute;
  final String? patientId;
  final Map<String, dynamic>? patientData;

  const RegistroPacientePage({
    super.key,
    required this.returnRoute,
    this.patientId,
    this.patientData,
  });

  @override
  State<RegistroPacientePage> createState() => _RegistroPacientePageState();
}

class _RegistroPacientePageState extends State<RegistroPacientePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nombreController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _edadController = TextEditingController();
  final _generoController = TextEditingController();
  final _estadoCivilController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _familiarController = TextEditingController();
  final _telFamiliarController = TextEditingController();
  final _parentescoController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;
  bool get _isEditing => widget.patientId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.patientData != null) {
      _loadPatientData();
    }
  }

  void _loadPatientData() {
    setState(() {
      final data = widget.patientData!;
      _nombreController.text = data['nombreCompleto'] ?? '';
      _generoController.text = data['genero'] ?? '';
      _telefonoController.text = data['telefono'] ?? '';
      _correoController.text = data['correo'] ?? '';
      _familiarController.text = data['nombreFamiliar'] ?? '';
      _telFamiliarController.text = data['telefonoFamiliar'] ?? '';
      _parentescoController.text = data['parentesco'] ?? '';
      _estadoCivilController.text = data['estadoCivil'] ?? '';

      if (data['fechaNacimiento'] != null) {
        if (data['fechaNacimiento'] is Timestamp) {
          _selectedDate = (data['fechaNacimiento'] as Timestamp).toDate();
        } else if (data['fechaNacimiento'] is String) {
          // Fallback for legacy string dates if any
          try {
             // Try parsing dd/MM/yyyy
             final parts = (data['fechaNacimiento'] as String).split('/');
             if (parts.length == 3) {
               _selectedDate = DateTime(
                 int.parse(parts[2]),
                 int.parse(parts[1]),
                 int.parse(parts[0]),
               );
             }
          } catch (_) {}
        }

        if (_selectedDate != null) {
          _fechaNacController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
          _calculateAge(_selectedDate!);
        }
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaNacController.dispose();
    _edadController.dispose();
    _generoController.dispose();
    _estadoCivilController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _familiarController.dispose();
    _telFamiliarController.dispose();
    _parentescoController.dispose();
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
    _edadController.text = age.toString();
  }

  // SELECCIONAR FECHA
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1991DB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaNacController.text = "${picked.day}/${picked.month}/${picked.year}";
        _calculateAge(picked);
      });
    }
  }

  Future<void> _guardarPaciente() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete los campos obligatorios correctamente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de nacimiento es obligatoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_isEditing) {
        success = await DatabaseService().updatePatient(
          id: widget.patientId!,
          nombreCompleto: _nombreController.text,
          fechaNacimiento: _selectedDate!,
          genero: _generoController.text,
          telefono: _telefonoController.text,
          correo: _correoController.text,
          direccion: '', 
          nombreFamiliar: _familiarController.text,
          telefonoFamiliar: _telFamiliarController.text,
          parentesco: _parentescoController.text,
          estadoCivil: _estadoCivilController.text,
        );
      } else {
        success = await DatabaseService().addPatient(
          nombreCompleto: _nombreController.text,
          fechaNacimiento: _selectedDate!,
          genero: _generoController.text,
          telefono: _telefonoController.text,
          correo: _correoController.text,
          direccion: '', 
          nombreFamiliar: _familiarController.text,
          telefonoFamiliar: _telFamiliarController.text,
          parentesco: _parentescoController.text,
          estadoCivil: _estadoCivilController.text,
        );
      }

      if (success) {
        if (mounted) _mostrarPopupGuardado(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al ${_isEditing ? 'actualizar' : 'guardar'} paciente')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF89C6EF),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;

            // RESPONSIVIDAD
            bool isVerySmallMobile = maxWidth < 400;
            bool isSmallMobile = maxWidth < 600;
            bool isTablet = maxWidth >= 600 && maxWidth < 1100;

            double formWidth = isSmallMobile
                ? maxWidth * 0.95
                : isTablet
                ? 700
                : 900;

            double horizontalPadding = isVerySmallMobile
                ? 15
                : isSmallMobile
                ? 20
                : 60;

            // Tamaños de fuente responsivos
            double titleFontSize = isVerySmallMobile ? 20 : isSmallMobile ? 22 : isTablet ? 25 : 28;
            double subtitleFontSize = isVerySmallMobile ? 16 : isSmallMobile ? 18 : isTablet ? 20 : 22;
            double labelFontSize = isVerySmallMobile ? 12 : isSmallMobile ? 13 : isTablet ? 15 : 16;
            double buttonFontSize = isVerySmallMobile ? 11 : isSmallMobile ? 12 : isTablet ? 14 : 16;

            // Ancho de label responsivo
            bool stackLabels = isVerySmallMobile;
            double labelWidth = stackLabels ? double.infinity : isSmallMobile ? 100 : isTablet ? 160 : 200;

            // Ancho de botón responsivo
            double buttonWidth = isVerySmallMobile ? double.infinity : isSmallMobile ? 140 : isTablet ? 180 : 230;
            double buttonSpacing = isVerySmallMobile ? 10 : isSmallMobile ? 15 : isTablet ? 30 : 60;
            bool stackButtons = isVerySmallMobile;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isVerySmallMobile ? 15 : isSmallMobile ? 20 : 30,
                horizontal: isVerySmallMobile ? 10 : isSmallMobile ? 15 : 20,
              ),
              child: Container(
                width: formWidth,
                padding: EdgeInsets.symmetric(
                  vertical: isVerySmallMobile ? 25 : isSmallMobile ? 35 : 40,
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // TÍTULO PRINCIPAL
                      Text(
                        _isEditing ? "Editar paciente" : "Registro de paciente",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: isVerySmallMobile ? 25 : 40),

                      // SUBTÍTULO
                      Text(
                        "Datos personales",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isVerySmallMobile ? 20 : 30),

                      // CAMPOS PERSONALES
                      _buildLabelAndField(
                        "Nombre completo:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _nombreController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'El nombre es obligatorio';
                          if (value.length < 3) return 'El nombre es muy corto';
                          return null;
                        },
                      ),
                      _buildLabelAndField(
                        "Fecha de nacimiento:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _fechaNacController,
                        isReadOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'La fecha es obligatoria';
                          return null;
                        },
                        suffixIcon: Icons.calendar_today,
                      ),
                      _buildLabelAndField(
                        "Edad:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _edadController,
                        isReadOnly: true,
                      ),
                      _buildLabelAndField(
                        "Género:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _generoController,
                        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      _buildLabelAndField(
                        "Estado civil:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _estadoCivilController,
                        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      SizedBox(height: isVerySmallMobile ? 25 : 40),

                      // SUBTÍTULO
                      Text(
                        "Datos de contacto y emergencia",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: isVerySmallMobile ? 20 : 30),

                      // CAMPOS CONTACTO
                      _buildLabelAndField(
                        "Número de teléfono:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _telefonoController,
                        inputType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'El teléfono es obligatorio';
                          if (value.length < 10) return 'Teléfono inválido';
                          return null;
                        },
                      ),
                      _buildLabelAndField(
                        "Correo:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _correoController,
                        inputType: TextInputType.emailAddress,
                      ),
                      _buildLabelAndField(
                        "Nombre del familiar:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _familiarController,
                        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      _buildLabelAndField(
                        "Número del familiar:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _telFamiliarController,
                        inputType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      _buildLabelAndField(
                        "Parentesco:",
                        labelFontSize,
                        labelWidth,
                        stackLabels,
                        _parentescoController,
                        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      SizedBox(height: isVerySmallMobile ? 30 : 50),

                      // BOTONES
                      stackButtons
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildButton(
                                  text: "Cancelar registro",
                                  color: const Color(0xFF1991DB),
                                  textColor: Colors.black,
                                  onPressed: () => _regresarAlDashboard(context),
                                  fontSize: buttonFontSize,
                                  width: buttonWidth,
                                ),
                                SizedBox(height: buttonSpacing),
                                _buildButton(
                                  text: _isLoading ? "Guardando..." : "Guardar registro",
                                  color: const Color(0xFF1991DB),
                                  textColor: Colors.black,
                                  onPressed: _isLoading ? () {} : _guardarPaciente,
                                  fontSize: buttonFontSize,
                                  width: buttonWidth,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildButton(
                                  text: "Cancelar registro",
                                  color: const Color(0xFF1991DB),
                                  textColor: Colors.black,
                                  onPressed: () => _regresarAlDashboard(context),
                                  fontSize: buttonFontSize,
                                  width: buttonWidth,
                                ),
                                SizedBox(width: buttonSpacing),
                                _buildButton(
                                  text: _isLoading ? "Guardando..." : "Guardar registro",
                                  color: const Color(0xFF1991DB),
                                  textColor: Colors.black,
                                  onPressed: _isLoading ? () {} : _guardarPaciente,
                                  fontSize: buttonFontSize,
                                  width: buttonWidth,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // LABEL + TEXTFORMFIELD CON VALIDACIÓN
  // ----------------------------------------------------
  Widget _buildLabelAndField(
    String label,
    double fontSize,
    double labelWidth,
    bool stackVertically,
    TextEditingController controller, {
    bool isReadOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
    IconData? suffixIcon,
  }) {
    Widget inputWidget = Container(
      // height: 42, // Quitamos altura fija para permitir error text
      decoration: BoxDecoration(
        color: const Color(0xffd9d9d9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        keyboardType: inputType,
        validator: validator,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
          errorStyle: const TextStyle(height: 0.8), // Ajuste para que no desplace mucho
        ),
      ),
    );

    if (stackVertically) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            inputWidget,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 10), // Alinear con el input
              child: Text(
                label,
                style: TextStyle(fontSize: fontSize, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: inputWidget),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // BOTÓN PERSONALIZADO
  // ----------------------------------------------------
  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    required double fontSize,
    required double width,
  }) {
    return SizedBox(
      width: width == double.infinity ? double.infinity : width - 6,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadowColor: Colors.black.withOpacity(0.4),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // POPUP DE CONFIRMACIÓN
  // ----------------------------------------------------
  void _mostrarPopupGuardado(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (popupContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF84C4EE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // X de cerrar
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => _regresarAlDashboard(parentContext),
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Guardado",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // FUNCION REAL PARA REGRESAR AL DASHBOARD
  // ----------------------------------------------------
  void _regresarAlDashboard(BuildContext ctx) {
    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (_) => widget.returnRoute),
    );
  }
}
