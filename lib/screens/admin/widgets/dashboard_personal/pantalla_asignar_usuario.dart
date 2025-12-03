import 'package:flutter/material.dart';
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
  String? errorMessage;

  // ============================================================
  //           VALIDACIONES DE CAMPOS
  // ============================================================
  bool _validarCampos() {
    if (usuarioCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty ||
        passConfirmCtrl.text.trim().isEmpty) {
      setState(() => errorMessage = "Todos los campos son obligatorios.");
      return false;
    }

    if (passCtrl.text.trim() != passConfirmCtrl.text.trim()) {
      setState(() => errorMessage = "Las contraseñas no coinciden.");
      return false;
    }

    return true;
  }

  // ============================================================
  //             FUNCIÓN PREPARADA PARA TU BASE DE DATOS
  // ============================================================
  Future<bool> saveUserCredentialsToDB({
    required String username,
    required String password,
  }) async {
    // Aquí conectas tu backend cuando esté listo
    // Ejemplo futuro:
    /*
    final res = await http.post(
      Uri.parse("https://tu-api.com/create-user"),
      body: json.encode({
        "username": username,
        "password": password,
        "id_personal": idPersonal, // si lo necesitas
      }),
      headers: {"Content-Type": "application/json"},
    );

    return res.statusCode == 200;
    */

    await Future.delayed(const Duration(seconds: 2)); // Simulación
    return true; // Simulación de "usuario creado en BD"
  }

  // ============================================================
  //             FUNCIÓN PRINCIPAL DEL BOTÓN
  // ============================================================
  Future<void> _confirmarRegistro() async {
    if (!_validarCampos()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final db = DatabaseService();
    final username = usuarioCtrl.text.trim();
    final password = passCtrl.text.trim();

    // 1. Crear usuario en colección 'usuarios'
    final userOk = await db.createUser(
      username: username,
      password: password,
      nombre: widget.personalData['nombre'] ?? '',
      rol: widget.personalData['tipo'] ?? 'medico', // Usar tipo como rol
      telefono: widget.personalData['telefono'],
      departamento: widget.personalData['area'],
    );

    if (!userOk) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: El usuario ya existe o hubo un problema.";
      });
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
    );

    setState(() => isLoading = false);

    if (personalOk) {
      _popupExito();
    } else {
      setState(() {
        errorMessage = "Usuario creado, pero error al guardar datos de personal.";
      });
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
          title: const Text("Usuario registrado"),
          content: const Text("Las credenciales han sido guardadas correctamente."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // regresará al dashboard
              },
              child: const Text("Aceptar"),
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
    return Scaffold(
      body: Row(
        children: [
          // ============================================================
          //      PANEL IZQUIERDO (IMAGEN / LOGO)
          // ============================================================
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff3aa0ff), Color(0xff7ccaff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/logo_hospital.png", // <-- coloca tu logo
                  width: 260,
                ),
              ),
            ),
          ),

          // ============================================================
          //      PANEL DERECHO (FORMULARIO)
          // ============================================================
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Asignar usuario y contraseña",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff00205C),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Usuario y contraseña",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================== CAMPOS ====================
                  Row(
                    children: [
                      Expanded(child: _inputField("Nombre de usuario", usuarioCtrl)),
                      const SizedBox(width: 20),
                      Expanded(child: _inputField("Contraseña", passCtrl, obscure: true)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _inputField("Confirmar contraseña", passConfirmCtrl, obscure: true),

                  const SizedBox(height: 20),

                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),

                  const SizedBox(height: 40),

                  // ==================== BOTÓN CONFIRMAR ====================
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _confirmarRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Confirmar",
                              style:
                                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //           WIDGET DE INPUT PERSONALIZADO
  // ============================================================
  Widget _inputField(String label, TextEditingController ctrl,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
