import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para agregar datos de prueba a las colecciones de Finanzas
/// Ejecutar una sola vez para poblar la base de datos
class FinanceSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedProviders() async {
    print('📦 Agregando proveedores de prueba...');
    
    final providers = [
      {
        'nombre': 'Farmacéutica Global S.A.',
        'telefono': '756 112 3045',
        'correo': 'contacto@farmglobal.com',
        'servicio': 'Medicamentos',
        'estado': 'Activo',
      },
      {
        'nombre': 'Suministros Médicos del Sur',
        'telefono': '756 113 3241',
        'correo': 'ventas@suministrosur.com',
        'servicio': 'Material Quirúrgico',
        'estado': 'Activo',
      },
      {
        'nombre': 'Muebles Hospitalarios Elite',
        'telefono': '756 152 4562',
        'correo': 'info@muebleshosp.com',
        'servicio': 'Mobiliario',
        'estado': 'Inactivo',
      },
      {
        'nombre': 'Servicios Integrales de Salud',
        'telefono': '756 189 4589',
        'correo': 'servicios@sissalud.com',
        'servicio': 'Servicios de Mantenimiento',
        'estado': 'Activo',
      },
      {
        'nombre': 'Distribuidora General Médica',
        'telefono': '756 145 5859',
        'correo': 'pedidos@distgenmedica.com',
        'servicio': 'Suministros Generales',
        'estado': 'Activo',
      },
    ];

    for (var provider in providers) {
      await _firestore.collection('finanzas_proveedores').add(provider);
    }
    
    print('✅ Proveedores agregados exitosamente');
  }

  static Future<void> seedPurchaseOrders() async {
    print('📦 Agregando órdenes de compra de prueba...');
    
    final orders = [
      {
        'id': 'OC001',
        'proveedorNombre': 'Farmacéutica Global S.A.',
        'tipo': 'Medicamentos',
        'area': 'Farmacia',
        'presupuesto': 5000.00,
        'estado': 'Solicitud',
      },
      {
        'id': 'OC002',
        'proveedorNombre': 'Suministros Médicos del Sur',
        'tipo': 'Material Quirúrgico',
        'area': 'Quirófano',
        'presupuesto': 12000.00,
        'estado': 'Aprobada',
      },
      {
        'id': 'OC003',
        'proveedorNombre': 'Muebles Hospitalarios Elite',
        'tipo': 'Mobiliario',
        'area': 'Consulta Externa',
        'presupuesto': 20000.00,
        'estado': 'Recibida',
      },
      {
        'id': 'OC004',
        'proveedorNombre': 'Servicios Integrales de Salud',
        'tipo': 'Mantenimiento',
        'area': 'Emergencia',
        'presupuesto': 8500.00,
        'estado': 'Aprobada',
      },
      {
        'id': 'OC005',
        'proveedorNombre': 'Distribuidora General Médica',
        'tipo': 'Suministros',
        'area': 'Laboratorio',
        'presupuesto': 3500.00,
        'estado': 'Solicitud',
      },
    ];

    for (var order in orders) {
      await _firestore.collection('finanzas_ordenes_compra').add(order);
    }
    
    print('✅ Órdenes de compra agregadas exitosamente');
  }

  static Future<void> seedAll() async {
    try {
      print('🌱 Iniciando seeding de datos de Finanzas...');
      await seedProviders();
      await seedPurchaseOrders();
      print('✅ Seeding completado exitosamente');
    } catch (e) {
      print('❌ Error durante el seeding: $e');
    }
  }

  /// Elimina todos los datos de las colecciones (útil para resetear)
  static Future<void> clearAll() async {
    try {
      print('🗑️  Eliminando datos de Finanzas...');
      
      // Eliminar proveedores
      final providersSnapshot = await _firestore.collection('finanzas_proveedores').get();
      for (var doc in providersSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Eliminar órdenes de compra
      final ordersSnapshot = await _firestore.collection('finanzas_ordenes_compra').get();
      for (var doc in ordersSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ Datos eliminados exitosamente');
    } catch (e) {
      print('❌ Error durante la eliminación: $e');
    }
  }
}

// Para ejecutar el seeding, llamar desde main.dart o cualquier widget:
// 
// import 'package:proyecto_hospital/screens/finanzas/finanzas/finanzas/services/finance_seeder.dart';
//
// // En initState o en un botón:
// FinanceSeeder.seedAll();
//
// // Para limpiar datos:
// FinanceSeeder.clearAll();
