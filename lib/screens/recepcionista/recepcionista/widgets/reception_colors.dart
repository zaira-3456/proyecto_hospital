import 'package:flutter/material.dart';

/// ========= PALETA DE COLORES MÓDULO RECEPCIÓN =========

// Básicos
const Color kRBlack = Color(0xFF000000);
const Color kRWhite = Color(0xFFFFFFFF);

// Azules (Principal)
const Color kRPrimaryBlue = Color(0xFF1991DB);
const Color kRLightBlue = Color(0xFFBEE8FF);
const Color kRBlue12 = Color(0x1F1991DB);

// Grises
const Color kRGreyText = Color(0xFF5C5B5B);
const Color kRGreyBg = Color(0xFFD9D9D9);
const Color kRBgLight = Color(0xFFF5F8FB);

// Alias para componentes específicos
const Color kRSidebarBlue = kRPrimaryBlue;
const Color kRSidebarLightBlue = kRLightBlue;

// Logo del hospital
const String kRHospitalLogoPath = 'assets/images/logo_hospital.png';

/// Logo circular reutilizable
class ReceptionLogoCircle extends StatelessWidget {
  const ReceptionLogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: kRWhite,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          kRHospitalLogoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
