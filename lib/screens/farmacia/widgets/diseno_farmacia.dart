import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importar pantallas hermanas
import '../dashboard.dart';
import '../inventario.dart';
import '../solicitudes.dart';

/// ========= PALETA DE COLORES =========
const Color kBlack        = Color(0xFF000000);
const Color kDarkGray     = Color(0xFF363637);
const Color kPrimaryBlue  = Color(0xFF1991DB);
const Color kCardBlue15   = Color(0x261991DB);
const Color kCardBlue12   = Color(0x1F1991DB);
const Color kPureRed      = Color(0xFFFF0000);
const Color kDarkRed      = Color(0xFFDD0000);
const Color kWhite        = Color(0xFFFFFFFF);
const Color kGreen        = Color(0xFF259528);
const Color kOrange       = Color(0xFFFF7900);

const Color kSidebarBlue      = kPrimaryBlue;
const Color kSidebarLightBlue = Color(0xFFC4E7FF);
const Color kBgLightBlue      = Color(0xFFF5F8FB);

const String kHospitalLogoPath = 'assets/images/logo_hospital.png';

class PharmacyLayout extends StatefulWidget {
  final int initialIndex;

  const PharmacyLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<PharmacyLayout> createState() => _PharmacyLayoutState();
}

class _PharmacyLayoutState extends State<PharmacyLayout> {
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
        return const DashboardScreen();
      case 1:
        return const InventoryScreen();
      case 2:
        return const RequestsScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Scaffold(
            backgroundColor: kBgLightBlue,
            appBar: AppBar(
              backgroundColor: kSidebarBlue,
              title: Text(
                'Farmacia',
                style: GoogleFonts.archivo(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            drawer: _SideDrawer(
              selectedIndex: _selectedIndex,
              onMenuSelected: _handleMenuSelected,
              onLogout: _handleLogout,
            ),
            body: _getCurrentPage(),
          );
        }

        return Scaffold(
          backgroundColor: kBgLightBlue,
          body: Row(
            children: [
              _SideMenu(
                selectedIndex: _selectedIndex,
                onMenuSelected: _handleMenuSelected,
                onLogout: _handleLogout,
              ),
              Expanded(
                child: Container(
                  color: kWhite,
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

class _SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const _SideMenu({
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: kSidebarLightBlue,
      child: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: kSidebarBlue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Farmacia',
              style: GoogleFonts.archivo(
                color: kWhite,
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
                  onTap: () => onMenuSelected(0),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.inventory_2_outlined,
                  text: 'Inventario',
                  selected: selectedIndex == 1,
                  onTap: () => onMenuSelected(1),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.shopping_cart_outlined,
                  text: 'Solicitudes',
                  selected: selectedIndex == 2,
                  onTap: () => onMenuSelected(2),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: kWhite,
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
          Icon(icon, color: kBlack, size: 22),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 18,
              color: kBlack,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const _SideDrawer({
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
        color: kSidebarLightBlue,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 70,
                width: double.infinity,
                color: kSidebarBlue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Farmacia',
                  style: GoogleFonts.archivo(
                    color: kWhite,
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
                onTap: () => handleSelect(0),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.inventory_2_outlined,
                text: 'Inventario',
                selected: selectedIndex == 1,
                onTap: () => handleSelect(1),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.shopping_cart_outlined,
                text: 'Solicitudes',
                selected: selectedIndex == 2,
                onTap: () => handleSelect(2),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: kWhite,
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
        ),
      ),
    );
  }
}

class HospitalLogoCircle extends StatelessWidget {
  const HospitalLogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: kWhite,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          kHospitalLogoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
