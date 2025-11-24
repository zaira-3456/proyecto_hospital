import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_enfermeria.dart';
import '../pacientes.dart';
import '../medicamentos.dart';

/// ========= PALETA DE COLORES (ENFERMERÍA) =========
/// basada en tu captura
const Color kNBlack        = Color(0xFF000000);
const Color kNPrimaryBlue  = Color(0xFF1991DB);
const Color kNBlue12       = Color(0x1F1991DB); // 12% opacidad
const Color kNRed          = Color(0xFFFF0000);
const Color kNWhite        = Color(0xFFFFFFFF);
const Color kNGreenBright  = Color(0xFF1CC37B);
const Color kNRedDark      = Color(0xFFD93434);
const Color kNGreenDark    = Color(0xFF259528);
const Color kNLightBlue    = Color(0xFFBEE8FF);
const Color kNRedAlert     = Color(0xFFDD0000);

const Color kNSidebarBlue      = kNPrimaryBlue;
const Color kNSidebarLightBlue = kNLightBlue;
const Color kNBgLight          = Color(0xFFF5F8FB);

const String kNHospitalLogoPath = 'assets/images/logo_hospital.jpeg';

class NurseLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex; // 0: inicio, 1: pacientes, 2: medicamentos

  const NurseLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Scaffold(
            backgroundColor: kNBgLight,
            appBar: AppBar(
              backgroundColor: kNSidebarBlue,
              title: Text(
                'Enfermería',
                style: GoogleFonts.archivo(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            drawer: _NurseDrawer(selectedIndex: selectedIndex),
            body: child,
          );
        }

        return Scaffold(
          backgroundColor: kNBgLight,
          body: Row(
            children: [
              _NurseSideMenu(selectedIndex: selectedIndex),
              Expanded(
                child: Container(
                  color: kNWhite,
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

class _NurseSideMenu extends StatelessWidget {
  final int selectedIndex;

  const _NurseSideMenu({required this.selectedIndex});

  void _goTo(BuildContext context, int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const NurseDashboardScreen();
        break;
      case 1:
        page = const NursePatientsScreen();
        break;
      case 2:
      default:
        page = const NurseMedicationsScreen();
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
      color: kNSidebarLightBlue,
      child: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: kNSidebarBlue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Enfermería',
              style: GoogleFonts.archivo(
                color: kNWhite,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
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
                  icon: Icons.people_alt_outlined,
                  text: 'Pacientes',
                  selected: selectedIndex == 1,
                  onTap: () => _goTo(context, 1),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.medication_outlined,
                  text: 'Medicamentos',
                  selected: selectedIndex == 2,
                  onTap: () => _goTo(context, 2),
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
                  backgroundColor: kNSidebarBlue,
                  foregroundColor: kNWhite,
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
          Icon(icon, color: kNBlack, size: 22),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 18,
              color: kNBlack,
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

class _NurseDrawer extends StatelessWidget {
  final int selectedIndex;

  const _NurseDrawer({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    void go(int index) {
      Navigator.pop(context);
      Widget page;
      switch (index) {
        case 0:
          page = const NurseDashboardScreen();
          break;
        case 1:
          page = const NursePatientsScreen();
          break;
        case 2:
        default:
          page = const NurseMedicationsScreen();
          break;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }

    return Drawer(
      child: Container(
        color: kNSidebarLightBlue,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 70,
                width: double.infinity,
                color: kNSidebarBlue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Enfermería',
                  style: GoogleFonts.archivo(
                    color: kNWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
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
                icon: Icons.people_alt_outlined,
                text: 'Pacientes',
                selected: selectedIndex == 1,
                onTap: () => go(1),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.medication_outlined,
                text: 'Medicamentos',
                selected: selectedIndex == 2,
                onTap: () => go(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo circular reutilizable
class NurseLogoCircle extends StatelessWidget {
  const NurseLogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: kNWhite,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          kNHospitalLogoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
