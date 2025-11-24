import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'enfermeria/dashboard_enfermeria.dart';

void main() {
  runApp(const ProyectoHospitalApp());
}

class ProyectoHospitalApp extends StatelessWidget {
  const ProyectoHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Hospitalario',
      theme: base.copyWith(
        textTheme: GoogleFonts.archivoNarrowTextTheme(base.textTheme),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      // 👇 Ya no usamos rutas ni initialRoute, solo un home.
      home: const  NurseDashboardScreen(),
    );
  }
}