import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AgregarPersonalScreen extends StatefulWidget {
  const AgregarPersonalScreen({super.key});

  @override
  State<AgregarPersonalScreen> createState() => _AgregarPersonalScreenState();
}

class _AgregarPersonalScreenState extends State<AgregarPersonalScreen> {
  // Controladores de textos
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController nacimientoCtrl = TextEditingController();
  final TextEditingController curpCtrl = TextEditingController();
  final TextEditingController rfcCtrl = TextEditingController();
  final TextEditingController generoCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController direccionCtrl = TextEditingController();

  // Archivos
  final List<PlatformFile?> _files = List.generate(7, (_) => null);

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
  //              POPUP GUARDADO EXITOSO
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
                Navigator.pop(context);
                Navigator.pop(context); // vuelve a la pantalla anterior
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
                buildInput("Nombre completo", nombreCtrl),
                buildInput("Fecha de nacimiento", nacimientoCtrl),
                buildInput("CURP", curpCtrl),
                buildInput("RFC", rfcCtrl),
                buildInput("Género", generoCtrl),
                buildInput("Teléfono de contacto", telefonoCtrl),
                buildInput("Correo electrónico", correoCtrl),
                buildInput("Dirección", direccionCtrl),

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

                // BOTONES FINALES
                Row(
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // INPUT DE TEXTO
  // ===============================
  Widget buildInput(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
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
}
