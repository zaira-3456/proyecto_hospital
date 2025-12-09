import 'package:flutter/material.dart';
import '../widgets/dashboard_finanzas/finance_stat_card.dart';
import '../widgets/dashboard_finanzas/chart_line_finanzas.dart';
import '../widgets/dashboard_finanzas/chart_pie_finanzas.dart';
import '../widgets/dashboard_finanzas/datos_finanzas_service.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  late Future<DatosFinancieros> futureDatos;

  @override
  void initState() {
    super.initState();
    futureDatos = DatosFinanzasService.obtenerDatos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatosFinancieros>(
      future: futureDatos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final datos = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;

            final bool isDesktop = w >= 1100;
            final bool isTablet = w >= 700 && w < 1100;
            final bool isMobile = w < 700;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gestión de Financiera",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 35),

                  // =====================================================
                  //  DESKTOP — FIGMA: TARJETAS IZQUIERDA, GRAFICAS DERECHA
                  // =====================================================
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              FinanceStatCard(
                                titulo: "Ingresos del Mes",
                                valor: datos.ingresosMes.toDouble(),
                                variacion: datos.varIngresos.toDouble(),
                                color: Colors.green,
                              ),
                              const SizedBox(height: 25),
                              FinanceStatCard(
                                titulo: "Egresos del Mes",
                                valor: datos.egresosMes.toDouble(),
                                variacion: datos.varEgresos.toDouble(),
                                color: Colors.red,
                              ),
                              const SizedBox(height: 25),
                              FinanceStatCard(
                                titulo: "Balance",
                                valor: datos.balance.toDouble(),
                                variacion: 0,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 25),
                              FinanceStatCard(
                                titulo: "Cuentas por Cobrar",
                                valor: datos.cuentasPorCobrar.toDouble(),
                                variacion: 0,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              ChartLineFinanzas(datos: datos),
                              const SizedBox(height: 40),

                              /// ⭐ CORRECCIÓN AQUÍ ⭐
                              ChartPieFinanzas(
                                salarios: datos.salarios,
                                equipamiento: datos.equipamiento,
                                medicamentos: datos.medicamentos,
                                servicios: datos.servicios,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  // =====================================================
                  //  TABLET
                  // =====================================================
                  if (isTablet)
                    Column(
                      children: [
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            SizedBox(
                              width: (w / 2) - 60,
                              child: FinanceStatCard(
                                titulo: "Ingresos del Mes",
                                valor: datos.ingresosMes.toDouble(),
                                variacion: datos.varIngresos.toDouble(),
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(
                              width: (w / 2) - 60,
                              child: FinanceStatCard(
                                titulo: "Egresos del Mes",
                                valor: datos.egresosMes.toDouble(),
                                variacion: datos.varEgresos.toDouble(),
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(
                              width: (w / 2) - 60,
                              child: FinanceStatCard(
                                titulo: "Balance",
                                valor: datos.balance.toDouble(),
                                variacion: 0,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(
                              width: (w / 2) - 60,
                              child: FinanceStatCard(
                                titulo: "Cuentas por Cobrar",
                                valor: datos.cuentasPorCobrar.toDouble(),
                                variacion: 0,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                        ChartLineFinanzas(datos: datos),
                        const SizedBox(height: 40),

                        /// ⭐ CORRECCIÓN AQUÍ ⭐
                        ChartPieFinanzas(
                          salarios: datos.salarios,
                          equipamiento: datos.equipamiento,
                          medicamentos: datos.medicamentos,
                          servicios: datos.servicios,
                        ),
                      ],
                    ),

                  // =====================================================
                  //  MÓVIL
                  // =====================================================
                  if (isMobile)
                    Column(
                      children: [
                        FinanceStatCard(
                          titulo: "Ingresos del Mes",
                          valor: datos.ingresosMes.toDouble(),
                          variacion: datos.varIngresos.toDouble(),
                          color: Colors.green,
                        ),
                        const SizedBox(height: 20),
                        FinanceStatCard(
                          titulo: "Egresos del Mes",
                          valor: datos.egresosMes.toDouble(),
                          variacion: datos.varEgresos.toDouble(),
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        FinanceStatCard(
                          titulo: "Balance",
                          valor: datos.balance.toDouble(),
                          variacion: 0,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        FinanceStatCard(
                          titulo: "Cuentas por Cobrar",
                          valor: datos.cuentasPorCobrar.toDouble(),
                          variacion: 0,
                          color: Colors.orange,
                        ),

                        const SizedBox(height: 40),
                        ChartLineFinanzas(datos: datos),
                        const SizedBox(height: 40),

                        /// ⭐ CORRECCIÓN AQUÍ ⭐
                        ChartPieFinanzas(
                          salarios: datos.salarios,
                          equipamiento: datos.equipamiento,
                          medicamentos: datos.medicamentos,
                          servicios: datos.servicios,
                        ),
                      ],
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
