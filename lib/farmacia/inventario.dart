import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_farmacia.dart';
import 'widgets/agregar_medicamento.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicines = _dummyMedicines;

    return PharmacyLayout(
      selectedIndex: 1,
      child: Padding(
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
                          child: _SearchField(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                if (isNarrow)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 10),
                    child: _SearchField(),
                  ),

                // ====== CONTENEDOR DE TABLA (máx 960 x 560) ======
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, innerConstraints) {
                      // tamaño máximo del recuadro
                      const double maxTableWidth = 960;
                      const double maxTableHeight = 560;

                      // ancho visible (no puede ser mayor al espacio disponible)
                      final double visibleWidth = innerConstraints.maxWidth <
                              maxTableWidth
                          ? innerConstraints.maxWidth
                          : maxTableWidth;

                      // alto visible (no puede ser mayor al espacio disponible)
                      final double visibleHeight = innerConstraints.maxHeight <
                              maxTableHeight
                          ? innerConstraints.maxHeight
                          : maxTableHeight;

                      // en móvil: usamos todo el ancho, en desktop: centramos a 960
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
                                  // scroll vertical cuando hay muchas filas
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    // scroll horizontal cuando el contenido
                                    // mínimo es más ancho que la pantalla (móvil)
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        // el contenido de la tabla siempre
                                        // piensa que “mide” 960 de ancho,
                                        // así respetamos el diseño y en móvil
                                        // hay scroll horizontal.
                                        minWidth: maxTableWidth,
                                      ),
                                      child: DataTableTheme(
                                        data: DataTableThemeData(
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                            kPrimaryBlue,
                                          ),
                                          headingTextStyle:
                                              GoogleFonts.archivo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            letterSpacing: 0.8,
                                            color: kWhite,
                                          ),
                                          dataTextStyle:
                                              GoogleFonts.archivoNarrow(
                                            fontSize: 14,
                                            color: kBlack,
                                          ),
                                          headingRowHeight: 40,
                                          dataRowHeight: 44,
                                        ),
                                        child: DataTable(
                                          columnSpacing: 32,
                                          columns: const [
                                            DataColumn(
                                                label: Text('Medicamento')),
                                            DataColumn(label: Text('Tipo')),
                                            DataColumn(label: Text('Dosis')),
                                            DataColumn(label: Text('Stock')),
                                            DataColumn(label: Text('Precio')),
                                          ],
                                          rows: medicines
                                              .map(
                                                (m) => DataRow(
                                                  cells: [
                                                    DataCell(Text(m.nombre)),
                                                    DataCell(Text(m.tipo)),
                                                    DataCell(Text(m.dosis)),
                                                    DataCell(_StockChip(
                                                        unidades: m.stock)),
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
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 20),
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

  Medicine(this.nombre, this.tipo, this.dosis, this.stock, this.precio);
}

// Datos de ejemplo
final List<Medicine> _dummyMedicines = [
  Medicine('Paracetamol', 'Analgésico', '500mg', 150, 25.50),
  Medicine('Ibuprofeno', 'Antiinflamatorio', '400mg', 80, 32.00),
  Medicine('Amoxicilina', 'Antibiótico', '250mg', 45, 89.50),
  Medicine('Omeprazol', 'Protector gástrico', '20mg', 120, 45.00),
  Medicine('Losartán', 'Antihipertensivo', '50mg', 95, 58.00),
  Medicine('Metformina', 'Antidiabético', '850mg', 35, 42.50),
  Medicine('Atorvastatina', 'Hipolipemiante', '20mg', 110, 95.00),
  Medicine('Aspirina', 'Antiagregante', '100mg', 200, 18.00),
];
