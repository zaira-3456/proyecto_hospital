import 'package:cloud_firestore/cloud_firestore.dart';

/// Script de diagnóstico para verificar datos en Firestore
class FirestoreDiagnostic {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Verificar todas las colecciones y sus documentos
  Future<void> diagnoseAllCollections() async {
    print('\n========================================');
    print('DIAGNÓSTICO DE FIRESTORE');
    print('========================================\n');

    final collections = [
      'usuarios',
      'pacientes',
      'citas',
      'medicamentos_inventario',
      'personal',
      'areas_hospital',
      'metricas_financieras',
      'historial_financiero',
      'tareas_urgentes',
      'tareas_enfermeria',
      'app_meta',
    ];

    for (final collection in collections) {
      await _diagnoseCollection(collection);
    }

    print('\n========================================');
    print('FIN DEL DIAGNÓSTICO');
    print('========================================\n');
  }

  Future<void> _diagnoseCollection(String collectionName) async {
    try {
      final snapshot = await _db.collection(collectionName).get();
      
      print('📦 Colección: $collectionName');
      print('   Total documentos: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        print('   ⚠️  VACÍA - No hay documentos');
      } else {
        print('   ✅ Documentos encontrados:');
        for (final doc in snapshot.docs) {
          final data = doc.data();
          print('      - ID: ${doc.id}');
          
          // Mostrar campos clave según la colección
          if (collectionName == 'usuarios') {
            print('        username: ${data['username']}, rol: ${data['rol']}');
          } else if (collectionName == 'pacientes') {
            print('        nombre: ${data['nombreCompleto']}, habitacion: ${data['habitacion']}');
          } else if (collectionName == 'citas') {
            print('        pacienteId: ${data['pacienteId']}, medicoId: ${data['medicoId']}, fecha: ${data['fechaHora']}');
          } else if (collectionName == 'personal') {
            print('        nombre: ${data['nombre']}, tipo: ${data['tipo']}, area: ${data['area']}');
          } else if (collectionName == 'medicamentos_inventario') {
            print('        nombre: ${data['nombre']}, stock: ${data['stock']}');
          } else if (collectionName == 'areas_hospital') {
            print('        nombre: ${data['nombre']}, camas: ${data['totalCamas']}');
          }
        }
      }
      print('');
    } catch (e) {
      print('❌ Error en colección $collectionName: $e\n');
    }
  }

  /// Verificar sincronización específica entre módulos
  Future<void> checkSynchronization() async {
    print('\n========================================');
    print('VERIFICACIÓN DE SINCRONIZACIÓN');
    print('========================================\n');

    // 1. Verificar que las citas tengan pacientes válidos
    await _checkCitasWithPatients();

    // 2. Verificar que las citas tengan médicos válidos
    await _checkCitasWithDoctors();

    // 3. Verificar que el personal médico esté en áreas válidas
    await _checkPersonalWithAreas();

    print('\n========================================');
    print('FIN DE VERIFICACIÓN DE SINCRONIZACIÓN');
    print('========================================\n');
  }

  Future<void> _checkCitasWithPatients() async {
    print('🔍 Verificando citas con pacientes...');
    try {
      final citas = await _db.collection('citas').get();
      final pacientes = await _db.collection('pacientes').get();
      
      final pacienteIds = pacientes.docs.map((doc) => doc.id).toSet();
      
      for (final cita in citas.docs) {
        final pacienteId = cita.data()['pacienteId'];
        if (pacienteId != null && !pacienteIds.contains(pacienteId)) {
          print('   ⚠️  Cita ${cita.id} tiene pacienteId inválido: $pacienteId');
        }
      }
      print('   ✅ Verificación completada\n');
    } catch (e) {
      print('   ❌ Error: $e\n');
    }
  }

  Future<void> _checkCitasWithDoctors() async {
    print('🔍 Verificando citas con médicos...');
    try {
      final citas = await _db.collection('citas').get();
      final personal = await _db.collection('personal').get();
      
      final medicoIds = personal.docs
          .where((doc) => doc.data()['tipo'] == 'medico')
          .map((doc) => doc.id)
          .toSet();
      
      // También verificar usuarios con rol médico
      final usuarios = await _db.collection('usuarios').get();
      final usuarioMedicoIds = usuarios.docs
          .where((doc) => doc.data()['rol'] == 'medico')
          .map((doc) => doc.id)
          .toSet();
      
      for (final cita in citas.docs) {
        final medicoId = cita.data()['medicoId'];
        if (medicoId != null && 
            !medicoIds.contains(medicoId) && 
            !usuarioMedicoIds.contains(medicoId)) {
          print('   ⚠️  Cita ${cita.id} tiene medicoId inválido: $medicoId');
          print('      (No está en personal ni en usuarios)');
        }
      }
      print('   ✅ Verificación completada\n');
    } catch (e) {
      print('   ❌ Error: $e\n');
    }
  }

