import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTA LAS PANTALLAS DEL MÓDULO MÉDICO
import '../dashboard_medico.dart';
import '../pacientes_medico.dart';
import '../estudios_medico.dart';
import '../expedientes_medico.dart';
import '../resultados_medico.dart';
import '../recetas_medico.dart';

/// ========= PALETA DE COLORES PANEL MÉDICO =========
/// A partir de las paletas que mandaste

const Color kMBlack = Color(0xFF000000);
const Color kMWhite = Color(0xFFFFFFFF);

const Color kMPrimaryBlue = Color(0xFF1991DB);
const Color kMBlue12 = Color(0x1F1991DB); // 12% opacidad
const Color kMBlue15 = Color(0x261991DB); // 15% opacidad
const Color kMLightBlue = Color(0xFFBEE8FF);

const Color kMGreenBright = Color(0xFF1CC37B);
const Color kMGreenMid = Color(0xFF20D74B);
const Color kMGreenDark = Color(0xFF05531A);
const Color kMRed = Color(0xFFDD0000);
const Color kMRedSoft = Color(0x66FF2B28); // 40%
const Color kMYellow = Color(0xFFFFE046);

const Color kMGreyText = Color(0xFF5C5B5B);
const Color kMGreyBorder = Color(0xFF8F8E8E);
const Color kMGreyChip = Color(0xFF8B8688);
const Color kMGreyBg = Color(0xFFEFF3F7);

const Color kMSidebarBlue = kMPrimaryBlue;
const Color kMSidebarLightBlue = kMLightBlue;
const Color kMBgLight = Color(0xFFF7FAFF);

const String kMDoctorLogoPath = 'assets/images/logo_hospital.png';

/// LAYOUT GENERAL DEL PANEL MÉDICO
class DoctorLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex; // 0..5 (Inicio, Pacientes, Estudios, Expedientes, Resultados, Recetas)

  const DoctorLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Scaffold(
            backgroundColor: kMBgLight,
            appBar: AppBar(
              backgroundColor: kMSidebarBlue,
              title: Text(
                'Panel Médico',
                style: GoogleFonts.archivo(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            drawer: _DoctorDrawer(selectedIndex: selectedIndex),
            body: child,
          );
        }

        return Scaffold(
          backgroundColor: kMBgLight,
          body: Row(
            children: [
              _DoctorSideMenu(selectedIndex: selectedIndex),
              Expanded(
                child: Container(
                  color: kMWhite,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ========== MENÚ LATERAL ESCRITORIO ==========

class _DoctorSideMenu extends StatelessWidget {
  final int selectedIndex;

  const _DoctorSideMenu({required this.selectedIndex});

  void _goTo(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const DoctorDashboardScreen();
        break;
      case 1:
        page = const DoctorPatientsScreen();
        break;
      case 2:
        page = const DoctorStudiesScreen();
        break;
      case 3:
        page = const DoctorRecordsScreen();
        break;
      case 4:
        page = const DoctorResultsScreen();
        break;
      case 5:
      default:
        page = const DoctorPrescriptionsScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: kMSidebarLightBlue,
      child: Column(
        children: [
          Container(
            height: 90,
            width: double.infinity,
            color: kMSidebarBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: kMWhite,
                  child: Icon(Icons.medical_services,
                      color: kMSidebarBlue, size: 26),
                ),
                const SizedBox(width: 12),
                Text(
                  'Panel Médico',
                  style: GoogleFonts.archivo(
                    color: kMWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SideItem(
                  icon: Icons.home,
                  text: 'Inicio',
                  selected: selectedIndex == 0,
                  onTap: () => _goTo(context, 0),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.groups_outlined,
                  text: 'Pacientes',
                  selected: selectedIndex == 1,
                  onTap: () => _goTo(context, 1),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.biotech_outlined,
                  text: 'Estudios clínicos',
                  selected: selectedIndex == 2,
                  onTap: () => _goTo(context, 2),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.folder_open_outlined,
                  text: 'Expedientes',
                  selected: selectedIndex == 3,
                  onTap: () => _goTo(context, 3),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.monitor_heart_outlined,
                  text: 'Resultados',
                  selected: selectedIndex == 4,
                  onTap: () => _goTo(context, 4),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.receipt_long_outlined,
                  text: 'Recetas',
                  selected: selectedIndex == 5,
                  onTap: () => _goTo(context, 5),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMSidebarBlue,
                  foregroundColor: kMWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.archivo(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {},
                child: const Text('Cerrar sesión'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SideItem({
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: kMBlack,
            size: 22,
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 18,
              color: kMBlack,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// ========== DRAWER MÓVIL ==========

class _DoctorDrawer extends StatelessWidget {
  final int selectedIndex;

  const _DoctorDrawer({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    void go(int index) {
      Navigator.pop(context);
      Widget page;
      switch (index) {
        case 0:
          page = const DoctorDashboardScreen();
          break;
        case 1:
          page = const DoctorPatientsScreen();
          break;
        case 2:
          page = const DoctorStudiesScreen();
          break;
        case 3:
          page = const DoctorRecordsScreen();
          break;
        case 4:
          page = const DoctorResultsScreen();
          break;
        case 5:
        default:
          page = const DoctorPrescriptionsScreen();
          break;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }

    return Drawer(
      child: Container(
        color: kMSidebarLightBlue,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 70,
                width: double.infinity,
                color: kMSidebarBlue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Panel Médico',
                  style: GoogleFonts.archivo(
                    color: kMWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SideItem(
                icon: Icons.home,
                text: 'Inicio',
                selected: selectedIndex == 0,
                onTap: () => go(0),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.groups_outlined,
                text: 'Pacientes',
                selected: selectedIndex == 1,
                onTap: () => go(1),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.biotech_outlined,
                text: 'Estudios clínicos',
                selected: selectedIndex == 2,
                onTap: () => go(2),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.folder_open_outlined,
                text: 'Expedientes',
                selected: selectedIndex == 3,
                onTap: () => go(3),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.monitor_heart_outlined,
                text: 'Resultados',
                selected: selectedIndex == 4,
                onTap: () => go(4),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.receipt_long_outlined,
                text: 'Recetas',
                selected: selectedIndex == 5,
                onTap: () => go(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo circular para la esquina superior derecha
class DoctorLogoCircle extends StatelessWidget {
  const DoctorLogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: kMWhite,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          kMDoctorLogoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
