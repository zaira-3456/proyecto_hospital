import 'package:flutter/material.dart';
import 'recepcionist_dashboard.dart';
import 'models/cita_models.dart';
import 'services/cita_data_service.dart';
import 'services/appointments_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AgendarCitaPage extends StatefulWidget {
  final Widget returnRoute;

  const AgendarCitaPage({super.key, required this.returnRoute});

  @override
  State<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  int _currentStep = 0;

  // Controladores para Paso 1
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nssController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Variables para Paso 2 - DINÁMICAS BASADAS EN DATOS
  String? _areaIdSeleccionada;
  String? _doctorIdSeleccionado;
  String? _horaSeleccionada;
  DateTime? _fechaSeleccionada;
  DateTime _mesActual = DateTime.now();

  // Datos cargados de servicio (simula Firebase)
  List<Area> _areas = [];
  List<Doctor> _doctoresDisponibles = [];
  Map<DateTime, DisponibilidadDia> _disponibilidadMes = {};
  List<String> _horasDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarAreas();
  }

  // Helper para formatear mes en español sin dependencias de locale
  String _getMonthYearString(DateTime date) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  // CARGA DE DATOS
  Future<void> _cargarAreas() async {
    final areas = await CitaDataService.getAreas();
    if (mounted) {
      setState(() {
        _areas = areas;
      });
    }
  }

  Future<void> _onAreaChanged(String? areaId) async {
    List<Doctor> doctores = [];
    if (areaId != null) {
      doctores = await CitaDataService.getDoctoresByArea(areaId);
    }

    if (mounted) {
      setState(() {
        _areaIdSeleccionada = areaId;
        _doctorIdSeleccionado = null;
        _horaSeleccionada = null;
        _fechaSeleccionada = null;
        _horasDisponibles = [];
        _disponibilidadMes = {};
        _doctoresDisponibles = doctores;
      });
    }
  }

  Future<void> _onDoctorChanged(String? doctorId) async {
    Map<DateTime, DisponibilidadDia> disponibilidad = {};
    if (doctorId != null) {
      disponibilidad = await CitaDataService.getDisponibilidadMes(
        doctorId,
        _mesActual.year,
        _mesActual.month,
      );
    }

    if (mounted) {
      setState(() {
        _doctorIdSeleccionado = doctorId;
        _horaSeleccionada = null;
        _fechaSeleccionada = null;
        _horasDisponibles = [];
        _disponibilidadMes = disponibilidad;
      });
    }
  }

  Future<void> _onFechaChanged(DateTime fecha) async {
    List<String> horas = [];
    if (_doctorIdSeleccionado != null) {
      horas = await CitaDataService.getHorasDisponibles(
        _doctorIdSeleccionado!,
        fecha,
      );
    }

    if (mounted) {
      setState(() {
        _fechaSeleccionada = fecha;
        _horaSeleccionada = null;
        _horasDisponibles = horas;
      });
    }
  }

  Future<void> _onMesChanged(DateTime nuevoMes) async {
    Map<DateTime, DisponibilidadDia> disponibilidad = {};
    if (_doctorIdSeleccionado != null) {
      disponibilidad = await CitaDataService.getDisponibilidadMes(
        _doctorIdSeleccionado!,
        nuevoMes.year,
        nuevoMes.month,
      );
    }

    if (mounted) {
      setState(() {
        _mesActual = nuevoMes;
        _disponibilidadMes = disponibilidad;
      });
    }
  }

  // Validación de campos obligatorios en Paso 1
  bool _validateStep1() {
    return _nombreController.text.trim().isNotEmpty &&
        _telefonoController.text.trim().isNotEmpty &&
        _curpController.text.trim().isNotEmpty &&
        _correoController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nssController.dispose();
    _curpController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Método para guardar la cita en el servicio
  Future<void> _guardarCita() async {
    print('🔵 DEBUG: _guardarCita iniciado');
    try {
      final service = AppointmentsService();

      // Generar ID único para la cita
      final citaId = 'cita_${DateTime.now().millisecondsSinceEpoch}';

      // Crear paciente basado en los datos del paso 1
      final paciente = Paciente(
        id: 'pac_${DateTime.now().millisecondsSinceEpoch}',
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
        nss: _nssController.text,
        curp: _curpController.text,
        correo: _correoController.text,
      );

      // Obtener el doctor seleccionado
      if (_doctorIdSeleccionado == null)
        throw Exception('Doctor no seleccionado');
      final doctor = _doctoresDisponibles.firstWhere(
        (d) => d.id == _doctorIdSeleccionado,
      );

      // Determinar tipo de cita basado en el área
      TipoCita tipo = TipoCita.consultaGeneral;
      if (_areaIdSeleccionada == 'cardio' ||
          _areaIdSeleccionada == 'traumatologia') {
        tipo = TipoCita.especialidad;
      }

      if (_fechaSeleccionada == null) throw Exception('Fecha no seleccionada');
      if (_horaSeleccionada == null) throw Exception('Hora no seleccionada');

      // Crear la cita
      final nuevaCita = Cita(
        id: citaId,
        paciente: paciente,
        doctor: doctor,
        fecha: _fechaSeleccionada!,
        hora: _horaSeleccionada!,
        tipo: tipo,
        estado: EstadoCita.confirmada,
        createdAt: DateTime.now(),
      );

      print('  Guardando cita: ${nuevaCita.id} para ${paciente.nombre}');

      // Guardar en el servicio
      await service.addCita(nuevaCita);
      print('✅ DEBUG: Cita guardada exitosamente en servicio');
    } catch (e) {
      print('🔴 ERROR en _guardarCita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar cita: $e'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow; // Re-lanzar para que el llamador sepa que falló
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;

          bool isVerySmallMobile = maxWidth < 400;
          bool isSmallMobile = maxWidth < 550;
          bool isTablet = maxWidth >= 550 && maxWidth < 1100;

          double formWidth = isSmallMobile
              ? maxWidth * 0.95
              : isTablet
              ? 800
              : 950;
          double horizontalPadding = isVerySmallMobile
              ? 15
              : isSmallMobile
              ? 20
              : 40;

          return Column(
            children: [
              // HEADER FIJO - 70px en mobile, 115px en desktop
              Container(
                width: double.infinity,
                height: isSmallMobile ? 70 : 115,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(133, 196, 238, 1),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmallMobile
                        ? 20
                        : isSmallMobile
                        ? 30
                        : 50,
                    vertical: isSmallMobile ? 15 : 20,
                  ),
                  child: Row(
                    // Centrado en mobile, izquierda en desktop
                    mainAxisAlignment: isSmallMobile
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      // Logo - 40x40 en mobile, 100x100 en desktop
                      Container(
                        width: isSmallMobile ? 40 : 100,
                        height: isSmallMobile ? 40 : 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          size: isSmallMobile ? 30 : 70,
                          color: Color(0xFF1991DB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CONTENIDO CON SCROLL
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Column(
                        children: [
                          // INDICADORES DE PASO - Ocultos en Paso 3
                          if (_currentStep != 2)
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: 20,
                              ),
                              child: _buildStepIndicators(
                                isVerySmallMobile,
                                isSmallMobile,
                              ),
                            ),

                          // CONTENIDO DEL PASO ACTUAL
                          Padding(
                            padding: EdgeInsets.all(horizontalPadding),
                            child: _buildCurrentStep(
                              isVerySmallMobile,
                              isSmallMobile,
                              isTablet,
                              maxWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicators(bool isVerySmall, bool isSmall) {
    double fontSize = isVerySmall
        ? 12
        : isSmall
        ? 14
        : 16;
    double buttonWidth = isVerySmall
        ? 80
        : isSmall
        ? 100
        : 130;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepButton("Paso 1", 0, buttonWidth, fontSize),
        _buildStepButton("Paso 2", 1, buttonWidth, fontSize),
        _buildStepButton("Paso 3", 2, buttonWidth, fontSize),
      ],
    );
  }

  Widget _buildStepButton(
    String label,
    int stepIndex,
    double width,
    double fontSize,
  ) {
    bool isActive = _currentStep == stepIndex;

    return Container(
      width: width,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1991DB) : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
    bool isVerySmall,
    bool isSmall,
    bool isTablet,
    double maxWidth,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(isVerySmall, isSmall);
      case 1:
        return _buildStep2(isVerySmall, isSmall, isTablet, maxWidth);
      case 2:
        return _buildStep3(isVerySmall, isSmall);
      default:
        return Container();
    }
  }

  // PASO 1: Datos médicos
  Widget _buildStep1(bool isVerySmall, bool isSmall) {
    double titleSize = isVerySmall
        ? 20
        : isSmall
        ? 24
        : 28;
    double fontSize = isVerySmall
        ? 12
        : isSmall
        ? 13
        : 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cita medica",
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),

        const Text(
          "Para realizar una cita, debes tener a la mano:",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),

        const Text("• CURP", style: TextStyle(fontSize: 13)),
        const Text(
          "• Correo electrónico válido, el cual sera asociado a la CURP",
          style: TextStyle(fontSize: 13),
        ),
        const Text("• Número telefónico", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 25),

        _buildTextField("Nombre:\*", _nombreController, fontSize, isVerySmall),
        _buildTextField(
          "Número telefónico:\*",
          _telefonoController,
          fontSize,
          isVerySmall,
        ),
        _buildTextField("NSS:", _nssController, fontSize, isVerySmall),
        _buildTextField("CURP:\*", _curpController, fontSize, isVerySmall),

        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 20),
          child: GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://www.gob.mx/curp/'));
            },
            child: const Text(
              "¿No te sabes tu CURP? Consulta aquí",
              style: TextStyle(
                color: Color(0xFF1991DB),
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        _buildTextField(
          "Correo electronico:\*",
          _correoController,
          fontSize,
          isVerySmall,
        ),

        const SizedBox(height: 30),
        const Text(
          "Campos obligatorios",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 25),

        _buildNavigationButtons(isVerySmall, isSmall, showBack: false),
      ],
    );
  }

  // PASO 2: Selección de cita
  Widget _buildStep2(
    bool isVerySmall,
    bool isSmall,
    bool isTablet,
    double maxWidth,
  ) {
    double titleSize = isVerySmall
        ? 18
        : isSmall
        ? 22
        : 26;
    double fontSize = isVerySmall
        ? 12
        : isSmall
        ? 13
        : 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rellena lo siguiente",
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 25),

        // DROPDOWN: ÁREA
        _buildDynamicDropdown<String>(
          "Área",
          "Elige un area",
          _areaIdSeleccionada,
          _areas
              .map(
                (area) =>
                    DropdownMenuItem(value: area.id, child: Text(area.nombre)),
              )
              .toList(),
          (value) => _onAreaChanged(value),
          fontSize,
          isVerySmall,
        ),

        // DROPDOWN: MÉDICO
        _buildDynamicDropdown<String>(
          "Médico",
          _areaIdSeleccionada == null
              ? "Primero elige un área"
              : "Elige a un Dr./Dra.",
          _doctorIdSeleccionado,
          _doctoresDisponibles
              .map(
                (doctor) => DropdownMenuItem(
                  value: doctor.id,
                  child: Text(doctor.nombre),
                ),
              )
              .toList(),
          (value) => _onDoctorChanged(value),
          fontSize,
          isVerySmall,
          enabled: _areaIdSeleccionada != null,
        ),

        // DROPDOWN: HORA
        _buildDynamicDropdown<String>(
          "Hora",
          _fechaSeleccionada == null
              ? "Primero elige una fecha"
              : "Elige una hora",
          _horaSeleccionada,
          _horasDisponibles
              .map((hora) => DropdownMenuItem(value: hora, child: Text(hora)))
              .toList(),
          (value) {
            setState(() {
              _horaSeleccionada = value;
            });
          },
          fontSize,
          isVerySmall,
          enabled: _fechaSeleccionada != null && _horasDisponibles.isNotEmpty,
        ),

        const SizedBox(height: 15),

        Text(
          "Día",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),

        // CALENDARIO Y SIMBOLOGÍA
        maxWidth >= 600
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildCalendar()),
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: _buildLeyenda()),
                ],
              )
            : Column(
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 20),
                  _buildLeyenda(),
                ],
              ),

        const SizedBox(height: 30),
        const Text(
          "Campos obligatorios",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 25),

        _buildNavigationButtons(isVerySmall, isSmall, showBack: true),
      ],
    );
  }

  // PASO 3: Pantalla de confirmación
  Widget _buildStep3(bool isVerySmall, bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isVerySmall
            ? 40
            : isSmall
            ? 60
            : 80,
        horizontal: isVerySmall ? 20 : 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo del hospital
          Container(
            width: isVerySmall
                ? 80
                : isSmall
                ? 100
                : 120,
            height: isVerySmall
                ? 80
                : isSmall
                ? 100
                : 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1991DB), width: 3),
            ),
            child: Icon(
              Icons.local_hospital,
              size: isVerySmall
                  ? 45
                  : isSmall
                  ? 55
                  : 65,
              color: const Color(0xFF1991DB),
            ),
          ),

          SizedBox(
            height: isVerySmall
                ? 30
                : isSmall
                ? 40
                : 50,
          ),

          // Texto de confirmación
          Text(
            "¡Cita confirmada!",
            style: TextStyle(
              fontSize: isVerySmall
                  ? 28
                  : isSmall
                  ? 36
                  : 44,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: isVerySmall
                ? 50
                : isSmall
                ? 70
                : 90,
          ),

          // Botón Salir
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1991DB),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: isVerySmall
                      ? 30
                      : isSmall
                      ? 40
                      : 50,
                  vertical: isVerySmall
                      ? 12
                      : isSmall
                      ? 14
                      : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceptionistDashboard(),
                  ),
                );
              },
              child: Text(
                "Salir",
                style: TextStyle(
                  fontSize: isVerySmall
                      ? 14
                      : isSmall
                      ? 16
                      : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Campo de texto
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    double fontSize,
    bool isVerySmall,
  ) {
    if (isVerySmall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(0),
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
            width: 180,
            child: Text(label, style: TextStyle(fontSize: fontSize)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(0),
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

  // Helper: Dropdown dinámico
  Widget _buildDynamicDropdown<T>(
    String label,
    String hint,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
    double fontSize,
    bool isVerySmall, {
    bool enabled = true,
  }) {
    if (isVerySmall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: enabled ? const Color(0xFFD9D9D9) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  isExpanded: true,
                  value: value,
                  hint: Text(hint, style: TextStyle(fontSize: fontSize - 1)),
                  items: enabled ? items : [],
                  onChanged: enabled ? onChanged : null,
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
            width: 180,
            child: Text(label, style: TextStyle(fontSize: fontSize)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: enabled ? const Color(0xFFD9D9D9) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  isExpanded: true,
                  value: value,
                  hint: Text(hint, style: TextStyle(fontSize: fontSize - 1)),
                  items: enabled ? items : [],
                  onChanged: enabled ? onChanged : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calendario personalizado - SIN OVERFLOW
  Widget _buildCalendar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        bool isMobile = availableWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFF4AABDE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del mes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: isMobile ? 18 : 24,
                      ),
                    ),
                    onPressed: () {
                      final now = DateTime.now();
                      final previousMonth = DateTime(
                        _mesActual.year,
                        _mesActual.month - 1,
                      );

                      if (previousMonth.year > now.year ||
                          (previousMonth.year == now.year &&
                              previousMonth.month >= now.month)) {
                        _onMesChanged(previousMonth);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      _getMonthYearString(_mesActual),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 14 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: isMobile ? 18 : 24,
                      ),
                    ),
                    onPressed: () {
                      _onMesChanged(
                        DateTime(_mesActual.year, _mesActual.month + 1),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 6 : 10),

              // Días de la semana
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 10 : 14,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: isMobile ? 4 : 10),

              // Días del mes - sin fixed height
              ..._buildCalendarDays(),
            ],
          ),
        );
      },
    );
  }

  // Construir días del calendario
  List<Widget> _buildCalendarDays() {
    List<Widget> rows = [];
    DateTime firstDayOfMonth = DateTime(_mesActual.year, _mesActual.month, 1);
    int daysInMonth = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    int firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Días del mes anterior
    for (int i = 1; i < firstWeekday; i++) {
      DateTime prevMonthDay = firstDayOfMonth.subtract(
        Duration(days: firstWeekday - i),
      );
      dayWidgets.add(_buildDayCell(prevMonthDay.day, isOtherMonth: true));
    }

    // Días del mes actual
    for (int day = 1; day <= daysInMonth; day++) {
      dayWidgets.add(_buildDayCell(day));
    }

    // Días del mes siguiente
    int remainingDays = (7 - (dayWidgets.length % 7)) % 7;
    for (int day = 1; day <= remainingDays; day++) {
      dayWidgets.add(_buildDayCell(day, isNextMonth: true));
    }

    // Agrupar en semanas
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayWidgets
              .skip(i)
              .take(7)
              .map((widget) => Expanded(child: widget))
              .toList(),
        ),
      );
      rows.add(const SizedBox(height: 8));
    }

    return rows;
  }

  // Construir celda de día - 50x50px (ajustado por usuario)
  Widget _buildDayCell(
    int day, {
    bool isOtherMonth = false,
    bool isNextMonth = false,
  }) {
    DateTime thisDate;

    if (isOtherMonth) {
      thisDate = DateTime(_mesActual.year, _mesActual.month - 1, day);
    } else if (isNextMonth) {
      thisDate = DateTime(_mesActual.year, _mesActual.month + 1, day);
    } else {
      thisDate = DateTime(_mesActual.year, _mesActual.month, day);
    }

    bool isSelected =
        _fechaSeleccionada != null &&
        _fechaSeleccionada!.year == thisDate.year &&
        _fechaSeleccionada!.month == thisDate.month &&
        _fechaSeleccionada!.day == thisDate.day;

    // Verificar si es HOY
    DateTime today = DateTime.now();
    bool isToday =
        thisDate.year == today.year &&
        thisDate.month == today.month &&
        thisDate.day == today.day;

    Color? backgroundColor;
    bool isClickable = false;

    if (!isOtherMonth &&
        !isNextMonth &&
        _doctorIdSeleccionado != null &&
        _disponibilidadMes.containsKey(thisDate)) {
      final disponibilidad = _disponibilidadMes[thisDate]!;
      isClickable = disponibilidad.citasDisponibles > 0;

      switch (disponibilidad.estado) {
        case EstadoDisponibilidad.disponible:
          backgroundColor = Colors.green;
          break;
        case EstadoDisponibilidad.medianamenteOcupado:
          backgroundColor = Colors.yellow;
          break;
        case EstadoDisponibilidad.muyOcupado:
          backgroundColor = Colors.red;
          break;
      }
    }

    return GestureDetector(
      onTap: (isOtherMonth || isNextMonth || !isClickable)
          ? null
          : () {
              _onFechaChanged(thisDate);
            },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isToday
              ? Border.all(color: const Color(0xFFBEE8FF), width: 2)
              : (isSelected ? Border.all(color: Colors.white, width: 2) : null),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: (isOtherMonth || isNextMonth)
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Leyenda de colores
  Widget _buildLeyenda() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Simbología:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildLeyendaItem(Colors.green, "Disponible"),
          const SizedBox(height: 8),
          _buildLeyendaItem(Colors.yellow, "Medianamente ocupado"),
          const SizedBox(height: 8),
          _buildLeyendaItem(Colors.red, "Muy ocupado/Sin citas"),
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  // Botones de navegación
  Widget _buildNavigationButtons(
    bool isVerySmall,
    bool isSmall, {
    bool showBack = false,
    bool isLastStep = false,
  }) {
    double buttonWidth = isVerySmall
        ? double.infinity
        : isSmall
        ? 140
        : 160;
    double fontSize = isVerySmall ? 13 : 15;

    if (isVerySmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBack)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1991DB),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  if (_currentStep > 0) _currentStep--;
                });
              },
              child: Text(
                "Volver",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (showBack) const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1991DB),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              // Validar campos obligatorios en Paso 1
              if (_currentStep == 0 && !_validateStep1()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor completa todos los campos obligatorios: Nombre, Teléfono, CURP y Correo',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Si estamos en paso 2 (índice 1) y vamos a paso 3, guardar la cita
              if (_currentStep == 1) {
                await _guardarCita();
              }
              setState(() {
                if (_currentStep < 2) _currentStep++;
              });
            },
            child: Text(
              isLastStep ? "Confirmar" : "Continuar",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: showBack
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: [
        if (showBack)
          SizedBox(
            width: buttonWidth,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1991DB),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  if (_currentStep > 0) _currentStep--;
                });
              },
              child: Text(
                "Volver",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        SizedBox(
          width: buttonWidth,
          height: 42,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1991DB),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              // Validar campos obligatorios en Paso 1
              if (_currentStep == 0 && !_validateStep1()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor completa todos los campos obligatorios: Nombre, Teléfono, CURP y Correo',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Si estamos en paso 2 (índice 1) y vamos a paso 3, guardar la cita
              if (_currentStep == 1) {
                await _guardarCita();
              }
              setState(() {
                if (_currentStep < 2) _currentStep++;
              });
            },
            child: Text(
              isLastStep ? "Confirmar" : "Continuar",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
