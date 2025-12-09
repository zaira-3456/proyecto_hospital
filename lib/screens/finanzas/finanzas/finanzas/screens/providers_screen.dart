import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/finance_colors.dart';
import '../models/provider_models.dart';
import '../widgets/provider_dialog.dart';
import '../widgets/purchase_order_dialog.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _searchQuery = '';
  String _searchProviderQuery = '';

  List<Provider> _filterProviders(List<Provider> providers) {
    if (_searchProviderQuery.isEmpty) {
      return providers;
    }
    final query = _searchProviderQuery.toLowerCase();
    return providers.where((provider) {
      return provider.name.toLowerCase().contains(query) ||
             provider.phone.toLowerCase().contains(query) ||
             provider.email.toLowerCase().contains(query) ||
             provider.service.toLowerCase().contains(query);
    }).toList();
  }

  List<PurchaseOrder> _filterOrders(List<PurchaseOrder> orders) {
    if (_searchQuery.isEmpty) {
      return orders;
    }
    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      return order.id.toLowerCase().contains(query) ||
             order.providerName.toLowerCase().contains(query) ||
             order.status.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addProvider(Provider provider) async {
    try {
      await _firestore.collection('finanzas_proveedores').add({
        'nombre': provider.name,
        'telefono': provider.phone,
        'correo': provider.email,
        'servicio': provider.service,
        'estado': provider.status,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proveedor agregado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar proveedor: $e')),
        );
      }
    }
  }

  Future<void> _editProvider(Provider provider, String docId) async {
    try {
      await _firestore.collection('finanzas_proveedores').doc(docId).update({
        'nombre': provider.name,
        'telefono': provider.phone,
        'correo': provider.email,
        'servicio': provider.service,
        'estado': provider.status,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proveedor actualizado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar proveedor: $e')),
        );
      }
    }
  }

  Future<void> _deleteProvider(String docId) async {
    try {
      await _firestore.collection('finanzas_proveedores').doc(docId).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proveedor eliminado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar proveedor: $e')),
        );
      }
    }
  }

  Future<void> _addOrder(PurchaseOrder order) async {
    try {
      await _firestore.collection('finanzas_ordenes_compra').add({
        'id': order.id,
        'proveedorNombre': order.providerName,
        'tipo': order.type,
        'area': order.area,
        'presupuesto': order.budget,
        'estado': order.status,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden de compra creada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear orden de compra: $e')),
        );
      }
    }
  }

  Future<void> _deleteOrder(String docId) async {
    try {
      await _firestore.collection('finanzas_ordenes_compra').doc(docId).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden de compra eliminada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar orden de compra: $e')),
        );
      }
    }
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
              const Text(
                'Proveedores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const FinanceLogoCircle(),
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
                  
                  // Buscador de Proveedores
                  _buildProviderSearchBar(),
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
            backgroundColor: kFPrimaryBlue,
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

  Widget _buildProviderSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchProviderQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, teléfono, correo o servicio...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          if (_searchProviderQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchProviderQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProvidersTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('finanzas_proveedores').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final providers = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Provider(
            name: data['nombre'] ?? '',
            phone: data['telefono'] ?? '',
            email: data['correo'] ?? '',
            service: data['servicio'] ?? '',
            status: data['estado'] ?? 'Activo',
          );
        }).toList();

        final filteredProviders = _filterProviders(providers);

        if (filteredProviders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _searchProviderQuery.isEmpty 
                        ? 'No hay proveedores registrados'
                        : 'No se encontraron proveedores',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: 1000,
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
                    color: kFLightBlue,
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
                ...snapshot.data!.docs.asMap().entries.where((entry) {
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;
                  final provider = Provider(
                    name: data['nombre'] ?? '',
                    phone: data['telefono'] ?? '',
                    email: data['correo'] ?? '',
                    service: data['servicio'] ?? '',
                    status: data['estado'] ?? 'Activo',
                  );
                  return _filterProviders([provider]).isNotEmpty;
                }).map((entry) {
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;
                  final provider = Provider(
                    name: data['nombre'] ?? '',
                    phone: data['telefono'] ?? '',
                    email: data['correo'] ?? '',
                    service: data['servicio'] ?? '',
                    status: data['estado'] ?? 'Activo',
                  );
                  
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
                                      onSave: (updatedProvider) => _editProvider(updatedProvider, doc.id),
                                    ),
                                  );
                                },
                                child: const Text('Editar', style: TextStyle(color: Colors.green)),
                              ),
                              TextButton(
                                onPressed: () => _deleteProvider(doc.id),
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
      },
    );
  }

  Widget _buildOrdersTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('finanzas_ordenes_compra').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return PurchaseOrder(
            id: data['id'] ?? '',
            providerName: data['proveedorNombre'] ?? '',
            type: data['tipo'] ?? '',
            area: data['area'] ?? '',
            budget: (data['presupuesto'] ?? 0.0).toDouble(),
            status: data['estado'] ?? '',
          );
        }).toList();

        final filteredOrders = _filterOrders(orders);

        if (filteredOrders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty 
                        ? 'No hay órdenes de compra registradas'
                        : 'No se encontraron órdenes de compra',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: 800,
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
                    color: kFLightBlue,
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
                ...snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final order = PurchaseOrder(
                    id: data['id'] ?? '',
                    providerName: data['proveedorNombre'] ?? '',
                    type: data['tipo'] ?? '',
                    area: data['area'] ?? '',
                    budget: (data['presupuesto'] ?? 0.0).toDouble(),
                    status: data['estado'] ?? '',
                  );
                  return _filterOrders([order]).isNotEmpty;
                }).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final order = PurchaseOrder(
                    id: data['id'] ?? '',
                    providerName: data['proveedorNombre'] ?? '',
                    type: data['tipo'] ?? '',
                    area: data['area'] ?? '',
                    budget: (data['presupuesto'] ?? 0.0).toDouble(),
                    status: data['estado'] ?? '',
                  );
                  
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
                              onPressed: () => _deleteOrder(doc.id),
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
      },
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
            color: kFLightBlue,
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
