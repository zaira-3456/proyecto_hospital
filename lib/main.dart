import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// LOGIN
import 'screens/login/login_screens.dart';

// DASHBOARDS
import 'screens/admin/admin_layout.dart';
import 'screens/medico/medico/dashboard_medico.dart';
import 'screens/farmacia/dashboard.dart';
import 'screens/enfermeria/dashboard_enfermeria.dart';
import 'screens/recepcionista/recepcionista/recepcionist_dashboard.dart';

// Servicio de BD (lo usaremos para sembrar datos)
import 'screens/login/services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⚠️ SOLO PARA DESARROLLO:
  // crea datos de ejemplo en todas las colecciones
  // puedes comentar esta línea después de la primera vez.
  await DatabaseService().seedDemoData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminLayout(),
        '/medico': (context) => const DoctorDashboardScreen(),
        '/farmacia': (context) => const DashboardScreen(),
        '/recepcion': (context) => const ReceptionistDashboard(),
        '/enfermeria': (context) => const NurseDashboardScreen(),
      },
    );
  }
}
