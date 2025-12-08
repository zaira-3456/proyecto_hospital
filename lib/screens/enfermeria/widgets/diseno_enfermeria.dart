import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/user_name_widget.dart';
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

const String kNHospitalLogoPath = 'assets/images/logo_hospital.png';

class NurseLayout extends StatefulWidget {
  final int initialIndex;

  const NurseLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<NurseLayout> createState() => _NurseLayoutState();
}

class _NurseLayoutState extends State<NurseLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _handleMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const NurseDashboardScreen();
      case 1:
        return const NursePatientsScreen();
      case 2:
        return const NurseMedicationsScreen();
      default:
        return const NurseDashboardScreen();
    }
  }

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
            drawer: _NurseDrawer(
              selectedIndex: _selectedIndex,
              onMenuSelected: _handleMenuSelected,
              onLogout: _handleLogout,
            ),
            body: _getCurrentPage(),
          );
        }

        return Scaffold(
          backgroundColor: kNBgLight,
          body: Row(
            children: [
              _NurseSideMenu(
                selectedIndex: _selectedIndex,
                onMenuSelected: _handleMenuSelected,
                onLogout: _handleLogout,
              ),
              Expanded(
                child: Container(
                  color: kNWhite,
                  child: _getCurrentPage(),
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
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const _NurseSideMenu({
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enfermería',
                  style: GoogleFonts.archivo(
                    color: kNWhite.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                UserNameWidget(
                  style: GoogleFonts.archivo(
                    color: kNWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                  onTap: () => onMenuSelected(0),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.people_alt_outlined,
                  text: 'Pacientes',
                  selected: selectedIndex == 1,
                  onTap: () => onMenuSelected(1),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.medication_outlined,
                  text: 'Medicamentos',
                  selected: selectedIndex == 2,
                  onTap: () => onMenuSelected(2),
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
                onPressed: onLogout,
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
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const _NurseDrawer({
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    void handleSelect(int index) {
      Navigator.pop(context);
      onMenuSelected(index);
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enfermería',
                      style: GoogleFonts.archivo(
                        color: kNWhite.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    UserNameWidget(
                      style: GoogleFonts.archivo(
                        color: kNWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SideItem(
                icon: Icons.home,
                text: 'Inicio',
                selected: selectedIndex == 0,
                onTap: () => handleSelect(0),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.people_alt_outlined,
                text: 'Pacientes',
                selected: selectedIndex == 1,
                onTap: () => handleSelect(1),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.medication_outlined,
                text: 'Medicamentos',
                selected: selectedIndex == 2,
                onTap: () => handleSelect(2),
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
