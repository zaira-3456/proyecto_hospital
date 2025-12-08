import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 NUEVO

import 'widgets/diseno_farmacia.dart';
import 'widgets/agregar_medicamento.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Medicine> _filterMedicines(List<Medicine> medicines) {
    if (_searchQuery.isEmpty) return medicines;
    final query = _searchQuery.toLowerCase();
    return medicines.where((m) =>
      m.nombre.toLowerCase().contains(query) ||
      m.tipo.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 900;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gestión de Inventario',
                      style: GoogleFonts.archivo(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: kBlack,
                      ),
                    ),
                    const HospitalLogoCircle(),
                  ],
                ),
                const SizedBox(height: 22),

                // Banda gris con título y buscador
                Container(
                  width: double.infinity,
                  color: const Color(0xFFE1E1E1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Inventario de Medicamentos',
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 22,
                            letterSpacing: 1,
                            color: kBlack,
                          ),
                        ),
                      ),
                      if (!isNarrow)
                        SizedBox(
                          width: 260,
                          child: _buildSearchField(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                if (isNarrow)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 10),
                    child: _buildSearchField(),
                  ),

                // ====== CONTENEDOR DE TABLA (máx 960 x 560) ======
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, innerConstraints) {
                      const double maxTableWidth = 960;
                      const double maxTableHeight = 560;

                      final double visibleWidth =
                          innerConstraints.maxWidth < maxTableWidth
                              ? innerConstraints.maxWidth
                              : maxTableWidth;

                      final double visibleHeight =
                          innerConstraints.maxHeight < maxTableHeight
                              ? innerConstraints.maxHeight
                              : maxTableHeight;

                      return Center(
                        child: SizedBox(
                          width: visibleWidth,
                          height: visibleHeight,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: maxTableWidth,
                                      ),
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'medicamentos_inventario')
                                            .orderBy('nombre')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16),
                                              child: Text(
                                                'Error al cargar inventario',
                                                style: GoogleFonts
                                                    .archivoNarrow(),
                                              ),
                                            );
                                          }

                                          if (snapshot
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }

                                          final docs =
                                              snapshot.data!.docs;
                                          if (docs.isEmpty) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(16),
                                              child: Text(
                                                'No hay medicamentos registrados.',
                                                style: GoogleFonts
                                                    .archivoNarrow(),
                                              ),
                                            );
                                          }

                                          final allMedicines = docs
                                              .map((d) =>
                                                  Medicine.fromFirestore(d))
                                              .toList();
                                          
                                          final medicines = _filterMedicines(allMedicines);

                                          if (medicines.isEmpty && _searchQuery.isNotEmpty) {
                                            return Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'No se encontraron medicamentos para "$_searchQuery"',
                                                style: GoogleFonts.archivoNarrow(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            );
                                          }

                                          return DataTableTheme(
                                            data: DataTableThemeData(
                                              headingRowColor:
                                                  WidgetStateProperty.all(
                                                kPrimaryBlue,
                                              ),
                                              headingTextStyle:
                                                  GoogleFonts.archivo(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 0.8,
                                                color: kWhite,
                                              ),
                                              dataTextStyle:
                                                  GoogleFonts
                                                      .archivoNarrow(
                                                fontSize: 14,
                                                color: kBlack,
                                              ),
                                            ),
                                            child: DataTable(
                                              columnSpacing: 32,
                                              columns: const [
                                                DataColumn(
                                                    label:
                                                        Text('Medicamento')),
                                                DataColumn(
                                                    label: Text('Tipo')),
                                                DataColumn(
                                                    label: Text('Dosis')),
                                                DataColumn(
                                                    label: Text('Stock')),
                                                DataColumn(
                                                    label: Text('Precio')),
                                              ],
                                              rows: medicines
                                                  .map(
                                                    (m) => DataRow(
                                                      cells: [
                                                        DataCell(
                                                            Text(m.nombre)),
                                                        DataCell(
                                                            Text(m.tipo)),
                                                        DataCell(
                                                            Text(m.dosis)),
                                                        DataCell(
                                                          _StockChip(
                                                              unidades: m
                                                                  .stock),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            '\$${m.precio.toStringAsFixed(2)}',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Botón agregar medicamento
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0EDF7),
                      foregroundColor: kBlack,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      textStyle: GoogleFonts.archivoNarrow(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddMedicineDialog(),
                      );
                    },
                    child: const Text('+ Agregar Medicamento'),
                  ),
                ),
              ],
            );
          },
        ),
      );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        hintText: 'Buscar medicamento',
        hintStyle: GoogleFonts.archivoNarrow(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: kWhite,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final int unidades;

  const _StockChip({required this.unidades});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (unidades < 50) {
      color = kPureRed;
    } else if (unidades < 100) {
      color = kOrange;
    } else {
      color = kGreen;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$unidades unidades',
        style: GoogleFonts.archivoNarrow(
          fontSize: 12,
          color: kWhite,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class Medicine {
  final String nombre;
  final String tipo;
  final String dosis;
  final int stock;
  final double precio;

  Medicine(
    this.nombre,
    this.tipo,
    this.dosis,
    this.stock,
    this.precio,
  );

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final nombre = (data['nombre'] ?? '').toString();
    final tipo = (data['tipo'] ?? '').toString();
    final dosis = (data['dosis'] ?? '').toString();

    final stockRaw = data['stock'];
    int stock;
    if (stockRaw is int) {
      stock = stockRaw;
    } else {
      stock = int.tryParse('$stockRaw') ?? 0;
    }

    final precioRaw = data['precioUnitario'];
    double precio;
    if (precioRaw is num) {
      precio = precioRaw.toDouble();
    } else {
      precio = double.tryParse('$precioRaw') ?? 0.0;
    }

    return Medicine(nombre, tipo, dosis, stock, precio);
  }
}
