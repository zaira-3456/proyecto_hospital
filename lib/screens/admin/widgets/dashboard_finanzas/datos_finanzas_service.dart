import '../../../login/services/database_service.dart';

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
    final db = DatabaseService();
    
    // Fetch data in parallel
    final results = await Future.wait([
      db.getMonthlyFinancials(),
      db.getFinancialHistory(),
    ]);

    final monthly = results[0] as Map<String, dynamic>;
    final history = results[1] as List<Map<String, dynamic>>;

    // Parse monthly data
    final ingresosMes = (monthly['ingresosMes'] ?? 0).toDouble();
    final egresosMes = (monthly['egresosMes'] ?? 0).toDouble();
    final balance = (monthly['balance'] ?? 0).toDouble();
    final cuentasPorCobrar = (monthly['cuentasPorCobrar'] ?? 0).toDouble();
    
    // Parse pie chart data
    final salarios = (monthly['salarios'] ?? 0).toDouble();
    final equipamiento = (monthly['equipamiento'] ?? 0).toDouble();
    final medicamentos = (monthly['medicamentos'] ?? 0).toDouble();
    final servicios = (monthly['servicios'] ?? 0).toDouble();

    // Parse history
    List<double> histIngresos = [];
    List<double> histEgresos = [];
    
    if (history.isNotEmpty) {
        histIngresos = history.map<double>((e) => (e['ingresosMes'] ?? 0).toDouble()).toList();
        histEgresos = history.map<double>((e) => (e['egresosMes'] ?? 0).toDouble()).toList();
    } else {
        // Fallback if empty
        histIngresos = [0, 0, 0, 0, 0, 0];
        histEgresos = [0, 0, 0, 0, 0, 0];
    }

    return DatosFinancieros(
      ingresosMes: ingresosMes,
      egresosMes: egresosMes,
      varIngresos: 0.0, // Placeholder
      varEgresos: 0.0, // Placeholder
      balance: balance,
      cuentasPorCobrar: cuentasPorCobrar,
      salarios: salarios,
      equipamiento: equipamiento,
      medicamentos: medicamentos,
      servicios: servicios,
      historialIngresos: histIngresos,
      historialEgresos: histEgresos,
    );
  }
}

