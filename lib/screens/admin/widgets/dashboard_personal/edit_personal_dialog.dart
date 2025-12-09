import 'package:flutter/material.dart';
import '../../../login/services/database_service.dart';

class EditPersonalDialog extends StatefulWidget {
  final Map<String, dynamic> personnel;

  const EditPersonalDialog({
    super.key,
    required this.personnel,
  });

  @override
  State<EditPersonalDialog> createState() => _EditPersonalDialogState();
}

class _EditPersonalDialogState extends State<EditPersonalDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  late TextEditingController _nombreController;
  late TextEditingController _puestoController;
  late TextEditingController _nacimientoController;
  late TextEditingController _edadController;
  late TextEditingController _curpController;
  late TextEditingController _rfcController;
  late TextEditingController _generoController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;

  String? _selectedArea;
  String? _selectedTurno;
  String? _selectedEstado;
  String? _selectedTipo;
  DateTime? _selectedDate;

  List<Map<String, dynamic>> _areas = [];
  bool _loadingAreas = true;

  final List<String> _turnos = ['Matutino', 'Vespertino', 'Nocturno'];
  final List<String> _estados = ['Activo', 'Inactivo', 'Licencia'];
  final List<String> _tipos = [
    'medico',
    'enfermeria',
    'administrativo',
    'farmacia',
    'recepcion',
    'finanzas',
    'laboratorio',
  ];

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con valores actuales
    _nombreController = TextEditingController(text: widget.personnel['nombre'] ?? '');
    _puestoController = TextEditingController(text: widget.personnel['puesto'] ?? '');
    _curpController = TextEditingController(text: widget.personnel['curp'] ?? '');
    _rfcController = TextEditingController(text: widget.personnel['rfc'] ?? '');
    _generoController = TextEditingController(text: widget.personnel['genero'] ?? '');
    _telefonoController = TextEditingController(text: widget.personnel['telefono'] ?? '');
    _correoController = TextEditingController(text: widget.personnel['correo'] ?? '');
    _direccionController = TextEditingController(text: widget.personnel['direccion'] ?? '');
    _edadController = TextEditingController();
    _nacimientoController = TextEditingController();

    // Inicializar fecha de nacimiento si existe
    if (widget.personnel['fechaNacimiento'] != null) {
      if (widget.personnel['fechaNacimiento'] is DateTime) {
        _selectedDate = widget.personnel['fechaNacimiento'];
      } else {
        try {
          _selectedDate = DateTime.parse(widget.personnel['fechaNacimiento'].toString());
        } catch (e) {
          _selectedDate = null;
        }
      }
      
      if (_selectedDate != null) {
        _nacimientoController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
        _calculateAge(_selectedDate!);
      }
    }

    // Inicializar valores de dropdowns con validación
    final areaValue = widget.personnel['area']?.toString() ?? '';
    _selectedArea = areaValue.isNotEmpty ? areaValue : null;
    
    // Validar turno contra lista permitida
    final turnoValue = widget.personnel['turno']?.toString() ?? '';
    _selectedTurno = _turnos.contains(turnoValue) ? turnoValue : null;
    
    // Validar estado contra lista permitida
    final estadoValue = widget.personnel['estado']?.toString() ?? '';
    _selectedEstado = _estados.contains(estadoValue) ? estadoValue : 'Activo';
    
    // Validar tipo contra lista permitida
    final tipoValue = widget.personnel['tipo']?.toString() ?? '';
    _selectedTipo = _tipos.contains(tipoValue) ? tipoValue : null;

    _loadAreas();
  }

  void _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    _edadController.text = age.toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _nacimientoController.text = "${picked.day}/${picked.month}/${picked.year}";
        _calculateAge(picked);
      });
    }
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await _dbService.getHospitalAreas();
      setState(() {
        _areas = areas;
        _loadingAreas = false;
      });
    } catch (e) {
      setState(() {
        _loadingAreas = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando áreas: $e')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos requeridos')),
      );
      return;
    }

    if (_selectedArea == null || _selectedArea!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un área')),
      );
      return;
    }

    if (_selectedTurno == null || _selectedTurno!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un turno')),
      );
      return;
    }

    if (_selectedEstado == null || _selectedEstado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un estado')),
      );
      return;
    }

    if (_selectedTipo == null || _selectedTipo!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione el tipo de personal')),
      );
      return;
    }

    // Preparar datos para actualizar
    final Map<String, dynamic> updatedData = {
      'nombre': _nombreController.text.trim(),
      'puesto': _puestoController.text.trim(),
      'area': _selectedArea!,
      'turno': _selectedTurno!,
      'estado': _selectedEstado!,
      'tipo': _selectedTipo!,
      'curp': _curpController.text.trim(),
      'rfc': _rfcController.text.trim(),
      'genero': _generoController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'correo': _correoController.text.trim(),
      'direccion': _direccionController.text.trim(),
    };

    // Agregar fecha de nacimiento si está seleccionada
    if (_selectedDate != null) {
      updatedData['fechaNacimiento'] = _selectedDate;
    }

    try {
      final success = await _dbService.updatePersonnel(
        personnelId: widget.personnel['id'],
        data: updatedData,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Retornar true para indicar que se guardó
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar personal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _puestoController.dispose();
    _nacimientoController.dispose();
    _edadController.dispose();
    _curpController.dispose();
    _rfcController.dispose();
    _generoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Editar Personal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 32),

            // Formulario con scroll
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === DATOS PERSONALES ===
                      _sectionHeader('Datos Personales'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Nombre completo',
                        controller: _nombreController,
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      
                      _buildTextField(
                        label: 'Fecha de nacimiento',
                        controller: _nacimientoController,
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),

                      _buildTextField(
                        label: 'Edad',
                        controller: _edadController,
                        icon: Icons.cake,
                        readOnly: true,
                      ),

                      _buildTextField(
                        label: 'CURP',
                        controller: _curpController,
                        icon: Icons.badge,
                      ),

                      _buildTextField(
                        label: 'RFC',
                        controller: _rfcController,
                        icon: Icons.account_balance_wallet,
                      ),

                      _buildTextField(
                        label: 'Género',
                        controller: _generoController,
                        icon: Icons.wc,
                      ),

                      _buildTextField(
                        label: 'Teléfono',
                        controller: _telefonoController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildTextField(
                        label: 'Correo electrónico',
                        controller: _correoController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          // Solo validar formato si hay algo escrito
                          if (value != null && value.isNotEmpty && !value.contains('@')) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Dirección',
                        controller: _direccionController,
                        icon: Icons.home,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      // === DATOS LABORALES ===
                      _sectionHeader('Datos Laborales'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Puesto',
                        controller: _puestoController,
                        icon: Icons.work,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El puesto es requerido';
                          }
                          return null;
                        },
                      ),

                      // Tipo de Personal
                      _buildDropdown(
                        label: 'Tipo de Personal',
                        value: _selectedTipo,
                        items: _tipos,
                        onChanged: (value) {
                          setState(() {
                            _selectedTipo = value;
                          });
                        },
                        icon: Icons.category,
                      ),

                      // Área
                      _loadingAreas
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDropdown(
                              label: 'Área',
                              value: _selectedArea,
                              items: _areas.map((a) => a['nombre'].toString()).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedArea = value;
                                });
                              },
                              icon: Icons.business,
                            ),

                      // Turno
                      _buildDropdown(
                        label: 'Turno',
                        value: _selectedTurno,
                        items: _turnos,
                        onChanged: (value) {
                          setState(() {
                            _selectedTurno = value;
                          });
                        },
                        icon: Icons.access_time,
                      ),

                      // Estado
                      _buildDropdown(
                        label: 'Estado',
                        value: _selectedEstado,
                        items: _estados,
                        onChanged: (value) {
                          setState(() {
                            _selectedEstado = value;
                          });
                        },
                        icon: Icons.toggle_on,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 32),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    // Solo usar initialValue si el valor está en la lista de items
    final validValue = (value != null && items.contains(value)) ? value : null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: validValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione $label';
          }
          return null;
        },
      ),
    );
  }
}
