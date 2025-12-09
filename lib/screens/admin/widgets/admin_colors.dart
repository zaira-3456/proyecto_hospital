import 'package:flutter/material.dart';

/// ========= PALETA DE COLORES MÓDULO ADMIN =========

// Básicos
const Color kABlack = Color(0xFF000000);
const Color kAWhite = Color(0xFFFFFFFF);

// Azules (Principal)
const Color kAPrimaryBlue = Color(0xFF1D9BF0);
const Color kALightBlue = Color(0xFFC7E7FF);
const Color kABlue15 = Color(0x261D9BF0);

// Grises
const Color kAGreyText = Color(0xFF5C5B5B);
const Color kABgLight = Color(0xFFF5F8FB);

// Alias para componentes específicos
const Color kASidebarBlue = kAPrimaryBlue;
const Color kASidebarLightBlue = kALightBlue;

// Logo del hospital
const String kAHospitalLogoPath = 'assets/images/logo_hospital.png';

/// Logo circular reutilizable
class AdminLogoCircle extends StatelessWidget {
  const AdminLogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: kAWhite,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          kAHospitalLogoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
