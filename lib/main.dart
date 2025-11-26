import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'farmacia/dashboard.dart';

void main() {
  runApp(const ProyectoHospitalApp());
}

class ProyectoHospitalApp extends StatelessWidget {
  const ProyectoHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí indicamos si queremos Material 3 o no
    final ThemeData base = ThemeData.light(
      useMaterial3: false, // 👈 ahora se configura en el constructor
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Hospitalario',
      theme: base.copyWith(
        textTheme: GoogleFonts.archivoNarrowTextTheme(base.textTheme),
        scaffoldBackgroundColor: Colors.white,
        // ya NO ponemos useMaterial3 aquí
      ),
      home: const DashboardScreen(),
    );
  }
}
