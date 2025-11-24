import 'package:flutter/material.dart';
import '../Recepcionista/recepcionist_dashboard.dart';

class RegistroPacientePage extends StatelessWidget {
  final Widget returnRoute;

  const RegistroPacientePage({super.key, required this.returnRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF89C6EF),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;

            // RESPONSIVIDAD
            double formWidth =
                maxWidth < 600 ? maxWidth * 0.9 : maxWidth < 1100 ? 700 : 900;

            double horizontalPadding =
                maxWidth < 600 ? 20 : 60;

            // Tamaños de fuente responsivos
            double titleFontSize = maxWidth < 600 ? 22 : maxWidth < 1100 ? 25 : 28;
            double subtitleFontSize = maxWidth < 600 ? 18 : maxWidth < 1100 ? 20 : 22;
            double labelFontSize = maxWidth < 600 ? 14 : maxWidth < 1100 ? 15 : 16;
            double buttonFontSize = maxWidth < 600 ? 12 : maxWidth < 1100 ? 14 : 16;
            
            // Ancho de label responsivo
            double labelWidth = maxWidth < 600 ? 120 : maxWidth < 1100 ? 160 : 200;
            
            // Ancho de botón responsivo
            double buttonWidth = maxWidth < 600 ? 140 : maxWidth < 1100 ? 180 : 230;
            double buttonSpacing = maxWidth < 600 ? 15 : maxWidth < 1100 ? 30 : 60;

            return SingleChildScrollView(
              child: Container(
                width: formWidth,
                padding: EdgeInsets.symmetric(
                  vertical: 40,
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
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // SUBTÍTULO
                    Text(
                      "Datos personales",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // CAMPOS PERSONALES
                    _buildLabelAndField("Nombre completo:", labelFontSize, labelWidth),
                    _buildLabelAndField("Fecha de nacimiento:", labelFontSize, labelWidth),
                    _buildLabelAndField("Edad:", labelFontSize, labelWidth),
                    _buildLabelAndField("Género:", labelFontSize, labelWidth),
                    _buildLabelAndField("Estado civil:", labelFontSize, labelWidth),
                    const SizedBox(height: 40),

                    // SUBTÍTULO
                    Text(
                      "Datos de contacto y emergencia",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // CAMPOS CONTACTO
                    _buildLabelAndField("Número de teléfono:", labelFontSize, labelWidth),
                    _buildLabelAndField("Correo:", labelFontSize, labelWidth),
                    _buildLabelAndField("Nombre del familiar:", labelFontSize, labelWidth),
                    _buildLabelAndField("Número del familiar:", labelFontSize, labelWidth),
                    _buildLabelAndField("Parentesco:", labelFontSize, labelWidth),
                    const SizedBox(height: 50),

                    // BOTONES - SIEMPRE HORIZONTALES
                    Row(
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
                          text: "Guardar registro",
                          color: const Color(0xFF1991DB),
                          textColor: Colors.black,
                          onPressed: () {
                            _mostrarPopupGuardado(context);
                          },
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
  Widget _buildLabelAndField(String label, double fontSize, double labelWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xffd9d9d9),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                style: TextStyle(fontSize: fontSize),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
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
      width: width,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // X de cerrar
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => _regresarAlDashboard(parentContext),
                    child: const Icon(Icons.close, size: 15, color: Colors.white),
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
      MaterialPageRoute(builder: (_) => const ReceptionistDashboard()),
    );
  }
}