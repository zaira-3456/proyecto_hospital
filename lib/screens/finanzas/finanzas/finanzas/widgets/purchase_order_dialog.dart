import 'package:flutter/material.dart';
import 'finance_colors.dart';
import '../models/provider_models.dart';

class PurchaseOrderDialog extends StatefulWidget {
  final Function(PurchaseOrder) onSave;

  const PurchaseOrderDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<PurchaseOrderDialog> createState() => _PurchaseOrderDialogState();
}

class _PurchaseOrderDialogState extends State<PurchaseOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _detailsController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _selectedStatus;
  bool _isStatusDropdownOpen = false;

  @override
  void dispose() {
    _providerController.dispose();
    _detailsController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width > 450 ? 400 : MediaQuery.of(context).size.width * 0.9,
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
                      'Nueva Orden',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fields
                _buildLabel('Proveedor'),
                _buildTextField(controller: _providerController, hint: 'Nombre del proveedor'),
                const SizedBox(height: 16),

                _buildLabel('Detalles'),
                _buildTextField(controller: _detailsController, hint: 'Descripción de los detalles'),
                const SizedBox(height: 16),

                _buildLabel('Asignar Presupuesto'),
                _buildTextField(controller: _budgetController, hint: 'Presupuesto', keyboardType: TextInputType.number),
                const SizedBox(height: 16),

                _buildLabel('Estado'),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isStatusDropdownOpen = !_isStatusDropdownOpen;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: _isStatusDropdownOpen 
                          ? const BorderRadius.vertical(top: Radius.circular(8))
                          : BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedStatus ?? 'Seleccionar Estado',
                          style: TextStyle(
                            color: _selectedStatus == null ? Colors.grey : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          _isStatusDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isStatusDropdownOpen)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                        right: BorderSide(color: Colors.grey.shade300),
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    ),
                    child: Column(
                      children: ['Solicitud', 'Aprovada', 'Recibida', 'Cancelada'].map((String value) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedStatus = value;
                              _isStatusDropdownOpen = false;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: value != 'Cancelada' ? Border(bottom: BorderSide(color: Colors.grey.shade100)) : null,
                            ),
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newOrder = PurchaseOrder(
                          id: 'OC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Simple ID generation
                          providerName: _providerController.text,
                          type: _detailsController.text, // Using details as type/description
                          area: 'General', // Default area
                          budget: double.tryParse(_budgetController.text) ?? 0.0,
                          status: _selectedStatus ?? 'Solicitud',
                        );
                        widget.onSave(newOrder);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFPrimaryBlue, // Blue color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Crear orden',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: kFPrimaryBlue),
        ),
      ),
    );
  }
}


