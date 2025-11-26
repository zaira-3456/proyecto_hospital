import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'diseno_farmacia.dart';

class AddMedicineDialog extends StatefulWidget {
  const AddMedicineDialog({super.key});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _stockInicialController = TextEditingController(text: '0');
  final _stockMinimoController = TextEditingController(text: '0');
  final _precioController = TextEditingController();
  String? _tipo;
  String? _proveedor;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _stockInicialController.dispose();
    _stockMinimoController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  InputDecoration _input(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.archivoNarrow(fontSize: 14),
      hintStyle: GoogleFonts.archivoNarrow(
        fontSize: 13,
        color: Colors.grey[600],
      ),
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxDialogHeight =
        MediaQuery.of(context).size.height * 0.85; // 85% alto pantalla

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxDialogHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título + cerrar
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Agregar Medicamento',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _nameController,
                        decoration:
                            _input('Nombre', hint: 'Ej. Paracetamol'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _doseController,
                        decoration:
                            _input('Dosis', hint: 'Ej. 500mg'),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: _tipo,
                        decoration: _input('Tipo'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Analgésico',
                              child: Text('Analgésico')),
                          DropdownMenuItem(
                              value: 'Antiinflamatorio',
                              child: Text('Antiinflamatorio')),
                          DropdownMenuItem(
                              value: 'Antibiótico',
                              child: Text('Antibiótico')),
                          DropdownMenuItem(
                              value: 'Otro', child: Text('Otro')),
                        ],
                        onChanged: (v) => setState(() => _tipo = v),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _stockInicialController,
                              keyboardType: TextInputType.number,
                              decoration: _input('Stock Inicial'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _stockMinimoController,
                              keyboardType: TextInputType.number,
                              decoration: _input('Stock Mínimo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _precioController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        decoration: _input('Precio'),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: _proveedor,
                        decoration: _input('Proveedor'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Proveedor A',
                              child: Text('Proveedor A')),
                          DropdownMenuItem(
                              value: 'Proveedor B',
                              child: Text('Proveedor B')),
                        ],
                        onChanged: (v) => setState(() => _proveedor = v),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: kWhite,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            textStyle: GoogleFonts.archivo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            // Aquí podrías validar y guardar
                            Navigator.pop(context);
                          },
                          child: const Text('Agregar Medicamento'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
