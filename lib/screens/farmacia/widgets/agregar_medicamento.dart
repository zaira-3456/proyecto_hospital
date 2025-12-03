import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _guardarMedicamento() async {
    final nombre = _nameController.text.trim();
    final dosis = _doseController.text.trim();
    final stockInicial = int.tryParse(_stockInicialController.text) ?? 0;
    final stockMinimo = int.tryParse(_stockMinimoController.text) ?? 0;

    // permitir coma o punto para decimales
    final precioText = _precioController.text.trim().replaceAll(',', '.');
    final precio = double.tryParse(precioText) ?? 0.0;

    final tipo = _tipo?.trim();
    final proveedor = _proveedor?.trim();

    // Validaciones básicas
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }

    if (dosis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La dosis es obligatoria')),
      );
      return;
    }

    if (tipo == null || tipo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de medicamento')),
      );
      return;
    }

    if (precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser mayor a 0')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('medicamentos_inventario')
          .add({
        'nombre': nombre,
        'dosis': dosis,
        'tipo': tipo,
        'proveedor': proveedor ?? '',
        'stock': stockInicial,
        'stockMinimo': stockMinimo,
        'precioUnitario': precio,
        'activo': true,
        'creadoEn': FieldValue.serverTimestamp(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicamento agregado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
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
                        onChanged: (v) =>
                            setState(() => _proveedor = v),
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
                          onPressed: _guardarMedicamento,
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

