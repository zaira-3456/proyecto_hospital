import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio central para Firestore
class DatabaseService {
  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // LOGIN: leer usuario desde colección "usuarios"
  // username + password (simple para este proyecto)
  // ============================================================
  Future<Map<String, String>?> authenticateUser(
    String username,
    String password,
  ) async {
    try {
      final snapshot = await _db
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('❌ Usuario no encontrado en Firestore');
        return null;
      }

      final data = snapshot.docs.first.data();
      print('✅ Usuario autenticado: ${data['username']}');

      return {
        'username': data['username'] as String,
        'name': (data['nombre'] ?? '') as String,
        'role': (data['rol'] ?? '') as String,
      };
    } catch (e) {
      print('❌ Error en authenticateUser: $e');
      return null;
    }
  }

  // ============================================================
  // CREAR USUARIO
  // ============================================================
  Future<bool> createUser({
    required String username,
    required String password,
    required String nombre,
    required String rol,
    String? telefono,
    String? departamento,
  }) async {
    try {
      // Verificar si ya existe
      final query = await _db
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty) {
        print('❌ El usuario $username ya existe.');
        return false;
      }

      await _db.collection('usuarios').add({
        'username': username,
        'password': password, // En producción, usar hash
        'nombre': nombre,
        'rol': rol,
        'telefono': telefono ?? '',
        'departamento': departamento ?? '',
        'activo': true,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      print('✅ Usuario creado: $username');
      return true;
    } catch (e) {
      print('❌ Error creando usuario: $e');
      return false;
    }
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA (simulado – aún no usa Firestore)
  // ============================================================
  Future<bool> sendVerificationCode(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    print('📧 Código de verificación enviado a: $email');
    print('🔐 Código simulado: 123456');
    return true;
  }

  Future<bool> verifyCode(String email, String code) async {
    await Future.delayed(const Duration(seconds: 1));
    final isValid = code.length == 6 && int.tryParse(code) != null;
    print('✅ Verificando código: $code para $email -> $isValid');
    return isValid;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(seconds: 2));
    print('🔒 Actualizando contraseña para: $email (simulado)');
    return true;
  }

  // ============================================================
  // ESTADÍSTICAS MÉDICO
  // ============================================================
  Future<Map<String, dynamic>> getDoctorStats() async {
    try {
      final patients = await getPatientCount();
      final appointments = await getAppointmentsToday();
      
      // TODO: Implementar conteo real de estudios y recetas cuando existan las colecciones
      final studies = 3; // Mock
      final prescriptions = 77; // Mock

      return {
        'patients': patients,
        'appointments': appointments,
        'studies': studies,
        'prescriptions': prescriptions,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas de médico: $e');
      return {
        'patients': 0,
        'appointments': 0,
        'studies': 0,
        'prescriptions': 0,
      };
    }
  }

  // ============================================================
  // FINANZAS: leer métricas desde Firestore
  // Colecciones: metricas_financieras, historial_financiero, tareas_urgentes
  // ============================================================

  /// Métricas del día actual (usa doc con id = yyyy-MM-dd)
  Future<Map<String, dynamic>> getFinancialMetrics() async {
    final today = DateTime.now();
    final id =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc =
        await _db.collection('metricas_financieras').doc(id).get();

    if (!doc.exists) {
      // Valores por defecto si no hay dato del día
      return {
        'dailyIncome': 0.0,
        'dailyExpenses': 0.0,
        'cashFlow': 0.0,
        'incomePercentageChange': 0.0,
        'expensesPercentageChange': 0.0,
        'cashFlowPercentageChange': 0.0,
      };
    }

    return doc.data()!;
  }

  /// Distribución de ingresos por área (para gráfica de barras / pastel)
  Future<List<Map<String, dynamic>>> getIncomeByArea() async {
    final snapshot =
        await _db.collection('historial_financiero').get();

    // Aquí arma una lista tipo:
    // [{areaName: 'Farmacia', amount: 800}, ...]
    final List<Map<String, double>> acumulado = [];

    // Para no complicar, vamos a mapear 4 campos fijos:
    // salarios, equipamiento, medicamentos, servicios
    final List<Map<String, dynamic>> result = [];

    for (final doc in snapshot.docs) {
      final d = doc.data();
      result.add({'areaName': 'Farmacia', 'amount': (d['medicamentos'] ?? 0).toDouble()});
      result.add({'areaName': 'Equipamiento', 'amount': (d['equipamiento'] ?? 0).toDouble()});
      result.add({'areaName': 'Servicios', 'amount': (d['servicios'] ?? 0).toDouble()});
      result.add({'areaName': 'Salarios', 'amount': (d['salarios'] ?? 0).toDouble()});
      break; // con un mes basta para demo
    }

    if (result.isEmpty) {
      return [
        {'areaName': 'Farmacia', 'amount': 0.0},
        {'areaName': 'Equipamiento', 'amount': 0.0},
        {'areaName': 'Servicios', 'amount': 0.0},
        {'areaName': 'Salarios', 'amount': 0.0},
      ];
    }

    return result;
  }

  /// Gastos por área (puedes usar los mismos datos simplificados)
  Future<List<Map<String, dynamic>>> getExpensesByArea() async {
    // Para simplificar usamos los mismos datos que getIncomeByArea
    final income = await getIncomeByArea();
    return income
        .map((e) => {
              'areaName': e['areaName'],
              'amount': (e['amount'] as num).toDouble() * 0.6,
            })
        .toList();
  }

  /// Tareas urgentes de finanzas (colección tareas_urgentes where area == "finanzas")
  Future<List<Map<String, dynamic>>> getUrgentTasks() async {
    final snapshot = await _db
        .collection('tareas_urgentes')
        .where('area', isEqualTo: 'finanzas')
        .where('estado', isEqualTo: 'pendiente')
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    return snapshot.docs.map((doc) {
      final d = doc.data();
      return {
        'description': d['descripcion'] ?? '',
        'priority': d['prioridad'] ?? 1,
      };
    }).toList();
  }

  /// Obtener datos financieros del mes actual (o el último disponible)
  Future<Map<String, dynamic>> getMonthlyFinancials() async {
    try {
      // Intentar obtener el mes actual, ej: "2025-01"
      final now = DateTime.now();
      // Ajustar esto según cómo generes los IDs de mes
      // En seedDemoData usaste '2025-01'
      final id = '${now.year}-${now.month.toString().padLeft(2, '0')}'; 
      
      var doc = await _db.collection('historial_financiero').doc(id).get();

      if (!doc.exists) {
        // Si no existe el actual, buscar el último
        final snapshot = await _db
            .collection('historial_financiero')
            .orderBy('anio', descending: true)
            .orderBy('mes', descending: true)
            .limit(1)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          doc = snapshot.docs.first;
        } else {
          return {};
        }
      }

      return doc.data() ?? {};
    } catch (e) {
      print('❌ Error obteniendo finanzas mensuales: $e');
      return {};
    }
  }

  /// Obtener historial financiero (últimos 6 meses)
  Future<List<Map<String, dynamic>>> getFinancialHistory() async {
    try {
      final snapshot = await _db
          .collection('historial_financiero')
          .orderBy('anio', descending: false)
          .orderBy('mes', descending: false)
          .limitToLast(6)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error obteniendo historial financiero: $e');
      return [];
    }
  }

  // ============================================================
  // SEED DE DATOS PARA TODOS LOS DASHBOARDS
  // (se llama una sola vez desde main)
  // ============================================================
  Future<void> seedDemoData() async {
    // para no duplicar datos en cada arranque
    final metaRef = _db.collection('app_meta').doc('seed_info');
    final metaSnap = await metaRef.get();
    if (metaSnap.exists && (metaSnap.data()?['done'] == true)) {
      print('✅ Seed ya ejecutado anteriormente, no se vuelve a correr.');
      return;
    }

    final batch = _db.batch();

    // ---------- USUARIOS ----------
    final usuarios = _db.collection('usuarios');
    batch.set(usuarios.doc('admin'), {
      'username': 'admin',
      'password': '123456',
      'nombre': 'Administrador General',
      'rol': 'admin',
      'telefono': '555-000-0000',
      'departamento': 'Administracion',
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('medico'), {
      'username': 'medico',
      'password': '123456',
      'nombre': 'Dr. Martínez',
      'rol': 'medico',
      'telefono': '555-111-1111',
      'departamento': 'Consulta externa',
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('farmacia'), {
      'username': 'farmacia',
      'password': '123456',
      'nombre': 'Encargado de Farmacia',
      'rol': 'farmacia',
      'telefono': '555-222-2222',
      'departamento': 'Farmacia',
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('recepcion'), {
      'username': 'recepcion',
      'password': '123456',
      'nombre': 'Recepcionista',
      'rol': 'recepcion',
      'telefono': '555-333-3333',
      'departamento': 'Recepcion',
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('enfermeria'), {
      'username': 'enfermeria',
      'password': '123456',
      'nombre': 'Lic. Enfermería',
      'rol': 'enfermeria',
      'telefono': '555-444-4444',
      'departamento': 'Enfermería',
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('finance'), {
      'username': 'finance',
      'password': '123456',
      'nombre': 'Gestor Financiero',
      'rol': 'finance',
      'telefono': '555-555-5555',
      'departamento': 'Finanzas',
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- PACIENTES ----------
    final pacientes = _db.collection('pacientes');
    final pac1 = pacientes.doc();
    batch.set(pac1, {
      'nombreCompleto': 'María Gonzáles López',
      'fechaNacimiento': DateTime(1980, 5, 10),
      'genero': 'F',
      'telefono': '555-666-1111',
      'direccion': 'Calle 1, Col. Centro',
      'habitacion': '101',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    final pac2 = pacientes.doc();
    batch.set(pac2, {
      'nombreCompleto': 'Juan Carlos Ruiz',
      'fechaNacimiento': DateTime(1975, 8, 22),
      'genero': 'M',
      'telefono': '555-666-2222',
      'direccion': 'Calle 2, Col. Sur',
      'habitacion': '102',
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- CITAS ----------
    final citas = _db.collection('citas');
    batch.set(citas.doc(), {
      'pacienteId': pac1.id,
      'medicoId': 'medico',
      'fechaHora': DateTime.now().add(const Duration(hours: 1)),
      'motivo': 'Control de hipertensión',
      'estado': 'programada',
      'prioridad': 'normal',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(citas.doc(), {
      'pacienteId': pac2.id,
      'medicoId': 'medico',
      'fechaHora': DateTime.now().add(const Duration(hours: 2)),
      'motivo': 'Consulta general',
      'estado': 'programada',
      'prioridad': 'normal',
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- INVENTARIO FARMACIA ----------
    final inventario = _db.collection('medicamentos_inventario');
    batch.set(inventario.doc(), {
      'nombre': 'Paracetamol 500mg',
      'tipo': 'Analgésico',
      'dosis': '500mg',
      'presentacion': 'Tabletas',
      'stock': 120,
      'stockMinimo': 20,
      'precioUnitario': 15.0,
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(inventario.doc(), {
      'nombre': 'Ibuprofeno 400mg',
      'tipo': 'Analgésico',
      'dosis': '400mg',
      'presentacion': 'Tabletas',
      'stock': 80,
      'stockMinimo': 15,
      'precioUnitario': 20.0,
      'activo': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- PERSONAL ----------
    final personal = _db.collection('personal');
    batch.set(personal.doc(), {
      'nombre': 'Dr. Carlos Pérez',
      'puesto': 'Cardiólogo',
      'area': 'Urgencias',
      'tipo': 'medico',
      'turno': 'Matutino',
      'estado': 'Activo',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(personal.doc(), {
      'nombre': 'Lic. Ana López',
      'puesto': 'Enfermera',
      'area': 'Urgencias',
      'tipo': 'enfermeria',
      'turno': 'Nocturno',
      'estado': 'Activo',
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- AREAS HOSPITAL ----------
    final areas = _db.collection('areas_hospital');
    batch.set(areas.doc('emergencias'), {
      'nombre': 'Sala de Emergencias',
      'totalCamas': 10,
      'camasDisponibles': 3,
      'camasEnUso': 7,
      'estado': 'Operativa',
      'ocupacion': 70,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- FINANZAS ----------
    final hoy = DateTime.now();
    final idHoy =
        '${hoy.year.toString().padLeft(4, '0')}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    final metricas = _db.collection('metricas_financieras');
    batch.set(metricas.doc(idHoy), {
      'fecha': hoy,
      'dailyIncome': 3250.0,
      'dailyExpenses': 1500.0,
      'cashFlow': 1750.0,
      'incomePercentageChange': 6.7,
      'expensesPercentageChange': -1.2,
      'cashFlowPercentageChange': 6.5,
    });

    final historial = _db.collection('historial_financiero');
    batch.set(historial.doc('2025-01'), {
      'anio': 2025,
      'mes': 1,
      'ingresosMes': 120000.0,
      'egresosMes': 90000.0,
      'balance': 30000.0,
      'cuentasPorCobrar': 15000.0,
      'salarios': 40.0,
      'equipamiento': 25.0,
      'medicamentos': 20.0,
      'servicios': 15.0,
    });

    // ---------- TAREAS URGENTES ----------
    final tareas = _db.collection('tareas_urgentes');
    batch.set(tareas.doc(), {
      'descripcion': 'Presupuesto por autorizar',
      'prioridad': 1,
      'area': 'finanzas',
      'estado': 'pendiente',
      'creadaEn': FieldValue.serverTimestamp(),
    });
    batch.set(tareas.doc(), {
      'descripcion': 'Pagos atrasados',
      'prioridad': 1,
      'area': 'finanzas',
      'estado': 'pendiente',
      'creadaEn': FieldValue.serverTimestamp(),
    });

    // marca que ya se corrió el seed
    batch.set(metaRef, {
      'done': true,
      'at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    print('✅ Seed de datos de ejemplo completado.');
  }

  // ============================================================
  // ADMIN DASHBOARD: Métodos adicionales
  // ============================================================

  /// Contar total de pacientes
  Future<int> getPatientCount() async {
    try {
      final snapshot = await _db.collection('pacientes').get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error obteniendo conteo de pacientes: $e');
      return 0;
    }
  }

  /// Citas programadas para hoy
  Future<int> getAppointmentsToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _db
          .collection('citas')
          .where('fechaHora', isGreaterThanOrEqualTo: startOfDay)
          .where('fechaHora', isLessThanOrEqualTo: endOfDay)
          .where('estado', isEqualTo: 'programada')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error obteniendo citas de hoy: $e');
      return 0;
    }
  }

  /// Total de personal activo
  Future<int> getActivePersonnel() async {
    try {
      final snapshot = await _db
          .collection('personal')
          .where('estado', isEqualTo: 'Activo')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error obteniendo personal activo: $e');
      return 0;
    }
  }

  /// Personal por tipo (médico, enfermeria, administrativo)
  Future<Map<String, int>> getPersonnelByType() async {
    try {
      final snapshot = await _db.collection('personal').get();
      
      int medicos = 0;
      int enfermeros = 0;
      int administrativos = 0;

      for (final doc in snapshot.docs) {
        final tipo = (doc.data()['tipo'] ?? '').toString().toLowerCase();
        if (tipo == 'medico') {
          medicos++;
        } else if (tipo == 'enfermeria') {
          enfermeros++;
        } else {
          administrativos++;
        }
      }

      return {
        'medicos': medicos,
        'enfermeros': enfermeros,
        'administrativos': administrativos,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error obteniendo personal por tipo: $e');
      return {
        'medicos': 0,
        'enfermeros': 0,
        'administrativos': 0,
        'total': 0,
      };
    }
  }

  /// Obtener lista completa de personal
  Future<List<Map<String, dynamic>>> getPersonnelList() async {
    try {
      final snapshot = await _db.collection('personal').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'] ?? '',
          'puesto': data['puesto'] ?? '',
          'turno': data['turno'] ?? '',
          'estado': data['estado'] ?? '',
          'area': data['area'] ?? '',
          'tipo': data['tipo'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo lista de personal: $e');
      return [];
    }
  }

  /// Obtener áreas del hospital
  Future<List<Map<String, dynamic>>> getHospitalAreas() async {
    try {
      final snapshot = await _db.collection('areas_hospital').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'] ?? '',
          'totalCamas': data['totalCamas'] ?? 0,
          'camasDisponibles': data['camasDisponibles'] ?? 0,
          'camasEnUso': data['camasEnUso'] ?? 0,
          'estado': data['estado'] ?? '',
          'ocupacion': data['ocupacion'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo áreas del hospital: $e');
      return [];
    }
  }

  /// Agregar nuevo personal
  Future<bool> addPersonnel({
    required String nombre,
    required String puesto,
    required String area,
    required String tipo,
    required String turno,
    String estado = 'Activo',
  }) async {
    try {
      await _db.collection('personal').add({
        'nombre': nombre,
        'puesto': puesto,
        'area': area,
        'tipo': tipo,
        'turno': turno,
        'estado': estado,
        'creadoEn': FieldValue.serverTimestamp(),
      });
      print('✅ Personal agregado: $nombre');
      return true;
    } catch (e) {
      print('❌ Error agregando personal: $e');
      return false;
    }
  }

  /// Agregar nuevo paciente
  Future<bool> addPatient({
    required String nombreCompleto,
    required DateTime fechaNacimiento,
    required String genero,
    required String telefono,
    String? correo,
    String? direccion,
    String? nombreFamiliar,
    String? telefonoFamiliar,
    String? parentesco,
    String? estadoCivil,
  }) async {
    try {
      await _db.collection('pacientes').add({
        'nombreCompleto': nombreCompleto,
        'fechaNacimiento': fechaNacimiento,
        'genero': genero,
        'telefono': telefono,
        'correo': correo ?? '',
        'direccion': direccion ?? '',
        'nombreFamiliar': nombreFamiliar ?? '',
        'telefonoFamiliar': telefonoFamiliar ?? '',
        'parentesco': parentesco ?? '',
        'estadoCivil': estadoCivil ?? '',
        'creadoEn': FieldValue.serverTimestamp(),
      });
      print('✅ Paciente agregado: $nombreCompleto');
      return true;
    } catch (e) {
      print('❌ Error agregando paciente: $e');
      return false;
    }
  }

  /// Obtener lista de pacientes
  Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final snapshot = await _db.collection('pacientes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombreCompleto': data['nombreCompleto'] ?? '',
          'fechaNacimiento': data['fechaNacimiento'],
          'genero': data['genero'] ?? '',
          'telefono': data['telefono'] ?? '',
          'correo': data['correo'] ?? '',
          'direccion': data['direccion'] ?? '',
          'habitacion': data['habitacion'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo pacientes: $e');
      return [];
    }
  }
}
