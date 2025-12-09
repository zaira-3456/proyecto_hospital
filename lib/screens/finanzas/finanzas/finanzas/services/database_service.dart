import 'dart:async';

/// Servicio para manejar operaciones de base de datos
/// NOTA: Esta es una implementación simulada. Reemplaza estos métodos
/// con llamadas reales a tu API/backend.
class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Simula el envío de un código de verificación al email
  /// 
  /// En producción, esto debería:
  /// 1. Generar un código aleatorio
  /// 2. Guardarlo en la base de datos con timestamp
  /// 3. Enviar el código por email al usuario
  /// 
  /// Ejemplo de integración:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('https://tu-api.com/send-verification-code'),
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: json.encode({'email': email}),
  /// );
  /// if (response.statusCode != 200) throw Exception('Error al enviar código');
  /// ```
  Future<bool> sendVerificationCode(String email) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Reemplazar con llamada real a la API
    print('📧 Código de verificación enviado a: $email');
    print('🔐 Código simulado: 123456');
    
    return true;
  }

  /// Verifica si el código ingresado es válido
  /// 
  /// En producción, esto debería:
  /// 1. Verificar que el código existe en la base de datos
  /// 2. Verificar que no ha expirado (ej: válido por 10 minutos)
  /// 3. Verificar que corresponde al email correcto
  /// 
  /// Ejemplo de integración:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('https://tu-api.com/verify-code'),
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: json.encode({'email': email, 'code': code}),
  /// );
  /// return response.statusCode == 200;
  /// ```
  Future<bool> verifyCode(String email, String code) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Reemplazar con llamada real a la API
    // Por ahora, acepta cualquier código de 6 dígitos
    final isValid = code.length == 6 && int.tryParse(code) != null;
    
    print('✅ Verificando código: $code para $email');
    print('📊 Resultado: ${isValid ? "Válido" : "Inválido"}');
    
    return isValid;
  }

  /// Actualiza la contraseña del usuario en la base de datos
  /// 
  /// En producción, esto debería:
  /// 1. Hashear la contraseña (NUNCA guardar en texto plano)
  /// 2. Actualizar la contraseña en la base de datos
  /// 3. Invalidar el código de verificación usado
  /// 4. Opcionalmente, enviar email de confirmación
  /// 
  /// Ejemplo de integración:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('https://tu-api.com/reset-password'),
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: json.encode({
  ///     'email': email,
  ///     'newPassword': newPassword,
  ///     'verificationCode': code,
  ///   }),
  /// );
  /// return response.statusCode == 200;
  /// ```
  Future<bool> resetPassword(String email, String newPassword) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Reemplazar con llamada real a la API
    // IMPORTANTE: En producción, hashear la contraseña antes de enviarla
    print('🔒 Actualizando contraseña para: $email');
    print('✅ Contraseña actualizada exitosamente');
    
    return true;
  }

  /// Verifica si un email existe en la base de datos
  /// 
  /// En producción, esto debería verificar si el email está registrado
  Future<bool> emailExists(String email) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Reemplazar con llamada real a la API
    // Por ahora, acepta cualquier email válido
    return email.contains('@');
  }

  /// Autentica un usuario y retorna su información
  /// 
  /// En producción, esto debería:
  /// 1. Verificar credenciales en la base de datos
  /// 2. Retornar información del usuario incluyendo su rol
  /// 3. Generar token de sesión
  Future<Map<String, dynamic>?> authenticateUser(
    String username,
    String password,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Reemplazar con llamada real a la API
    // Simulación: usuario "finanzas" con contraseña "123456" tiene rol finance
    if (username == 'finanzas' && password == '123456') {
      print('✅ Usuario autenticado: $username');
      return {
        'username': username,
        'name': 'Dr. Carlos Pérez',
        'role': 'finance',
      };
    }
    
    print('❌ Credenciales inválidas');
    return null;
  }

  /// Obtiene las métricas financieras del día
  Future<Map<String, dynamic>> getFinancialMetrics() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return {
      'dailyIncome': 3250.0,
      'dailyExpenses': 1500.0,
      'cashFlow': 1700.0,
      'incomePercentageChange': 6.7,
      'expensesPercentageChange': -1.2,
      'cashFlowPercentageChange': 6.5,
    };
  }

  /// Obtiene los ingresos por área
  Future<List<Map<String, dynamic>>> getIncomeByArea() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return [
      {'areaName': 'Farmacia', 'amount': 800.0},
      {'areaName': 'Laboratorio', 'amount': 600.0},
      {'areaName': 'Consultas', 'amount': 1400.0},
      {'areaName': 'Emergencia', 'amount': 650.0},
    ];
  }

  /// Obtiene los gastos por área
  Future<List<Map<String, dynamic>>> getExpensesByArea() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return [
      {'areaName': 'Farmacia', 'amount': 450.0},
      {'areaName': 'Laboratorio', 'amount': 200.0},
      {'areaName': 'Consultas', 'amount': 350.0},
      {'areaName': 'Emergencia', 'amount': 500.0},
    ];
  }

  /// Obtiene las tareas urgentes
  Future<List<Map<String, dynamic>>> getUrgentTasks() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return [
      {
        'description': 'Presupuesto por autorizar',
        'priority': 1,
      },
      {
        'description': 'Facturas pendiente de pagar',
        'priority': 1,
      },
      {
        'description': 'Pagos atrasados',
        'priority': 1,
      },
    ];
  }

  /// Obtiene los registros de ingresos
  Future<List<Map<String, dynamic>>> getIncomeRecords() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 700));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return [
      {
        'date': '10/04/2025',
        'client': 'María Gomez',
        'amount': 1250.0,
        'paymentMethod': 'Efectivo',
        'area': 'Hospital',
      },
      {
        'date': '15/04/2025',
        'client': 'Carlos López',
        'amount': 500.0,
        'paymentMethod': 'Transferencia',
        'area': 'Consulta',
      },
      {
        'date': '16/04/2025',
        'client': 'Ana Rivera',
        'amount': 800.0,
        'paymentMethod': 'Tarjeta',
        'area': 'Emergencia',
      },
      {
        'date': '02/05/2025',
        'client': 'Luis Fernández',
        'amount': 1000.0,
        'paymentMethod': 'Efectivo',
        'area': 'Laboratorio',
      },
      {
        'date': '08/05/2025',
        'client': 'Isaías Barrera',
        'amount': 900.0,
        'paymentMethod': 'Tarjeta',
        'area': 'Consulta',
      },
    ];
  }

  /// Obtiene la métrica de ingresos del día
  Future<Map<String, dynamic>> getDailyIncomeMetric() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return {
      'amount': 4450.0,
      'percentageChange': 5.7,
    };
  }

  /// Obtiene datos de ingresos para gráficos
  Future<List<Map<String, dynamic>>> getIncomeChartData() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: Reemplazar con datos reales de la base de datos
    return [
      {'category': 'Farmacia', 'amount': 900.0},
      {'category': 'Hospital', 'amount': 650.0},
      {'category': 'Emergencia', 'amount': 450.0},
      {'category': 'Laboratorio', 'amount': 250.0},
      {'category': 'Consulta', 'amount': 150.0},
    ];
  }

  /// Obtiene los registros de gastos
  Future<List<Map<String, dynamic>>> getExpenseRecords() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      {
        'date': '10/04/2025',
        'amount': 1250.0,
        'area': 'Hospital',
        'type': 'Nomina',
        'status': 'Aprobado',
        'hasInvoice': true,
      },
      {
        'date': '15/04/2025',
        'amount': 500.0,
        'area': 'Consulta',
        'type': 'Insumos',
        'status': 'Rechazado',
        'hasInvoice': true,
      },
      {
        'date': '16/04/2025',
        'amount': 800.0,
        'area': 'Emergencia',
        'type': 'Mantenimiento',
        'status': 'Aprobado',
        'hasInvoice': true,
      },
      {
        'date': '02/05/2025',
        'amount': 1000.0,
        'area': 'Laboratorio',
        'type': 'Servicios',
        'status': 'Aprobado',
        'hasInvoice': true,
      },
      {
        'date': '08/05/2025',
        'amount': 900.0,
        'area': 'Consulta',
        'type': 'Equipos',
        'status': 'Aprobado',
        'hasInvoice': true,
      },
    ];
  }

  /// Obtiene las solicitudes de gastos
  Future<List<Map<String, dynamic>>> getExpenseRequests() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {
        'date': '10/04/2025',
        'amount': 1500.0,
        'area': 'Farmacia',
        'type': 'Medicamentos',
        'detailsUrl': 'link',
        'description': 'Se agotaron los medicamentos básicos en la farmacia',
        'changeHistory': [
          {'date': '10/04/2025', 'time': '10:30 am', 'user': 'Ruiz'},
          {'date': '15/04/2025', 'time': '12:06 pm', 'user': 'Gonzalez'},
          {'date': '16/04/2025', 'time': '16:12 pm', 'user': 'Romero'},
          {'date': '02/05/2025', 'time': '8:45 am', 'user': 'Garcia'},
          {'date': '08/05/2025', 'time': '9:02 am', 'user': 'Ruiz'},
        ],
      },
      {
        'date': '15/04/2025',
        'amount': 500.0,
        'area': 'Consulta',
        'type': 'Insumos',
        'detailsUrl': 'link',
        'description': 'Compra de material médico para consultas',
        'changeHistory': [
          {'date': '15/04/2025', 'time': '09:15 am', 'user': 'Martinez'},
          {'date': '16/04/2025', 'time': '14:30 pm', 'user': 'Lopez'},
        ],
      },
      {
        'date': '16/04/2025',
        'amount': 800.0,
        'area': 'Emergencia',
        'type': 'Mantenimiento',
        'detailsUrl': 'link',
        'description': 'Reparación de equipo de emergencia',
        'changeHistory': [
          {'date': '16/04/2025', 'time': '11:00 am', 'user': 'Sanchez'},
        ],
      },
      {
        'date': '02/05/2025',
        'amount': 1000.0,
        'area': 'Laboratorio',
        'type': 'Servicios',
        'detailsUrl': 'link',
        'description': 'Contrato de mantenimiento de equipos de laboratorio',
        'changeHistory': [
          {'date': '02/05/2025', 'time': '08:00 am', 'user': 'Fernandez'},
          {'date': '03/05/2025', 'time': '10:20 am', 'user': 'Torres'},
        ],
      },
      {
        'date': '08/05/2025',
        'amount': 900.0,
        'area': 'Consulta',
        'type': 'Equipos',
        'detailsUrl': 'link',
        'description': 'Adquisición de nuevo equipo de diagnóstico',
        'changeHistory': [],
      },
    ];
  }
}

