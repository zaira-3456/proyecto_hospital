class DatosFinancieros {
  final double ingresosMes;
  final double egresosMes;
  final double varIngresos;
  final double varEgresos;
  final double balance;
  final double cuentasPorCobrar;

  // 👉 NUEVOS CAMPOS (para la gráfica de pastel)
  final double salarios;
  final double equipamiento;
  final double medicamentos;
  final double servicios;

  // 👉 Historial para la gráfica lineal
  final List<double> historialIngresos;
  final List<double> historialEgresos;

  DatosFinancieros({
    required this.ingresosMes,
    required this.egresosMes,
    required this.varIngresos,
    required this.varEgresos,
    required this.balance,
    required this.cuentasPorCobrar,

    required this.salarios,
    required this.equipamiento,
    required this.medicamentos,
    required this.servicios,

    required this.historialIngresos,
    required this.historialEgresos,
  });
}

class DatosFinanzasService {
  static Future<DatosFinancieros> obtenerDatos() async {
    await Future.delayed(const Duration(milliseconds: 400)); // Simula BD

    return DatosFinancieros(
      ingresosMes: 150000,
      egresosMes: 90000,
      varIngresos: 7.5,
      varEgresos: 2.1,
      balance: 60000,
      cuentasPorCobrar: 35000,

      // 👉 VALORES DEL PASTEL (como tu diseño de Figma)
      salarios: 50,
      equipamiento: 20,
      medicamentos: 15,
      servicios: 15,

      // 👉 GRÁFICA LINEAL
      historialIngresos: [200000, 220000, 235000, 240000, 225000, 240000],
      historialEgresos: [120000, 135000, 145000, 150000, 140000, 150000],
    );
  }
}
