import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../login/services/database_service.dart';

class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  
  String _selectedRole = 'admin';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<Map<String, String>> _roles = [
    {'value': 'admin', 'label': 'Administrador'},
    {'value': 'medico', 'label': 'Médico'},
    {'value': 'farmacia', 'label': 'Farmacia'},
    {'value': 'recepcion', 'label': 'Recepción'},
    {'value': 'enfermeria', 'label': 'Enfermería'},
    {'value': 'finance', 'label': 'Finanzas'},
    {'value': 'laboratorio', 'label': 'Laboratorio'},
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbService = DatabaseService();
      
      final success = await dbService.createUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        nombre: _nameController.text.trim(),
        rol: _selectedRole,
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        telefono: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        departamento: _departmentController.text.trim().isEmpty 
            ? null 
            : _departmentController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Usuario "${_usernameController.text}" creado exitosamente',
              style: GoogleFonts.archivo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Error: El usuario ya existe o hubo un problema',
              style: GoogleFonts.archivo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al crear usuario: $e', style: GoogleFonts.archivo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.archivo(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintText: hint ?? '*Campo obligatorio',
            hintStyle: GoogleFonts.archivo(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;

    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE - COMPANY LOGO
          if (!isSmallScreen)
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A237E), // Azul oscuro/morado profundo
                      Color(0xFF283593), // Azul índigo
                      Color(0xFF3949AB), // Azul medio
                      Color(0xFF42A5F5), // Azul claro
                    ],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/empresa.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.business,
                        size: 200,
                        color: Colors.white.withOpacity(0.8),
                      );
                    },
                  ),
                ),
              ),
            ),

          // RIGHT SIDE - CREATE USER FORM
          Expanded(
            flex: isSmallScreen ? 1 : 1,
            child: Container(
              color: Colors.grey.shade50,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 60,
                    vertical: 40,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Crear nuevo usuario',
                            style: GoogleFonts.archivo(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Usuario y contraseña',
                            style: GoogleFonts.archivo(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Username
                          _buildTextField(
                            controller: _usernameController,
                            label: 'Nombre de usuario:',
                            hint: 'hospital_norte',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingrese un nombre de usuario';
                              }
                              if (value.trim().contains(' ')) {
                                return 'El usuario no puede contener espacios';
                              }
                              if (value.trim().length < 3) {
                                return 'El usuario debe tener al menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Password
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Contraseña temporal:',
                            hint: 'Mínimo 6 caracteres',
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nombre completo:',
                            hint: 'Hospital del Norte',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingrese el nombre completo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Role
                          Text(
                            'Rol en el sistema:',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            style: GoogleFonts.archivo(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem(
                                value: role['value'],
                                child: Text(role['label']!, style: GoogleFonts.archivo()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                          ),
                          const SizedBox(height: 24),

                          // Email (opcional)
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email: (opcional)',
                            hint: 'admin@hospitalnorte.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Email inválido';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Phone (opcional)
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Teléfono: (opcional)',
                            hint: '555-777-7777',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),

                          // Department (opcional)
                          _buildTextField(
                            controller: _departmentController,
                            label: 'Departamento: (opcional)',
                            hint: 'Administración',
                          ),
                          const SizedBox(height: 24),

                          // Info box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF1E3A8A).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF1E3A8A),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'El usuario deberá cambiar su contraseña en el primer inicio de sesión',
                                    style: GoogleFonts.archivo(
                                      fontSize: 13,
                                      color: const Color(0xFF1E3A8A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Crear Usuario',
                                      style: GoogleFonts.archivo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
