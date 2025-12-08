import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

// LOGIN
import 'screens/login/login_screens.dart';

// DASHBOARDS
import 'screens/admin/admin_layout.dart';
import 'screens/medico/medico/widgets/diseno_medico.dart';
import 'screens/farmacia/widgets/diseno_farmacia.dart';
import 'screens/enfermeria/widgets/diseno_enfermeria.dart';
import 'screens/recepcionista/recepcionista/recepcionist_dashboard.dart';
import 'screens/laboratorio/widgets/diseno_laboratorio.dart';

// Servicio de BD (lo usaremos para sembrar datos)
import 'screens/login/services/database_service.dart';
import 'screens/login/services/firestore_diagnostic.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⚠️ SOLO PARA DESARROLLO:
  // crea datos de ejemplo en todas las colecciones
  // puedes comentar esta línea después de la primera vez.
  
  // 🔄 RESETEAR SEED (descomentar para forzar recreación de datos)
 //await FirebaseFirestore.instance.collection('app_meta').doc('seed_info').delete();
  
  await DatabaseService().seedDemoData();

  // 🔍 DIAGNÓSTICO: Verificar datos en Firestore
  print('\n🔍 Ejecutando diagnóstico de Firestore...\n');
  final diagnostic = FirestoreDiagnostic();
  await diagnostic.diagnoseAllCollections();
  await diagnostic.checkMissingDataForModules();
  await diagnostic.checkSynchronization();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital App',
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminLayout(),
        '/medico': (context) => const DoctorLayout(),
        '/farmacia': (context) => const PharmacyLayout(),
        '/recepcion': (context) => const ReceptionistDashboard(),
        '/enfermeria': (context) => const NurseLayout(),
        '/laboratorio': (context) => const LaboratoryLayout(),
      },
    );
  }
}
