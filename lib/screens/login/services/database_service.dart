import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_service.dart';

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
  Future<Map<String, dynamic>?> authenticateUser(
    String username,
    String password,
  ) async {
    try {
      // Primero buscar en la colección nueva 'users'
      var snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      // Si no se encuentra, buscar en la colección antigua 'usuarios' (compatibilidad)
      if (snapshot.docs.isEmpty) {
        snapshot = await _db
            .collection('usuarios')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        print('❌ Usuario no encontrado en Firestore');
        return null;
      }

      final data = snapshot.docs.first.data();
      print('✅ Usuario autenticado: ${data['username']}');

      // Soportar ambos formatos de campos (nuevo y antiguo)
      return {
        'username': data['username'] as String,
        'name': (data['name'] ?? data['nombre'] ?? '') as String,  // Soporta 'name' y 'nombre'
        'role': (data['role'] ?? data['rol'] ?? '') as String,  // Soporta 'role' y 'rol'
        'isFirstLogin': (data['isFirstLogin'] ?? false) as bool,  // Default false para usuarios viejos
      };
    } catch (e) {
      print('❌ Error en authenticateUser: $e');
      return null;
    }
  }

  // ============================================================
  // UPDATE PASSWORD (for first-time login)
  // ============================================================
  Future<bool> updatePassword({
    required String username,
    required String newPassword,
  }) async {
    try {
      // Buscar primero en colección 'users' (nueva)
      var snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // Si no se encuentra, buscar en 'usuarios' (legacy)
      if (snapshot.docs.isEmpty) {
        snapshot = await _db
            .collection('usuarios')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        print('❌ Usuario no encontrado para actualizar contraseña: $username');
        return false;
      }

      await snapshot.docs.first.reference.update({
        'password': newPassword,
        'isFirstLogin': false,
      });

      print('✅ Contraseña actualizada para: $username');
      return true;
    } catch (e) {
      print('❌ Error actualizando contraseña: $e');
      return false;
    }
  }

  // ============================================================
  // UPDATE USERNAME (for first-time login or profile changes)
  // ============================================================
  Future<bool> updateUsername({
    required String oldUsername,
    required String newUsername,
  }) async {
    try {
      // Check if new username already exists in 'users'
      var existingUser = await _db
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .limit(1)
          .get();

      // Check also in 'usuarios' (legacy)
      if (existingUser.docs.isEmpty) {
        existingUser = await _db
            .collection('usuarios')
            .where('username', isEqualTo: newUsername)
            .limit(1)
            .get();
      }

      if (existingUser.docs.isNotEmpty) {
        print('❌ El nombre de usuario $newUsername ya está en uso');
        return false;
      }

      // Find user in 'users' first (nueva)
      var snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: oldUsername)
          .limit(1)
          .get();

      // If not found, search in 'usuarios' (legacy)
      if (snapshot.docs.isEmpty) {
        snapshot = await _db
            .collection('usuarios')
            .where('username', isEqualTo: oldUsername)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        print('❌ Usuario no encontrado para actualizar nombre de usuario: $oldUsername');
        return false;
      }

      await snapshot.docs.first.reference.update({
        'username': newUsername,
      });

      print('✅ Nombre de usuario actualizado de $oldUsername a $newUsername');
      return true;
    } catch (e) {
      print('❌ Error actualizando nombre de usuario: $e');
      return false;
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
    String? email,
    String? telefono,
    String? departamento,
  }) async {
    try {
      // Verificar si ya existe en la colección correcta 'users'
      final query = await _db
          .collection('users')  // ✅ CAMBIADO de 'usuarios' a 'users'
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty) {
        print('❌ El usuario $username ya existe.');
        return false;
      }

      await _db.collection('users').add({  // ✅ CAMBIADO de 'usuarios' a 'users'
        'username': username,
        'password': password, // En producción, usar hash
        'name': nombre,  // ✅ CAMBIADO de 'nombre' a 'name'
        'role': rol,  // ✅ Agregado 'role' para consistencia
        'email': email ?? '',
        'telefono': telefono ?? '',
        'departamento': departamento ?? '',
        'activo': true,
        'isFirstLogin': true,  // ✅ AGREGADO para obligar cambio de contraseña
        'creadoEn': FieldValue.serverTimestamp(),
      });

      print('✅ Usuario creado: $username');
      return true;
    } catch (e) {
      print('❌ Error creando usuario: $e');
      return false;
    }
  }

  /// Elimina las credenciales de un usuario para poder reasignarlas
  Future<bool> deleteUserCredentials(String username) async {
    try {
      // Buscar en colección users
      final usersQuery = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      // Eliminar de users
      for (var doc in usersQuery.docs) {
        await doc.reference.delete();
        print('✅ Credenciales eliminadas de users: $username');
      }

      // También buscar en colección usuarios (por si hay datos antiguos)
      final usuariosQuery = await _db
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .get();

      // Eliminar de usuarios
      for (var doc in usuariosQuery.docs) {
        await doc.reference.delete();
        print('✅ Credenciales eliminadas de usuarios: $username');
      }

      return true;
    } catch (e) {
      print('❌ Error eliminando credenciales: $e');
      return false;
    }
  }

  /// Elimina un registro de personal de la base de datos
  Future<bool> deletePersonnel(String personnelId) async {
    try {
      await _db.collection('personal').doc(personnelId).delete();
      print('✅ Personal eliminado: $personnelId');
      return true;
    } catch (e) {
      print('❌ Error eliminando personal: $e');
      return false;
    }
  }

  /// Elimina credenciales de usuario buscando por nombre de personal
  Future<bool> deleteUserCredentialsByName(String personnelName) async {
    try {
      int deletedCount = 0;

      // Buscar en colección 'users' por nombre
      final usersQuery = await _db
          .collection('users')
          .where('name', isEqualTo: personnelName)
          .get();

      for (var doc in usersQuery.docs) {
        await doc.reference.delete();
        deletedCount++;
        print('✅ Credenciales eliminadas de users: ${doc.data()['username']}');
      }

      // Buscar en colección 'usuarios' por nombre
      final usuariosQuery = await _db
          .collection('usuarios')
          .where('nombre', isEqualTo: personnelName)
          .get();

      for (var doc in usuariosQuery.docs) {
        await doc.reference.delete();
        deletedCount++;
        print('✅ Credenciales eliminadas de usuarios: ${doc.data()['username']}');
      }

      if (deletedCount > 0) {
        print('✅ Total credenciales eliminadas: $deletedCount');
        return true;
      } else {
        print('ℹ️ No se encontraron credenciales para: $personnelName');
        return true; // No es error, simplemente no tenía credenciales
      }
    } catch (e) {
      print('❌ Error eliminando credenciales por nombre: $e');
      return false;
    }
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================
  
  /// Enviar código de verificación al email del usuario
  Future<bool> sendVerificationCode(String email) async {
    try {
      // 1. Verificar que el email existe en la base de datos
      final userSnapshot = await _db
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        print('❌ Email no encontrado: $email');
        return false;
      }

      final userData = userSnapshot.docs.first.data();
      final userName = userData['nombre'] ?? 'Usuario';

      // 2. Generar código aleatorio de 6 dígitos
      final random = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
      final code = random.toString();

      // 3. Guardar código en Firestore con expiración de 5 minutos
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 5));

      await _db.collection('verification_codes').add({
        'email': email,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'used': false,
      });

      // 4. Enviar código por correo electrónico
      final emailService = EmailService();
      final emailSent = await emailService.sendVerificationCode(
        recipientEmail: email,
        verificationCode: code,
        recipientName: userName,
      );

      if (emailSent) {
        print('✅ Código de verificación enviado a: $email');
        print('🔐 Código: $code (válido por 5 minutos)');
      } else {
        print('⚠️ Error al enviar email, pero código guardado en Firestore');
        print('🔐 Código de verificación: $code');
      }

      return true;
    } catch (e) {
      print('❌ Error en sendVerificationCode: $e');
      return false;
    }
  }

  /// Verificar código de verificación
  Future<bool> verifyCode(String email, String code) async {
    try {
      // 1. Buscar código en Firestore
      final snapshot = await _db
          .collection('verification_codes')
          .where('email', isEqualTo: email)
          .where('code', isEqualTo: code)
          .where('used', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('❌ Código inválido o ya usado para: $email');
        return false;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final now = DateTime.now();

      // 2. Verificar que no ha expirado
      if (now.isAfter(expiresAt)) {
        print('❌ Código expirado para: $email');
        // Marcar como usado para que no se pueda reutilizar
        await doc.reference.update({'used': true});
        return false;
      }

      // 3. Marcar código como usado
      await doc.reference.update({'used': true});
      
      print('✅ Código verificado exitosamente para: $email');
      return true;
    } catch (e) {
      print('❌ Error en verifyCode: $e');
      return false;
    }
  }

  /// Resetear contraseña del usuario
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      // 1. Buscar usuario por email
      final snapshot = await _db
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('❌ Usuario no encontrado para resetear contraseña: $email');
        return false;
      }

      // 2. Actualizar contraseña
      await snapshot.docs.first.reference.update({
        'password': newPassword,
        'isFirstLogin': false,
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Limpiar códigos de verificación usados (opcional, para mantener limpia la BD)
      final oldCodes = await _db
          .collection('verification_codes')
          .where('email', isEqualTo: email)
          .where('used', isEqualTo: true)
          .get();
      
      for (final doc in oldCodes.docs) {
        await doc.reference.delete();
      }

      print('✅ Contraseña reseteada exitosamente para: $email');
      return true;
    } catch (e) {
      print('❌ Error en resetPassword: $e');
      return false;
    }
  }

  // ============================================================
  // DOCTOR: Get recent appointments
  // ============================================================
  /// Get recent appointments for a specific doctor
  Future<List<Map<String, dynamic>>> getDoctorRecentAppointments({
    required String doctorId,
    int limit = 5,
  }) async {
    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection('citas')
          .where('medicoId', isEqualTo: doctorId)
          .where('fechaHora', isGreaterThanOrEqualTo: now.subtract(const Duration(hours: 24)))
          .orderBy('fechaHora', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> appointments = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final pacienteId = data['pacienteId'];
        
        // Get patient name
        String pacienteNombre = 'Paciente desconocido';
        if (pacienteId != null) {
          final pacienteDoc = await _db.collection('pacientes').doc(pacienteId).get();
          if (pacienteDoc.exists) {
            pacienteNombre = pacienteDoc.data()?['nombreCompleto'] ?? 'Paciente desconocido';
          }
        }
        
        appointments.add({
          'id': doc.id,
          'pacienteNombre': pacienteNombre,
          'motivo': data['motivo'] ?? 'Consulta general',
          'fechaHora': data['fechaHora'],
          'estado': data['estado'] ?? 'programada',
          'prioridad': data['prioridad'] ?? 'normal',
        });
      }
      
      print('✅ Citas del doctor cargadas: ${appointments.length}');
      return appointments;
    } catch (e) {
      print('❌ Error obteniendo citas del doctor: $e');
      return [];
    }
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
      'email': 'admin@hospital.com',
      'nombre': 'Administrador General',
      'rol': 'admin',
      'telefono': '555-000-0000',
      'departamento': 'Administracion',
      'activo': true,
      'isFirstLogin': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('medico'), {
      'username': 'medico',
      'password': '123456',
      'email': 'medico@hospital.com',
      'nombre': 'Dr. Martínez',
      'rol': 'medico',
      'telefono': '555-111-1111',
      'departamento': 'Consulta externa',
      'activo': true,
      'isFirstLogin': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('farmacia'), {
      'username': 'farmacia',
      'password': '123456',
      'email': 'farmacia@hospital.com',
      'nombre': 'Encargado de Farmacia',
      'rol': 'farmacia',
      'telefono': '555-222-2222',
      'departamento': 'Farmacia',
      'activo': true,
      'isFirstLogin': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('recepcion'), {
      'username': 'recepcion',
      'password': '123456',
      'email': 'recepcion@hospital.com',
      'nombre': 'Recepcionista',
      'rol': 'recepcion',
      'telefono': '555-333-3333',
      'departamento': 'Recepcion',
      'activo': true,
      'isFirstLogin': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('enfermeria'), {
      'username': 'enfermeria',
      'password': '123456',
      'email': 'enfermeria@hospital.com',
      'nombre': 'Lic. Enfermería',
      'rol': 'enfermeria',
      'telefono': '555-444-4444',
      'departamento': 'Enfermería',
      'activo': true,
      'isFirstLogin': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('finance'), {
      'username': 'finance',
      'password': '123456',
      'email': 'finance@hospital.com',
      'nombre': 'Gestor Financiero',
      'rol': 'finance',
      'telefono': '555-555-5555',
      'departamento': 'Finanzas',
      'activo': true,
      'isFirstLogin': true,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(usuarios.doc('laboratorio'), {
      'username': 'laboratorio',
      'password': '123456',
      'email': 'laboratorio@hospital.com',
      'nombre': 'Técnico de Laboratorio',
      'rol': 'laboratorio',
      'telefono': '555-666-6666',
      'departamento': 'Laboratorio Clínico',
      'activo': true,
      'isFirstLogin': true,
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
      'estado': 'estable',
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
      'estado': 'estable',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    final pac3 = pacientes.doc();
    batch.set(pac3, {
      'nombreCompleto': 'Ana Patricia Morales',
      'fechaNacimiento': DateTime(1992, 3, 15),
      'genero': 'F',
      'telefono': '555-666-3333',
      'direccion': 'Av. Principal 123',
      'habitacion': '201',
      'estado': 'critico',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    final pac4 = pacientes.doc();
    batch.set(pac4, {
      'nombreCompleto': 'Roberto García Fernández',
      'fechaNacimiento': DateTime(1968, 11, 8),
      'genero': 'M',
      'telefono': '555-666-4444',
      'direccion': 'Calle Norte 45',
      'habitacion': '202',
      'estado': 'recuperacion',
      'creadoEn': FieldValue.serverTimestamp(),
    });

    // ---------- CITAS ----------
    final citas = _db.collection('citas');
    batch.set(citas.doc(), {
      'pacienteId': pac1.id,
      'pacienteNombre': 'María Gonzáles López',
      'pacienteTelefono': '555-666-1111',
      'medicoId': 'medico',
      'doctorNombre': 'Dr. Martínez',
      'areaId': 'consulta_externa',
      'fechaHora': DateTime.now().add(const Duration(hours: 1)),
      'hora': '${DateTime.now().add(const Duration(hours: 1)).hour}:00',
      'motivo': 'Control de hipertensión',
      'tipo': 'seguimiento',
      'estado': 'confirmada',
      'prioridad': 'normal',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(citas.doc(), {
      'pacienteId': pac2.id,
      'pacienteNombre': 'Juan Carlos Ruiz',
      'pacienteTelefono': '555-666-2222',
      'medicoId': 'medico',
      'doctorNombre': 'Dr. Martínez',
      'areaId': 'consulta_externa',
      'fechaHora': DateTime.now().add(const Duration(hours: 2)),
      'hora': '${DateTime.now().add(const Duration(hours: 2)).hour}:00',
      'motivo': 'Consulta general',
      'tipo': 'consultaGeneral',
      'estado': 'confirmada',
      'prioridad': 'normal',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(citas.doc(), {
      'pacienteId': pac3.id,
      'pacienteNombre': 'Ana Patricia Morales',
      'pacienteTelefono': '555-666-3333',
      'medicoId': 'medico',
      'doctorNombre': 'Dra. María Rodríguez',
      'areaId': 'pediatria',
      'fechaHora': DateTime.now().add(const Duration(days: 1)),
      'hora': '10:00',
      'motivo': 'Revisión pediátrica',
      'tipo': 'especialidad',
      'estado': 'confirmada',
      'prioridad': 'alta',
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
      'area': 'Cardiología',
      'tipo': 'medico',
      'turno': 'Matutino',
      'estado': 'Activo',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(personal.doc(), {
      'nombre': 'Dra. María Rodríguez',
      'puesto': 'Pediatra',
      'area': 'Pediatría',
      'tipo': 'medico',
      'turno': 'Matutino',
      'estado': 'Activo',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(personal.doc(), {
      'nombre': 'Dr. José Martínez',
      'puesto': 'Médico General',
      'area': 'Consulta Externa',
      'tipo': 'medico',
      'turno': 'Vespertino',
      'estado': 'Activo',
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(personal.doc(), {
      'nombre': 'Dra. Laura Sánchez',
      'puesto': 'Ginecóloga',
      'area': 'Ginecología',
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
    batch.set(personal.doc(), {
      'nombre': 'Lic. Pedro Ramírez',
      'puesto': 'Enfermero',
      'area': 'Pediatría',
      'tipo': 'enfermeria',
      'turno': 'Matutino',
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
    batch.set(areas.doc('cardiologia'), {
      'nombre': 'Cardiología',
      'totalCamas': 8,
      'camasDisponibles': 2,
      'camasEnUso': 6,
      'estado': 'Operativa',
      'ocupacion': 75,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(areas.doc('pediatria'), {
      'nombre': 'Pediatría',
      'totalCamas': 12,
      'camasDisponibles': 5,
      'camasEnUso': 7,
      'estado': 'Operativa',
      'ocupacion': 58,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(areas.doc('ginecologia'), {
      'nombre': 'Ginecología',
      'totalCamas': 6,
      'camasDisponibles': 1,
      'camasEnUso': 5,
      'estado': 'Operativa',
      'ocupacion': 83,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(areas.doc('consulta_externa'), {
      'nombre': 'Consulta Externa',
      'totalCamas': 0,
      'camasDisponibles': 0,
      'camasEnUso': 0,
      'estado': 'Operativa',
      'ocupacion': 0,
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

    // ---------- TAREAS ENFERMERÍA ----------
    final tareasEnfermeria = _db.collection('tareas_enfermeria');
    batch.set(tareasEnfermeria.doc(), {
      'descripcion': 'Revisar signos vitales Habitación 101',
      'paciente': 'María Gonzáles López',
      'prioridad': 'alta',
      'estado': 'pendiente',
      'hora': '08:00',
      'creadaEn': FieldValue.serverTimestamp(),
    });
    batch.set(tareasEnfermeria.doc(), {
      'descripcion': 'Administrar medicamento a Juan Carlos Ruiz',
      'paciente': 'Juan Carlos Ruiz',
      'prioridad': 'media',
      'estado': 'pendiente',
      'hora': '10:00',
      'creadaEn': FieldValue.serverTimestamp(),
    });
    batch.set(tareasEnfermeria.doc(), {
      'descripcion': 'Cambio de vendaje Habitación 102',
      'paciente': 'Juan Carlos Ruiz',
      'prioridad': 'normal',
      'estado': 'pendiente',
      'hora': '14:00',
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

  /// Actualizar datos del personal
  Future<bool> updatePersonnel({
    required String personnelId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection('personal').doc(personnelId).update(data);
      print('✅ Personal actualizado: $personnelId');
      return true;
    } catch (e) {
      print('❌ Error actualizando personal: $e');
      return false;
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
    // Nuevos campos
    DateTime? fechaNacimiento,
    String? curp,
    String? rfc,
    String? genero,
    String? telefono,
    String? correo,
    String? direccion,
  }) async {
    try {
      await _db.collection('personal').add({
        'nombre': nombre,
        'puesto': puesto,
        'area': area,
        'tipo': tipo,
        'turno': turno,
        'estado': estado,
        // Guardar nuevos campos
        'fechaNacimiento': fechaNacimiento,
        'curp': curp ?? '',
        'rfc': rfc ?? '',
        'genero': genero ?? '',
        'telefono': telefono ?? '',
        'correo': correo ?? '',
        'direccion': direccion ?? '',
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

  /// Actualizar paciente existente
  Future<bool> updatePatient({
    required String id,
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
      await _db.collection('pacientes').doc(id).update({
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
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      print('✅ Paciente actualizado: $nombreCompleto');
      return true;
    } catch (e) {
      print('❌ Error actualizando paciente: $e');
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

  /// Agregar visita de paciente
  Future<bool> addVisit({
    required String pacienteId,
    required String pacienteNombre,
    required DateTime fecha,
    required String motivo,
    required String notas,
    required String presion,
    required String frecuenciaCardiaca,
    required String temperatura,
    required String peso,
    required String altura,
    required String diagnostico,
    required List<Map<String, String>> medicamentos,
    required String planTratamiento,
    DateTime? proximaVisita,
  }) async {
    try {
      await _db.collection('visits').add({
        'pacienteId': pacienteId,
        'pacienteNombre': pacienteNombre,
        'fecha': fecha,
        'motivo': motivo,
        'notas': notas,
        'signosVitales': {
          'presion': presion,
          'frecuenciaCardiaca': frecuenciaCardiaca,
          'temperatura': temperatura,
          'peso': peso,
          'altura': altura,
        },
        'diagnostico': diagnostico,
        'medicamentos': medicamentos,
        'planTratamiento': planTratamiento,
        'proximaVisita': proximaVisita,
        'creadoEn': FieldValue.serverTimestamp(),
      });
      print('✅ Visita agregada para paciente: $pacienteNombre');
      return true;
    } catch (e) {
      print('❌ Error agregando visita: $e');
      return false;
    }
  }

  // ============================================================
  // STUDY REQUESTS - Solicitudes de Estudios/Laboratorio
  // ============================================================
  
  /// Crear solicitud de estudio (Médico)
  Future<bool> createStudyRequest({
    required String pacienteId,
    required String pacienteNombre,
    required String medicoId,
    required String medicoNombre,
    required String tipoEstudio,
    required String prioridad,
    String? notas,
  }) async {
    try {
      await _db.collection('study_requests').add({
        'pacienteId': pacienteId,
        'pacienteNombre': pacienteNombre,
        'medicoId': medicoId,
        'medicoNombre': medicoNombre,
        'tipoEstudio': tipoEstudio,
        'prioridad': prioridad,
        'notas': notas ?? '',
        'estado': 'pendiente', // pendiente | en_proceso | completado
        'fechaSolicitud': FieldValue.serverTimestamp(),
        'fechaCompletado': null,
        'resultadoURL': null,
        'observaciones': null,
      });
      print('✅ Solicitud de estudio creada para: $pacienteNombre');
      return true;
    } catch (e) {
      print('❌ Error creando solicitud de estudio: $e');
      return false;
    }
  }

  /// Obtener todas las solicitudes de estudios
  Future<List<Map<String, dynamic>>> getStudyRequests({String? estado}) async {
    try {
      Query query = _db.collection('study_requests');
      
      // Apply where clause first, then orderBy
      if (estado != null) {
        query = query.where('estado', isEqualTo: estado);
      }
      
      query = query.orderBy('fechaSolicitud', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo solicitudes de estudios: $e');
      return [];
    }
  }

  /// Obtener solicitudes de estudios por paciente
  Future<List<Map<String, dynamic>>> getStudyRequestsByPatient(String pacienteId) async {
    try {
      final snapshot = await _db
          .collection('study_requests')
          .where('pacienteId', isEqualTo: pacienteId)
          .orderBy('fechaSolicitud', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo estudios del paciente: $e');
      return [];
    }
  }

  /// Actualizar estado de solicitud de estudio (Laboratorio)
  Future<bool> updateStudyStatus({
    required String requestId,
    required String nuevoEstado,
    String? resultadoURL,
    String? observaciones,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'estado': nuevoEstado,
      };

      if (nuevoEstado == 'completado') {
        updateData['fechaCompletado'] = FieldValue.serverTimestamp();
      }

      if (resultadoURL != null) {
        updateData['resultadoURL'] = resultadoURL;
      }

      if (observaciones != null) {
        updateData['observaciones'] = observaciones;
      }

      await _db.collection('study_requests').doc(requestId).update(updateData);
      print('✅ Estado de solicitud actualizado a: $nuevoEstado');
      return true;
    } catch (e) {
      print('❌ Error actualizando estado de solicitud: $e');
      return false;
    }
  }
}
