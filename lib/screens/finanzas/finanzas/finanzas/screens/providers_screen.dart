import 'package:flutter/material.dart';
import '../models/provider_models.dart';
import '../widgets/provider_dialog.dart';
import '../widgets/purchase_order_dialog.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  // Dummy data for Providers
  final List<Provider> _providers = [
    Provider(name: 'Proveedor 1', phone: '756 112 3045', email: 'proveedor1@gmail.com', service: 'Medicamento', status: 'Activo'),
    Provider(name: 'Peoveedor 2', phone: '756 113 3241', email: 'proveedor2@gmail.com', service: 'Material Quirurgico', status: 'Activo'),
    Provider(name: 'Proveedor 3', phone: '756 152 4562', email: 'proveedor3@gmail.com', service: 'Moviliario', status: 'Inactivo'),
    Provider(name: 'Proveedor 4', phone: '756 189 4589', email: 'proveedor4@gmail.com', service: 'Servicios', status: 'Activo'),
    Provider(name: 'Proveedor 5', phone: '756 145 5859', email: 'proveedor5@gmail.com', service: 'Suministros Generales', status: 'Activo'),
  ];

  // Dummy data for Purchase Orders
  final List<PurchaseOrder> _orders = [
    PurchaseOrder(id: 'OC001', providerName: 'Proveedor 1', type: 'Medicamentos', area: 'Laboratorio', budget: 5000.00, status: 'Solicitud'),
    PurchaseOrder(id: 'OC002', providerName: 'Proveedor 2', type: 'Material Quirurgico', area: 'Farmacia', budget: 12000.00, status: 'Aprovada'),
    PurchaseOrder(id: 'OC003', providerName: 'Proveedor 3', type: 'Moviliario', area: 'Servicio', budget: 20000.00, status: 'Recibida'),
  ];

  String _searchQuery = '';

  List<PurchaseOrder> get _filteredOrders {
    if (_searchQuery.isEmpty) {
      return _orders;
    }
    final query = _searchQuery.toLowerCase();
    return _orders.where((order) {
      return order.id.toLowerCase().contains(query) ||
             order.providerName.toLowerCase().contains(query) ||
             order.status.toLowerCase().contains(query);
    }).toList();
  }

  void _addOrder(PurchaseOrder order) {
    setState(() {
      _orders.add(order);
    });
  }

  void _deleteOrder(int index) {
    setState(() {
      // Find the actual object to remove since index might be from filtered list
      final orderToRemove = _filteredOrders[index];
      _orders.remove(orderToRemove);
    });
  }

  void _addProvider(Provider provider) {
    setState(() {
      _providers.add(provider);
    });
  }

  void _editProvider(Provider provider, int index) {
    setState(() {
      _providers[index] = provider;
    });
  }

  void _deleteProvider(int index) {
    setState(() {
      _providers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(), // Spacer for centering if needed
              const Text(
                'Proveedores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Logo placeholder or user icon
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFB3E5FC),
                ),
                child: const Icon(Icons.person, color: Color(0xFF00BCD4)),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Providers List Section
                  _buildSectionHeader('Lista de Proveedores', 'Agregar', () {
                    showDialog(
                      context: context,
                      builder: (context) => ProviderDialog(
                        onSave: _addProvider,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildProvidersTable(),
                  const SizedBox(height: 32),

                  // Purchase Orders Section
                  _buildSectionHeader('Órdenes de Compras', 'Crear nueva compra', () {
                    showDialog(
                      context: context,
                      builder: (context) => PurchaseOrderDialog(
                        onSave: _addOrder,
                      ),
                    );
                  }, isBlueButton: true),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1100) {
                         return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildOrdersTable()),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _buildFilterBox()),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildOrdersTable(),
                            const SizedBox(height: 24),
                            _buildFilterBox(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String buttonText, VoidCallback onPressed, {bool isBlueButton = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0288D1), // Darker blue
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 1000, // Fixed minimum width for scrolling
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFB3E5FC), // Light blue header
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Telefono', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Correo', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Servicio que ofrece', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Acción', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ],
              ),
            ),
            // Table Rows
            ..._providers.asMap().entries.map((entry) {
              final index = entry.key;
              final provider = entry.value;
              return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(provider.name)),
                  Expanded(flex: 2, child: Text(provider.phone)),
                  Expanded(flex: 3, child: Text(provider.email)),
                  Expanded(flex: 3, child: Text(provider.service)),
                  Expanded(flex: 1, child: Text(provider.status)),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ProviderDialog(
                                provider: provider,
                                onSave: (updatedProvider) => _editProvider(updatedProvider, index),
                              ),
                            );
                          },
                          child: const Text('Editar', style: TextStyle(color: Colors.green)),
                        ),
                        TextButton(
                          onPressed: () => _deleteProvider(index),
                          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 800, // Fixed minimum width for scrolling
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFB3E5FC), // Light blue header
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Proveedor', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Área', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Presupuesto', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Acción', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ],
              ),
            ),
            // Table Rows
            ..._filteredOrders.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text(order.id)),
                  Expanded(flex: 2, child: Text(order.providerName)),
                  Expanded(flex: 2, child: Text(order.type)),
                  Expanded(flex: 2, child: Text(order.area)),
                  Expanded(flex: 2, child: Text('\$ ${order.budget.toStringAsFixed(2)}')),
                  Expanded(flex: 2, child: Text(order.status)),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: TextButton(
                        onPressed: () => _deleteOrder(index),
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ),
                ],
              ),
            );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFB3E5FC),
            child: const Text(
              'Filtros',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Busqueda por ID, proveedor o estado',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'OC001',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