  Future<void> _checkPersonalWithAreas() async {
    print('🔍 Verificando personal con áreas...');
    try {
      final personal = await _db.collection('personal').get();
      final areas = await _db.collection('areas_hospital').get();
      
      final areaNombres = areas.docs.map((doc) => doc.data()['nombre']).toSet();
      
      for (final p in personal.docs) {
        final area = p.data()['area'];
        if (area != null && !areaNombres.contains(area)) {
          print('   ℹ️  Personal ${p.data()['nombre']} tiene área: $area (no está en areas_hospital)');
        }
      }
      print('   ✅ Verificación completada\n');
    } catch (e) {
      print('   ❌ Error: $e\n');
    }
  }

  /// Verificar datos faltantes para cada módulo
  Future<void> checkMissingDataForModules() async {
    print('\n========================================');
    print('VERIFICACIÓN DE DATOS FALTANTES POR MÓDULO');
    print('========================================\n');

    // Recepción: necesita pacientes, doctores, áreas
    print('📋 MÓDULO RECEPCIÓN:');
    await _checkReceptionData();

    // Médico: necesita citas, pacientes
    print('\n📋 MÓDULO MÉDICO:');
    await _checkDoctorData();

    // Farmacia: necesita inventario
    print('\n📋 MÓDULO FARMACIA:');
    await _checkPharmacyData();

    // Enfermería: necesita pacientes, tareas
    print('\n📋 MÓDULO ENFERMERÍA:');
    await _checkNursingData();

    // Admin: necesita personal, áreas, finanzas
    print('\n📋 MÓDULO ADMIN:');
    await _checkAdminData();

    print('\n========================================');
    print('FIN DE VERIFICACIÓN DE DATOS FALTANTES');
    print('========================================\n');
  }

  Future<void> _checkReceptionData() async {
    final pacientes = await _db.collection('pacientes').get();
    final personal = await _db.collection('personal').get();
    final areas = await _db.collection('areas_hospital').get();
    
    final medicos = personal.docs.where((doc) => doc.data()['tipo'] == 'medico').length;
    
    print('   Pacientes: ${pacientes.docs.length} ${pacientes.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
    print('   Médicos en personal: $medicos ${medicos == 0 ? "⚠️  FALTA" : "✅"}');
    print('   Áreas: ${areas.docs.length} ${areas.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
  }

  Future<void> _checkDoctorData() async {
    final citas = await _db.collection('citas').get();
    final pacientes = await _db.collection('pacientes').get();
    
    print('   Citas: ${citas.docs.length} ${citas.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
    print('   Pacientes: ${pacientes.docs.length} ${pacientes.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
  }

  Future<void> _checkPharmacyData() async {
    final inventario = await _db.collection('medicamentos_inventario').get();
    
    print('   Medicamentos: ${inventario.docs.length} ${inventario.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
  }

  Future<void> _checkNursingData() async {
    final pacientes = await _db.collection('pacientes').get();
    final tareas = await _db.collection('tareas_enfermeria').get();
    
    print('   Pacientes: ${pacientes.docs.length} ${pacientes.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
    print('   Tareas: ${tareas.docs.length} ${tareas.docs.isEmpty ? "ℹ️  VACÍA (normal si no hay tareas)" : "✅"}');
  }

  Future<void> _checkAdminData() async {
    final personal = await _db.collection('personal').get();
    final areas = await _db.collection('areas_hospital').get();
    final metricas = await _db.collection('metricas_financieras').get();
    final historial = await _db.collection('historial_financiero').get();
    
    print('   Personal: ${personal.docs.length} ${personal.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
    print('   Áreas: ${areas.docs.length} ${areas.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
    print('   Métricas financieras: ${metricas.docs.length} ${metricas.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
    print('   Historial financiero: ${historial.docs.length} ${historial.docs.isEmpty ? "⚠️  FALTA" : "✅"}');
  }
}
