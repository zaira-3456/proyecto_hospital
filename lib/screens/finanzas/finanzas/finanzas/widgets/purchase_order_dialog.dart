import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _detailsController = TextEditingController();
  final _budgetController = TextEditingController();
  
  String? _selectedProvider;
  String? _selectedStatus;
  bool _isProviderDropdownOpen = false;
  bool _isStatusDropdownOpen = false;
  List<String> _providers = [];
  bool _isLoadingProviders = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      final snapshot = await _firestore.collection('finanzas_proveedores').get();
      setState(() {
        _providers = snapshot.docs
            .map((doc) => (doc.data()['nombre'] ?? '') as String)
            .where((name) => name.isNotEmpty)
            .toList();
        _isLoadingProviders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProviders = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar proveedores: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
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

                // Proveedor Dropdown
                _buildLabel('Proveedor'),
                _buildProviderDropdown(),
                const SizedBox(height: 16),

                _buildLabel('Detalles'),
                _buildTextField(controller: _detailsController, hint: 'Descripción de los detalles'),
                const SizedBox(height: 16),

                _buildLabel('Asignar Presupuesto'),
                _buildTextField(controller: _budgetController, hint: 'Presupuesto', keyboardType: TextInputType.number),
                const SizedBox(height: 16),

                _buildLabel('Estado'),
                _buildStatusDropdown(),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedProvider == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor selecciona un proveedor')),
                          );
                          return;
                        }
                        
                        final newOrder = PurchaseOrder(
                          id: 'OC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          providerName: _selectedProvider!,
                          type: _detailsController.text,
                          area: 'General',
                          budget: double.tryParse(_budgetController.text) ?? 0.0,
                          status: _selectedStatus ?? 'Solicitud',
                        );
                        widget.onSave(newOrder);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFPrimaryBlue,
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

  Widget _buildProviderDropdown() {
    if (_isLoadingProviders) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Cargando proveedores...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_providers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.shade50,
        ),
        child: Row(
          children: const [
            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay proveedores registrados',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isProviderDropdownOpen = !_isProviderDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: _isProviderDropdownOpen 
                  ? const BorderRadius.vertical(top: Radius.circular(8))
                  : BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedProvider ?? 'Seleccionar Proveedor',
                    style: TextStyle(
                      color: _selectedProvider == null ? Colors.grey : Colors.black87,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isProviderDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_isProviderDropdownOpen)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: _providers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final provider = entry.value;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedProvider = provider;
                        _isProviderDropdownOpen = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: index != _providers.length - 1 
                            ? Border(bottom: BorderSide(color: Colors.grey.shade100)) 
                            : null,
                        color: _selectedProvider == provider 
                            ? kFLightBlue 
                            : Colors.white,
                      ),
                      child: Text(
                        provider,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedProvider == provider 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      children: [
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
              children: ['Solicitud', 'Aprobada', 'Recibida', 'Cancelada'].map((String value) {
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
      ],
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
