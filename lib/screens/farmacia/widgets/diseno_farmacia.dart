import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importar pantallas hermanas
import '../dashboard.dart';
import '../inventario.dart';
import '../solicitudes.dart';

/// ========= PALETA DE COLORES =========
/// (basado en tu captura)
const Color kBlack        = Color(0xFF000000);
const Color kDarkGray     = Color(0xFF363637);
const Color kPrimaryBlue  = Color(0xFF1991DB);
const Color kCardBlue15   = Color(0x261991DB); // 15% opacidad
const Color kCardBlue12   = Color(0x1F1991DB); // 12% opacidad (si quieres sombra)
const Color kPureRed      = Color(0xFFFF0000);
const Color kDarkRed      = Color(0xFFDD0000);
const Color kWhite        = Color(0xFFFFFFFF);
const Color kGreen        = Color(0xFF259528);
const Color kOrange       = Color(0xFFFF7900);

const Color kSidebarBlue      = kPrimaryBlue;
const Color kSidebarLightBlue = Color(0xFFC4E7FF); // azul claro lateral
const Color kBgLightBlue      = Color(0xFFF5F8FB); // fondo general

/// ruta del logo que pusiste
const String kHospitalLogoPath = 'assets/images/logo_hospital.png';

class PharmacyLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex; // 0: inicio, 1: inventario, 2: solicitudes

  const PharmacyLayout({
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
          // App móvil / tablet
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
            drawer: _SideDrawer(selectedIndex: selectedIndex),
            body: child,
          );
        }

        // Escritorio
        return Scaffold(
          backgroundColor: kBgLightBlue,
          body: Row(
            children: [
              _SideMenu(selectedIndex: selectedIndex),
              Expanded(
                child: Container(
                  color: kWhite,
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

/// ========== FUNCIÓN DE NAVEGACIÓN COMÚN ==========

void _navigateToIndex(BuildContext context, int index) {
  Widget page;

  switch (index) {
    case 0:
      page = const DashboardScreen();
      break;
    case 1:
      page = const InventoryScreen();
      break;
    case 2:
    default:
      page = const RequestsScreen();
      break;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => page),
  );
}

/// ========== MENÚ LATERAL ESCRITORIO ==========

class _SideMenu extends StatelessWidget {
  final int selectedIndex;

  const _SideMenu({required this.selectedIndex});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // podrías mostrar un SnackBar si quieres
    }

    // Ir al login y limpiar el stack
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: kSidebarLightBlue,
      child: Column(
        children: [
          // Franja superior
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

          // Opciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SideItem(
                  icon: Icons.home,
                  text: 'Inicio',
                  selected: selectedIndex == 0,
                  onTap: () => _navigateToIndex(context, 0),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.inventory_2_outlined,
                  text: 'Inventario',
                  selected: selectedIndex == 1,
                  onTap: () => _navigateToIndex(context, 1),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.shopping_cart_outlined,
                  text: 'Solicitudes',
                  selected: selectedIndex == 2,
                  onTap: () => _navigateToIndex(context, 2),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Cerrar sesión
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, bottom: 24),
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
                onPressed: () => _logout(context),
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

/// ========== DRAWER MÓVIL ==========

class _SideDrawer extends StatelessWidget {
  final int selectedIndex;

  const _SideDrawer({required this.selectedIndex});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    void go(int index) {
      Navigator.pop(context); // cerrar drawer
      _navigateToIndex(context, index);
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
                onTap: () => go(0),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.inventory_2_outlined,
                text: 'Inventario',
                selected: selectedIndex == 1,
                onTap: () => go(1),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.shopping_cart_outlined,
                text: 'Solicitudes',
                selected: selectedIndex == 2,
                onTap: () => go(2),
              ),
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: kWhite,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.archivo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () => _logout(context),
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

/// Widget reutilizable para el logo circular
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
