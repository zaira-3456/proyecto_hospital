import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/diseno_farmacia.dart';
import 'widgets/agregar_medicamento.dart';
import 'inventario.dart';
import 'solicitudes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PharmacyLayout(
      selectedIndex: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool narrow = constraints.maxWidth < 1050;

          // ── CONTENIDO PRINCIPAL ──
          Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel Farmacéutico',
                        style: GoogleFonts.archivo(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: kBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenido, Wendy',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 22,
                          letterSpacing: 1,
                          color: kBlack,
                        ),
                      ),
                    ],
                  ),
                  const HospitalLogoCircle(),
                ],
              ),
              const SizedBox(height: 30),

              // Tarjetas superiores
              if (narrow)
                Column(
                  children: const [
                    _CardInventarioTotal(),
                    SizedBox(height: 18),
                    _CardStockBajo(),
                    SizedBox(height: 18),
                    _CardSolicitudes(),
                  ],
                )
              else
                Row(
                  children: const [
                    Expanded(child: _CardInventarioTotal()),
                    SizedBox(width: 18),
                    Expanded(child: _CardStockBajo()),
                    SizedBox(width: 18),
                    Expanded(child: _CardSolicitudes()),
                  ],
                ),

              const SizedBox(height: 26),

              // Tarjetas inferiores (botones grandes)
              if (narrow)
                Column(
                  children: [
                    _BigButton(
                      icon: Icons.list_alt,
                      text: 'Ver Inventario',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InventoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _BigButton(
                      icon: Icons.local_hospital,
                      text: 'Solicitudes de Enfermería',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const _BigButton(
                      icon: Icons.show_chart,
                      text: 'Reportes y Estadísticas',
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _BigButton(
                        icon: Icons.list_alt,
                        text: 'Ver Inventario',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InventoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _BigButton(
                        icon: Icons.local_hospital,
                        text: 'Solicitudes de Enfermería',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RequestsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: _BigButton(
                        icon: Icons.show_chart,
                        text: 'Reportes y Estadísticas',
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Botón Agregar Medicamento
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0EDF7),
                      foregroundColor: kBlack,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      textStyle: GoogleFonts.archivoNarrow(
                        fontSize: 16,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
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
              ),
            ],
          );

          // ── SCROLL VERTICAL PARA MÓVILES ──
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

/// ----- Tarjeta Inventario Total -----

class _CardInventarioTotal extends StatelessWidget {
  const _CardInventarioTotal();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBlue15,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Inventario Total',
            style: GoogleFonts.archivo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '8',
            style: GoogleFonts.archivo(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Medicamentos diferentes',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              letterSpacing: 1,
              color: kDarkGray,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 2, color: kDarkGray),
          const SizedBox(height: 10),
          Text(
            '\$36,860',
            style: GoogleFonts.archivoNarrow(
              fontSize: 18,
              color: kGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Valor total del inventario',
            style: GoogleFonts.archivoNarrow(
              fontSize: 12,
              color: kDarkGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// ----- Tarjeta Stock Bajo -----

class _CardStockBajo extends StatelessWidget {
  const _CardStockBajo();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBlue15,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: kPureRed, size: 20),
              const SizedBox(width: 6),
              Text(
                'Stock Bajo',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: kBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LowStockPill(
            title: 'Amoxicilina 250mg',
            subtitle: 'Stock actual: 45 | Mínimo: 60',
          ),
          const SizedBox(height: 10),
          _LowStockPill(
            title: 'Metformina 850mg',
            subtitle: 'Stock actual: 35 | Mínimo: 50',
          ),
        ],
      ),
    );
  }
}

class _LowStockPill extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LowStockPill({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kDarkRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.archivoNarrow(
              fontSize: 14,
              color: kDarkRed,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.archivoNarrow(
              fontSize: 11,
              color: kDarkGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// ----- Tarjeta Solicitudes Pendientes -----

class _CardSolicitudes extends StatelessWidget {
  const _CardSolicitudes();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBlue15,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Solicitudes\npendientes',
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: kBlack,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '3',
            style: GoogleFonts.archivo(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: kOrange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Por aprobar',
            style: GoogleFonts.archivoNarrow(
              fontSize: 13,
              color: kDarkGray,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: kWhite,
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                textStyle: GoogleFonts.archivoNarrow(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestsScreen(),
                  ),
                );
              },
              child: const Text('Ver todos'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ----- Botones grandes inferiores -----

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _BigButton({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: kCardBlue15,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: kBlack),
                const SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
