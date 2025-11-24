import 'package:flutter/material.dart';

/// =============================================================
///   MODELO — Datos preparados para futura conexión a BD
/// =============================================================
class InfraestructuraDatos {
  final int totalCamas;
  final int disponibles;
  final int enUso;
  final double ocupacion;

  final List<AreaEstado> areas; // Tabla completa

  InfraestructuraDatos({
    required this.totalCamas,
    required this.disponibles,
    required this.enUso,
    required this.ocupacion,
    required this.areas,
  });
}

class AreaEstado {
  final String area;
  final int total;
  final int disponibles;
  final String estado; // Operativa, Critica, etc.

  AreaEstado({
    required this.area,
    required this.total,
    required this.disponibles,
    required this.estado,
  });
}

/// =============================================================
///   SERVICIO — Futuro consumo desde API / Firebase / MySQL
/// =============================================================
class InfraestructuraService {
  static Future<InfraestructuraDatos> obtenerDatos() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return InfraestructuraDatos(
      totalCamas: 70,
      disponibles: 17,
      enUso: 53,
      ocupacion: 76,
      areas: [
        AreaEstado(area: "Sala de Emergencias", total: 10, disponibles: 3, estado: "Operativa"),
        AreaEstado(area: "Hospitalización", total: 50, disponibles: 12, estado: "Operativa"),
        AreaEstado(area: "UCI", total: 8, disponibles: 1, estado: "Crítica"),
        AreaEstado(area: "Quirófano 1", total: 1, disponibles: 1, estado: "Mantenimiento"),
        AreaEstado(area: "Quirófano 2", total: 1, disponibles: 0, estado: "En Uso"),
      ],
    );
  }
}

/// =============================================================
///   PANTALLA PRINCIPAL
/// =============================================================
class InfraestructuraScreen extends StatefulWidget {
  const InfraestructuraScreen({super.key});

  @override
  State<InfraestructuraScreen> createState() => _InfraestructuraScreenState();
}

class _InfraestructuraScreenState extends State<InfraestructuraScreen> {
  late Future<InfraestructuraDatos> futureDatos;

  @override
  void initState() {
    super.initState();
    futureDatos = InfraestructuraService.obtenerDatos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureDatos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final datos = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isMobile = width < 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TÍTULO
                  const Text(
                    "Infraestructura y Recursos",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 35),

                  /// =============================================================
                  ///   TARJETAS SUPERIORES (RESPONSIVAS)
                  /// =============================================================
                  isMobile
                      ? Column(
                          children: [
                            infraCard("Total Camas", Icons.bed, datos.totalCamas.toString()),
                            const SizedBox(height: 18),
                            infraCard("Disponibles", Icons.verified, datos.disponibles.toString()),
                            const SizedBox(height: 18),
                            infraCard("En Uso", Icons.pan_tool, datos.enUso.toString()),
                            const SizedBox(height: 18),
                            infraCard("Ocupación", Icons.donut_large, "${datos.ocupacion}%"),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: infraCard("Total Camas", Icons.bed, datos.totalCamas.toString())),
                            const SizedBox(width: 25),
                            Expanded(child: infraCard("Disponibles", Icons.verified, datos.disponibles.toString())),
                            const SizedBox(width: 25),
                            Expanded(child: infraCard("En Uso", Icons.pan_tool, datos.enUso.toString())),
                            const SizedBox(width: 25),
                            Expanded(child: infraCard("Ocupación", Icons.donut_large, "${datos.ocupacion}%")),
                          ],
                        ),

                  const SizedBox(height: 55),

                  /// =============================================================
                  ///    TABLA — IGUAL A FIGMA
                  /// =============================================================
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Estado de Áreas",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// TABLA COMPLETA
                        Table(
                          border: TableBorder.all(color: Colors.black.withOpacity(0.1)),
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            /// ENCABEZADO
                           TableRow(
                            decoration: BoxDecoration(color: Colors.blue.shade100),
                            children: [
                              tablaHeader("Área"),
                              tablaHeader("Total Camas"),
                              tablaHeader("Disponibles"),
                              tablaHeader("Estado"),
                            ],
                          ),

                            /// FILAS DINÁMICAS
                            ...datos.areas.map((a) {
                              return TableRow(
                                children: [
                                  tablaCell(a.area),
                                  tablaCell(a.total.toString()),
                                  tablaCell(a.disponibles.toString()),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: estadoChip(a.estado),
                                  ),
                                ],
                              );
                            }).toList()
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// =============================================================
///   WIDGETS DE TARJETAS
/// =============================================================
Widget infraCard(String title, IconData icon, String value) {
  // 🎨 COLORES EXACTOS
  final Map<String, Color> iconColors = {
    "Total Camas": const Color(0xff4B5CD7),       // Azul púrpura
    "Disponibles": const Color(0xff234C2B),       // Verde oscuro
    "En Uso": const Color(0xffC01717),            // Rojo
    "Ocupación": const Color(0xffEC8C3C),         // Naranja
  };

  final Color iconColor = iconColors[title] ?? Colors.blue;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
    decoration: BoxDecoration(
      color: const Color(0xffe5f3ff), // fondo azul clarito igual al dashboard
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.black.withOpacity(0.05),
      ),
    ),

    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// TEXTOS (IZQUIERDA)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff32465a),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d1b2a),
                ),
              ),
            ],
          ),
        ),

        /// ÍCONO CIRCULAR (PEGADO A LA DERECHA)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 28,
            color: iconColor,
          ),
        ),
      ],
    ),
  );
}

/// =============================================================
///   WIDGETS DE TABLA
/// =============================================================
Widget tablaHeader(String text) => Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );

Widget tablaCell(String text) => Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );

Widget estadoChip(String estado) {
  Color color;

  switch (estado) {
    case "Operativa":
      color = Colors.green.shade400;
      break;
    case "Crítica":
      color = Colors.red.shade400;
      break;
    case "Mantenimiento":
      color = Colors.orange.shade400;
      break;
    case "En Uso":
      color = Colors.blue.shade400;
      break;
    default:
      color = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color, width: 1.5),
    ),
    child: Text(
      estado,
      style: TextStyle(
       color: color.withOpacity(0.9),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
