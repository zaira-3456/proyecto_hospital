import 'package:flutter/material.dart';
import '../../login/services/database_service.dart';

class RegistroPacientePage extends StatefulWidget {
  final Widget returnRoute;

  const RegistroPacientePage({super.key, required this.returnRoute});

  @override
  State<RegistroPacientePage> createState() => _RegistroPacientePageState();
}

class _RegistroPacientePageState extends State<RegistroPacientePage> {
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

  Future<void> _guardarPaciente() async {
    if (_nombreController.text.isEmpty || _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y teléfono son obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse fecha nacimiento if possible, else use now or null logic
      DateTime fechaNac = DateTime.now();
      try {
        // Asumiendo formato YYYY-MM-DD o similar, o simplemente guardamos string si cambiamos el servicio
        // Por ahora el servicio pide DateTime. Intentaremos parsear o usar dummy.
        // Mejor: cambiar el input a DatePicker en el futuro.
        fechaNac = DateTime.parse(_fechaNacController.text); 
      } catch (_) {}

      final success = await DatabaseService().addPatient(
        nombreCompleto: _nombreController.text,
        fechaNacimiento: fechaNac,
        genero: _generoController.text,
        telefono: _telefonoController.text,
        correo: _correoController.text,
        direccion: '', // No field in UI
        nombreFamiliar: _familiarController.text,
        telefonoFamiliar: _telFamiliarController.text,
        parentesco: _parentescoController.text,
        estadoCivil: _estadoCivilController.text,
      );

      if (success) {
        if (mounted) _mostrarPopupGuardado(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar paciente')),
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
            double titleFontSize = isVerySmallMobile
                ? 20
                : isSmallMobile
                ? 22
                : isTablet
                ? 25
                : 28;
            double subtitleFontSize = isVerySmallMobile
                ? 16
                : isSmallMobile
                ? 18
                : isTablet
                ? 20
                : 22;
            double labelFontSize = isVerySmallMobile
                ? 12
                : isSmallMobile
                ? 13
                : isTablet
                ? 15
                : 16;
            double buttonFontSize = isVerySmallMobile
                ? 11
                : isSmallMobile
                ? 12
                : isTablet
                ? 14
                : 16;

            // Ancho de label responsivo
            bool stackLabels = isVerySmallMobile;
            double labelWidth = stackLabels
                ? double.infinity
                : isSmallMobile
                ? 100
                : isTablet
                ? 160
                : 200;

            // Ancho de botón responsivo
            double buttonWidth = isVerySmallMobile
                ? double.infinity
                : isSmallMobile
                ? 140
                : isTablet
                ? 180
                : 230;
            double buttonSpacing = isVerySmallMobile
                ? 10
                : isSmallMobile
                ? 15
                : isTablet
                ? 30
                : 60;
            bool stackButtons = isVerySmallMobile;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isVerySmallMobile
                    ? 15
                    : isSmallMobile
                    ? 20
                    : 30,
                horizontal: isVerySmallMobile
                    ? 10
                    : isSmallMobile
                    ? 15
                    : 20,
              ),
              child: Container(
                width: formWidth,
                padding: EdgeInsets.symmetric(
                  vertical: isVerySmallMobile
                      ? 25
                      : isSmallMobile
                      ? 35
                      : 40,
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TÍTULO PRINCIPAL
                    Text(
                      "Registro de paciente",
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
                    ),
                    _buildLabelAndField(
                      "Fecha de nacimiento:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _fechaNacController,
                    ),
                    _buildLabelAndField(
                      "Edad:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _edadController,
                    ),
                    _buildLabelAndField(
                      "Género:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _generoController,
                    ),
                    _buildLabelAndField(
                      "Estado civil:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _estadoCivilController,
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
                    ),
                    _buildLabelAndField(
                      "Correo:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _correoController,
                    ),
                    _buildLabelAndField(
                      "Nombre del familiar:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _familiarController,
                    ),
                    _buildLabelAndField(
                      "Número del familiar:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _telFamiliarController,
                    ),
                    _buildLabelAndField(
                      "Parentesco:",
                      labelFontSize,
                      labelWidth,
                      stackLabels,
                      _parentescoController,
                    ),
                    SizedBox(height: isVerySmallMobile ? 30 : 50),

                    // BOTONES - RESPONSIVOS
                    stackButtons
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildButton(
                                text: "Cancelar registro",
                                color: const Color(0xFF1991DB),
                                textColor: Colors.black,
                                onPressed: () {
                                  _regresarAlDashboard(context);
                                },
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
                                onPressed: () {
                                  _regresarAlDashboard(context);
                                },
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
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // LABEL + TEXTFIELD REAL, ESCRIBIBLE
  // ----------------------------------------------------
  Widget _buildLabelAndField(
    String label,
    double fontSize,
    double labelWidth,
    bool stackVertically,
    TextEditingController controller,
  ) {
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
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xffd9d9d9),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: fontSize),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(fontSize: fontSize, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffd9d9d9),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: fontSize),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
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
