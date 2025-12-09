import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../login/services/database_service.dart';

class PantallaAsignarUsuario extends StatefulWidget {
  final Map<String, dynamic> personalData;

  const PantallaAsignarUsuario({super.key, required this.personalData});

  @override
  State<PantallaAsignarUsuario> createState() => _PantallaAsignarUsuarioState();
}

class _PantallaAsignarUsuarioState extends State<PantallaAsignarUsuario> {
  final TextEditingController usuarioCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController passConfirmCtrl = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passCtrl.dispose();
    passConfirmCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  //             FUNCIÓN PRINCIPAL DEL BOTÓN
  // ============================================================
  Future<void> _confirmarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final db = DatabaseService();
    final username = usuarioCtrl.text.trim();
    final password = passCtrl.text.trim();

    // 0. Eliminar credenciales antiguas si existen (para permitir reasignación)
    print('🔄 Eliminando credenciales antiguas si existen...');
    await db.deleteUserCredentials(username);

    // 1. Crear usuario en colección 'users'
    final userOk = await db.createUser(
      username: username,
      password: password,
      nombre: widget.personalData['nombre'] ?? '',
      rol: widget.personalData['tipo'] ?? 'medico', // Usar tipo como rol
      telefono: widget.personalData['telefono'],
      departamento: widget.personalData['area'],
    );

    if (!userOk) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: El usuario ya existe o hubo un problema',
            style: GoogleFonts.archivo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Crear registro en colección 'personal'
    final personalOk = await db.addPersonnel(
      nombre: widget.personalData['nombre'] ?? '',
      puesto: widget.personalData['puesto'] ?? '',
      area: widget.personalData['area'] ?? '',
      tipo: widget.personalData['tipo'] ?? '',
      turno: widget.personalData['turno'] ?? '',
      estado: widget.personalData['estado'] ?? 'Activo',
      fechaNacimiento: widget.personalData['fechaNacimiento'],
      curp: widget.personalData['curp'],
      rfc: widget.personalData['rfc'],
      genero: widget.personalData['genero'],
      telefono: widget.personalData['telefono'],
      correo: widget.personalData['correo'],
      direccion: widget.personalData['direccion'],
    );

    setState(() => isLoading = false);

    if (personalOk) {
      _popupExito();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usuario creado, pero error al guardar datos de personal',
            style: GoogleFonts.archivo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  //                POPUP DE ÉXITO
  // ============================================================
  void _popupExito() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Usuario registrado", style: GoogleFonts.archivo()),
          content: Text(
            "Las credenciales han sido guardadas correctamente.",
            style: GoogleFonts.archivo(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // regresará al dashboard
              },
              child: Text("Aceptar", style: GoogleFonts.archivo()),
            )
          ],
        );
      },
    );
  }

  // ============================================================
  //                WIDGET PRINCIPAL
  // ============================================================
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

          // RIGHT SIDE - FORM
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
                            'Asignar usuario y contraseña',
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
                          Text(
                            'Nombre de usuario:',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: usuarioCtrl,
                            style: GoogleFonts.archivo(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: '*Campo obligatorio',
                              hintStyle: GoogleFonts.archivo(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingrese un nombre de usuario';
                              }
                              if (value.trim().length < 3) {
                                return 'El usuario debe tener al menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Password
                          Text(
                            'Contraseña:',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passCtrl,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.archivo(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: '*Campo obligatorio',
                              hintStyle: GoogleFonts.archivo(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Confirm Password
                          Text(
                            'Confirmar contraseña:',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passConfirmCtrl,
                            obscureText: _obscureConfirmPassword,
                            style: GoogleFonts.archivo(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: '*Campo obligatorio',
                              hintStyle: GoogleFonts.archivo(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirme su contraseña';
                              }
                              if (value != passCtrl.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _confirmarRegistro,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
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
                                      'Confirmar',
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
