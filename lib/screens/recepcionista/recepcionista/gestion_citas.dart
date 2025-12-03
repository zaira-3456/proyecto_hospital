import 'package:flutter/material.dart';
import 'models/cita_models.dart';
import 'services/appointments_service.dart';
import 'services/cita_data_service.dart';
import 'widgets/side_menu_recepcionist.dart';

class GestionCitasPage extends StatefulWidget {
  const GestionCitasPage({super.key});

  @override
  State<GestionCitasPage> createState() => _GestionCitasPageState();
}

class _GestionCitasPageState extends State<GestionCitasPage> {
  final AppointmentsService _service = AppointmentsService();
  final TextEditingController _searchController = TextEditingController();
  List<Cita> _citas = [];
  List<Cita> _citasFiltradas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    print('🟡 GestionCitas: _onServiceUpdate called');
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    print('🔵 GestionCitas: _loadAppointments called');
    setState(() => _isLoading = true);
    final citas = await _service.fetchCitas();
    print('📊 GestionCitas: Loaded ${citas.length} citas');
    setState(() {
      _citas = citas;
      _citasFiltradas = citas;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _citasFiltradas = _citas;
      } else {
        _citasFiltradas = _service.searchByPatientName(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isMobile = width < 850;
          bool isTablet = width >= 850 && width < 1280;

          double horizontalPadding = isMobile ? 20 : (isTablet ? 30 : 50);
          double headerFontSize = isMobile ? 28 : (isTablet ? 34 : 40);
          double subtitleFontSize = isMobile ? 14 : (isTablet ? 16 : 18);
          double titleFontSize = isMobile ? 20 : (isTablet ? 24 : 28);

          return Row(
            children: [
              if (!isMobile) const SideMenuReception(),

              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isMobile ? 20 : 30,
                      ),
                      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMobile)
                            Row(
                              children: [
                                Builder(
                                  builder: (context) => IconButton(
                                    icon: const Icon(Icons.menu, size: 28),
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Gestión de Citas',
                                    style: TextStyle(
                                      fontFamily: 'Archivo',
                                      fontSize: headerFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'Gestión de Citas',
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          SizedBox(height: isMobile ? 5 : 10),
                          Text(
                            'Edita o cancela tus citas confirmadas',
                            style: TextStyle(
                              fontFamily: 'Archivo',
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar cita...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Archivo',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            Text(
                              'Todas las Citas',
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 25),

                            if (_isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1991DB),
                                  ),
                                ),
                              )
                            else if (_citasFiltradas.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50),
                                  child: Text(
                                    'No se encontraron citas',
                                    style: TextStyle(
                                      fontFamily: 'Archivo',
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _citasFiltradas.length,
                                itemBuilder: (context, index) {
                                  return _CitaCard(
                                    cita: _citasFiltradas[index],
                                    isMobile: isMobile,
                                    onEdit: () =>
                                        _showEditDialog(_citasFiltradas[index]),
                                    onCancel: () => _showCancelDialog(
                                      _citasFiltradas[index],
                                    ),
                                    onDelete: () =>
                                        _confirmDelete(_citasFiltradas[index]),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      drawer: const Drawer(child: SideMenuReception(isDrawer: true)),
    );
  }

  void _showEditDialog(Cita cita) {
    showDialog(
      context: context,
      builder: (context) => _EditCitaDialog(
        cita: cita,
        onSave: (updatedCita) async {
          await _service.updateCita(updatedCita);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCancelDialog(Cita cita) {
    showDialog(
      context: context,
      builder: (context) => _CancelConfirmDialog(
        onConfirm: () async {
          await _service.cancelCita(cita.id);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(Cita cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta cita permanentemente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _service.deleteCita(cita.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Cita cita;
  final bool isMobile;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _CitaCard({
    required this.cita,
    required this.isMobile,
    required this.onEdit,
    required this.onCancel,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isCanceled = cita.estado == EstadoCita.cancelada;

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8AA5EA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(cita.fecha),
                    style: const TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cita.hora,
                    style: const TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              cita.paciente.nombre,
              style: const TextStyle(
                fontFamily: 'Archivo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              '${cita.doctor.nombre} - ${cita.tipo.displayName}',
              style: const TextStyle(
                fontFamily: 'Archivo',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.black54),
                const SizedBox(width: 5),
                Text(
                  cita.paciente.telefono,
                  style: const TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCanceled
                        ? const Color(0xFFFFCDD2)
                        : const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cita.estado.displayName,
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCanceled
                          ? const Color(0xFFC62828)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ),

                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (!isCanceled)
                      _ActionButton(
                        icon: Icons.edit,
                        label: 'Editar',
                        color: const Color(0xFF1991DB),
                        onTap: onEdit,
                        compact: true,
                      ),
                    _ActionButton(
                      icon: Icons.delete,
                      label: 'Eliminar',
                      color: const Color(0xFFE53935),
                      onTap: onDelete,
                      compact: true,
                    ),
                    if (!isCanceled)
                      _ActionButton(
                        icon: Icons.cancel,
                        label: 'Cancelar',
                        color: const Color(0xFFFFA726),
                        onTap: onCancel,
                        compact: true,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF8AA5EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _formatDate(cita.fecha),
                  style: const TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  cita.hora,
                  style: const TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.paciente.nombre,
                  style: const TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  '${cita.doctor.nombre} - ${cita.tipo.displayName}',
                  style: const TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      cita.paciente.telefono,
                      style: const TextStyle(
                        fontFamily: 'Archivo',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCanceled
                        ? const Color(0xFFFFCDD2)
                        : const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cita.estado.displayName,
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCanceled
                          ? const Color(0xFFC62828)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCanceled)
                _ActionButton(
                  icon: Icons.edit,
                  label: 'Editar',
                  color: const Color(0xFF1991DB),
                  onTap: onEdit,
                ),

              if (!isCanceled) const SizedBox(height: 10),

              if (!isCanceled)
                _ActionButton(
                  icon: Icons.cancel,
                  label: 'Cancelar',
                  color: const Color(0xFFFFA726),
                  onTap: onCancel,
                ),

              if (!isCanceled) const SizedBox(height: 10),

              _ActionButton(
                icon: Icons.delete,
                label: 'Eliminar',
                color: const Color(0xFFE53935),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 16 : 18, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Archivo',
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCitaDialog extends StatefulWidget {
  final Cita cita;
  final Function(Cita) onSave;

  const _EditCitaDialog({required this.cita, required this.onSave});

  @override
  State<_EditCitaDialog> createState() => _EditCitaDialogState();
}

class _EditCitaDialogState extends State<_EditCitaDialog> {
  late TextEditingController _telefonoController;
  late DateTime _selectedDate;
  late String _selectedHora;
  late String _selectedDoctor;
  late TipoCita _selectedTipo;
  late EstadoCita _selectedEstado;

  DateTime _mesActual = DateTime.now();
  Map<DateTime, DisponibilidadDia> _disponibilidadMes = {};
  List<String> _horasDisponibles = [];
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController(
      text: widget.cita.paciente.telefono,
    );
    _selectedDate = widget.cita.fecha;
    _selectedHora = widget.cita.hora;
    _selectedDoctor = widget.cita.doctor.nombre;
    _selectedTipo = widget.cita.tipo;
    _selectedEstado = widget.cita.estado;
    _doctorId = widget.cita.doctor.id;
    _mesActual = DateTime(_selectedDate.year, _selectedDate.month);

    _cargarDisponibilidad();
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDisponibilidad() async {
    if (_doctorId != null) {
      final disponibilidad = await CitaDataService.getDisponibilidadMes(
        _doctorId!,
        _mesActual.year,
        _mesActual.month,
      );
      final horas = await CitaDataService.getHorasDisponibles(
        _doctorId!,
        _selectedDate,
      );
      
      if (mounted) {
        setState(() {
          _disponibilidadMes = disponibilidad;
          _horasDisponibles = horas;
        });
      }
    }
  }

  Future<void> _onMesChanged(DateTime nuevoMes) async {
    if (_doctorId != null) {
      final disponibilidad = await CitaDataService.getDisponibilidadMes(
        _doctorId!,
        nuevoMes.year,
        nuevoMes.month,
      );
      
      if (mounted) {
        setState(() {
          _mesActual = nuevoMes;
          _disponibilidadMes = disponibilidad;
        });
      }
    } else {
      setState(() {
        _mesActual = nuevoMes;
      });
    }
  }

  Future<void> _onFechaChanged(DateTime fecha) async {
    if (_doctorId != null) {
      final horas = await CitaDataService.getHorasDisponibles(
        _doctorId!,
        fecha,
      );
      
      if (mounted) {
        setState(() {
          _selectedDate = fecha;
          _horasDisponibles = horas;
          if (_horasDisponibles.isNotEmpty &&
              !_horasDisponibles.contains(_selectedHora)) {
            _selectedHora = _horasDisponibles.first;
          }
        });
      }
    } else {
      setState(() {
        _selectedDate = fecha;
      });
    }
  }

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

  void _save() {
    // Create updated patient with new phone number
    final updatedPaciente = Paciente(
      id: widget.cita.paciente.id,
      nombre: widget.cita.paciente.nombre,
      telefono: _telefonoController.text.trim(),
      nss: widget.cita.paciente.nss,
      curp: widget.cita.paciente.curp,
      correo: widget.cita.paciente.correo,
    );

    final updatedCita = widget.cita.copyWith(
      paciente: updatedPaciente,
      fecha: _selectedDate,
      hora: _selectedHora,
      tipo: _selectedTipo,
      estado: _selectedEstado,
    );

    widget.onSave(updatedCita);
  }

  void _showCancelConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => _CancelConfirmDialog(
        onConfirm: () {
          final canceledCita = widget.cita.copyWith(
            estado: EstadoCita.cancelada,
          );
          widget.onSave(canceledCita);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final dialogWidth = isMobile ? size.width * 0.9 : 500.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: size.height * 0.85),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editar cita',
                  style: TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Paciente'),
                    _buildReadOnlyField(widget.cita.paciente.nombre),

                    const SizedBox(height: 15),

                    _buildLabel('Teléfono'),
                    _buildTextField(_telefonoController),

                    const SizedBox(height: 15),

                    _buildLabel('Fecha*'),
                    _buildCalendar(),

                    const SizedBox(height: 15),

                    _buildLabel('Hora'),
                    _horasDisponibles.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'No hay horas disponibles',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : _buildDropdown<String>(
                            value: _horasDisponibles.contains(_selectedHora)
                                ? _selectedHora
                                : _horasDisponibles.first,
                            items: _horasDisponibles,
                            onChanged: (val) =>
                                setState(() => _selectedHora = val!),
                          ),

                    const SizedBox(height: 15),

                    _buildLabel('Doctor'),
                    _buildReadOnlyField(_selectedDoctor),

                    const SizedBox(height: 15),

                    _buildLabel('Tipo de cita'),
                    _buildReadOnlyField(_selectedTipo.displayName),

                    const SizedBox(height: 15),

                    _buildLabel('Estado'),
                    _buildDropdown<EstadoCita>(
                      value: _selectedEstado,
                      items: EstadoCita.values,
                      displayName: (estado) => estado.displayName,
                      onChanged: (val) =>
                          setState(() => _selectedEstado = val!),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1991DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              _showCancelConfirm();
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1991DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _save,
                            child: const Text(
                              'Guardar',
                              style: TextStyle(
                                fontFamily: 'Archivo',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4AABDE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 18,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () => _onMesChanged(
                  DateTime(_mesActual.year, _mesActual.month + 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          ..._buildCalendarDays(),

          const SizedBox(height: 10),

          _buildLeyendaCompacta(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarDays() {
    List<Widget> rows = [];
    DateTime firstDayOfMonth = DateTime(_mesActual.year, _mesActual.month, 1);
    int daysInMonth = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    int firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    for (int i = 1; i < firstWeekday; i++) {
      DateTime prevMonthDay = firstDayOfMonth.subtract(
        Duration(days: firstWeekday - i),
      );
      dayWidgets.add(_buildDayCell(prevMonthDay.day, isOtherMonth: true));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      dayWidgets.add(_buildDayCell(day));
    }

    int remainingDays = (7 - (dayWidgets.length % 7)) % 7;
    for (int day = 1; day <= remainingDays; day++) {
      dayWidgets.add(_buildDayCell(day, isNextMonth: true));
    }

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
      rows.add(const SizedBox(height: 6));
    }

    return rows;
  }

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
        _selectedDate.year == thisDate.year &&
        _selectedDate.month == thisDate.month &&
        _selectedDate.day == thisDate.day;

    DateTime today = DateTime.now();
    bool isToday =
        thisDate.year == today.year &&
        thisDate.month == today.month &&
        thisDate.day == today.day;

    Color? backgroundColor;
    bool isClickable = false;

    if (!isOtherMonth &&
        !isNextMonth &&
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
          : () => _onFechaChanged(thisDate),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isToday
              ? Border.all(color: const Color(0xFFBEE8FF), width: 2)
              : (isSelected ? Border.all(color: Colors.white, width: 2) : null),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: (isOtherMonth || isNextMonth)
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeyendaCompacta() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Simbología:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildLeyendaItemCompacto(Colors.green, 'Disponible'),
          const SizedBox(height: 6),
          _buildLeyendaItemCompacto(Colors.yellow, 'Medianamente ocupado'),
          const SizedBox(height: 6),
          _buildLeyendaItemCompacto(Colors.red, 'Muy ocupado/Sin citas'),
        ],
      ),
    );
  }

  Widget _buildLeyendaItemCompacto(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Archivo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    String Function(T)? displayName,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayName != null ? displayName(item) : item.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CancelConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _CancelConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF85C4EE),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro?',
              style: TextStyle(
                fontFamily: 'Archivo',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onConfirm,
                  child: const Text(
                    'Si',
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
