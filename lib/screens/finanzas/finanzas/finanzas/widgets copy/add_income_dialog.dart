import 'package:flutter/material.dart';
import '../models/financial_models.dart';

class AddIncomeDialog extends StatefulWidget {
  const AddIncomeDialog({super.key});

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedPaymentMethod;
  String? _selectedArea;

  final List<String> _paymentMethods = ['Efectivo', 'Tarjeta', 'Transferencia'];
  final List<String> _areas = ['Hospital', 'Consulta', 'Emergencia', 'Laboratorio', 'Farmacia'];

  @override
  void dispose() {
    _dateController.dispose();
    _clientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newRecord = IncomeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID generation
        date: DateTime.now(), // Using current date for now as parsing DD/MM/AA is complex without a package
        client: _clientController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        paymentMethod: _selectedPaymentMethod ?? '',
        area: _selectedArea ?? '',
      );
      Navigator.of(context).pop(newRecord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final dialogWidth = isSmallScreen ? constraints.maxWidth * 0.9 : 400.0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar ingresos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Fecha
                    _buildLabel('Fecha'),
                    TextFormField(
                      controller: _dateController,
                      decoration: _inputDecoration('DD/MM/AA'),
                      validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Cliente
                    _buildLabel('Cliente'),
                    TextFormField(
                      controller: _clientController,
                      decoration: _inputDecoration('Nombre del Cliente'),
                      validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Monto
                    _buildLabel('Monto'),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('\$ Monto'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Campo requerido';
                        if (double.tryParse(value!) == null) return 'Monto inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Método de pago
                    _buildLabel('Método de pago'),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: _inputDecoration('Seleccionar Metodo de pago'),
                      isDense: true,
                      menuMaxHeight: 200,
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(
                            method,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                      validator: (value) => value == null ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Área
                    _buildLabel('Área'),
                    DropdownButtonFormField<String>(
                      value: _selectedArea,
                      decoration: _inputDecoration('Seleccionar Área'),
                      isDense: true,
                      menuMaxHeight: 200,
                      items: _areas.map((area) {
                        return DropdownMenuItem(
                          value: area,
                          child: Text(
                            area,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedArea = value),
                      validator: (value) => value == null ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 24),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4), // Cyan color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Agregar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00BCD4)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

