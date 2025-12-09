import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTA LAS PANTALLAS DEL MÓDULO LABORATORIO
import '../dashboard_laboratorio.dart';
import '../solicitudes_laboratorio.dart';
import '../resultados_laboratorio.dart';

/// ========= PALETA DE COLORES PANEL LABORATORIO =========
const Color kLBlack = Color(0xFF000000);
const Color kLWhite = Color(0xFFFFFFFF);

const Color kLPrimaryBlue = Color(0xFF1991DB);
const Color kLBlue12 = Color(0x1F1991DB);
const Color kLBlue15 = Color(0x261991DB);
const Color kLLightBlue = Color(0xFFBEE8FF);

const Color kLGreenBright = Color(0xFF1CC37B);
const Color kLGreenMid = Color(0xFF20D74B);
const Color kLGreenDark = Color(0xFF05531A);
const Color kLRed = Color(0xFFDD0000);
const Color kLRedSoft = Color(0x66FF2B28);
const Color kLYellow = Color(0xFFFFE046);
const Color kLOrange = Color(0xFFFF9800);

const Color kLGreyText = Color(0xFF5C5B5B);
const Color kLGreyBorder = Color(0xFF8F8E8E);
const Color kLGreyChip = Color(0xFF8B8688);
const Color kLGreyBg = Color(0xFFEFF3F7);

const Color kLSidebarBlue = kLPrimaryBlue;
const Color kLSidebarLightBlue = kLLightBlue;
const Color kLBgLight = Color(0xFFF7FAFF);

const String kLLabLogoPath = 'assets/images/logo_hospital.png';

/// LAYOUT GENERAL DEL PANEL LABORATORIO
class LaboratoryLayout extends StatefulWidget {
  final int initialIndex;

  const LaboratoryLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<LaboratoryLayout> createState() => _LaboratoryLayoutState();
}

class _LaboratoryLayoutState extends State<LaboratoryLayout> {
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

  void _handleLogout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return LaboratoryDashboardScreen(onNavigate: _handleMenuSelected);
      case 1:
        return const LaboratoryRequestsScreen();
      case 2:
        return const LaboratoryResultsScreen();
      default:
        return LaboratoryDashboardScreen(onNavigate: _handleMenuSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Scaffold(
            backgroundColor: kLBgLight,
            appBar: AppBar(
              backgroundColor: kLSidebarBlue,
              title: Text(
                'Panel Laboratorio',
                style: GoogleFonts.archivo(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            drawer: _LaboratoryDrawer(
              selectedIndex: _selectedIndex,
              onMenuSelected: _handleMenuSelected,
              onLogout: _handleLogout,
            ),
            body: _getCurrentPage(),
          );
        }

        return Scaffold(
          backgroundColor: kLBgLight,
          body: Row(
            children: [
              _LaboratorySideMenu(
                selectedIndex: _selectedIndex,
                onMenuSelected: _handleMenuSelected,
                onLogout: _handleLogout,
              ),
              Expanded(
                child: Container(
                  color: kLWhite,
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

class _LaboratorySideMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const _LaboratorySideMenu({
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  State<_LaboratorySideMenu> createState() => _LaboratorySideMenuState();
}

class _LaboratorySideMenuState extends State<_LaboratorySideMenu> {
  String _userName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      // Intentar obtener de SharedPreferences primero
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('current_username');
      
      if (currentUsername != null && currentUsername.isNotEmpty) {
        // Buscar nombre completo en la colección personal
        final personalDoc = await FirebaseFirestore.instance
            .collection('personal')
            .where('username', isEqualTo: currentUsername)
            .limit(1)
            .get();
        
        if (personalDoc.docs.isNotEmpty && mounted) {
          setState(() {
            _userName = personalDoc.docs.first.data()['nombre'] ?? currentUsername;
          });
          return;
        }
        
        // Si no se encuentra en personal, buscar en users
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: currentUsername)
            .limit(1)
            .get();
        
        if (userDoc.docs.isNotEmpty && mounted) {
          setState(() {
            _userName = userDoc.docs.first.data()['name'] ?? currentUsername;
          });
          return;
        }
        
        if (mounted) {
          setState(() {
            _userName = currentUsername;
          });
        }
      } else {
        // Fallback a FirebaseAuth
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && mounted) {
          setState(() {
            _userName = currentUser.displayName ?? currentUser.email ?? 'Usuario';
          });
        }
      }
    } catch (e) {
      print('❌ Error cargando nombre de usuario: $e');
      if (mounted) {
        setState(() {
          _userName = 'Usuario';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: kLSidebarLightBlue,
      child: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            color: kLSidebarBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: kLWhite,
                      child: Icon(
                        Icons.science,
                        color: kLSidebarBlue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Laboratorio',
                      style: GoogleFonts.archivo(
                        color: kLWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: kLWhite, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _userName,
                        style: GoogleFonts.archivoNarrow(
                          color: kLWhite,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
                  selected: widget.selectedIndex == 0,
                  onTap: () => widget.onMenuSelected(0),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.assignment_outlined,
                  text: 'Solicitudes',
                  selected: widget.selectedIndex == 1,
                  onTap: () => widget.onMenuSelected(1),
                ),
                const SizedBox(height: 18),
                _SideItem(
                  icon: Icons.description_outlined,
                  text: 'Resultados',
                  selected: widget.selectedIndex == 2,
                  onTap: () => widget.onMenuSelected(2),
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
                  backgroundColor: kLSidebarBlue,
                  foregroundColor: kLWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.archivo(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: widget.onLogout,
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
          Icon(icon, color: kLBlack, size: 22),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.archivoNarrow(
              fontSize: 18,
              color: kLBlack,
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

class _LaboratoryDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const _LaboratoryDrawer({
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  State<_LaboratoryDrawer> createState() => _LaboratoryDrawerState();
}

class _LaboratoryDrawerState extends State<_LaboratoryDrawer> {
  String _userName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('current_username');
      
      if (currentUsername != null && currentUsername.isNotEmpty) {
        final personalDoc = await FirebaseFirestore.instance
            .collection('personal')
            .where('username', isEqualTo: currentUsername)
            .limit(1)
            .get();
        
        if (personalDoc.docs.isNotEmpty && mounted) {
          setState(() {
            _userName = personalDoc.docs.first.data()['nombre'] ?? currentUsername;
          });
          return;
        }
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: currentUsername)
            .limit(1)
            .get();
        
        if (userDoc.docs.isNotEmpty && mounted) {
          setState(() {
            _userName = userDoc.docs.first.data()['name'] ?? currentUsername;
          });
          return;
        }
        
        if (mounted) {
          setState(() {
            _userName = currentUsername;
          });
        }
      } else {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && mounted) {
          setState(() {
            _userName = currentUser.displayName ?? currentUser.email ?? 'Usuario';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'Usuario';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void handleSelect(int index) {
      Navigator.pop(context);
      widget.onMenuSelected(index);
    }

    return Drawer(
      child: Container(
        color: kLSidebarLightBlue,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 90,
                width: double.infinity,
                color: kLSidebarBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Laboratorio',
                      style: GoogleFonts.archivo(
                        color: kLWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, color: kLWhite, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _userName,
                            style: GoogleFonts.archivoNarrow(
                              color: kLWhite,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SideItem(
                icon: Icons.home,
                text: 'Inicio',
                selected: widget.selectedIndex == 0,
                onTap: () => handleSelect(0),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.assignment_outlined,
                text: 'Solicitudes',
                selected: widget.selectedIndex == 1,
                onTap: () => handleSelect(1),
              ),
              const SizedBox(height: 16),
              _SideItem(
                icon: Icons.description_outlined,
                text: 'Resultados',
                selected: widget.selectedIndex == 2,
                onTap: () => handleSelect(2),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLSidebarBlue,
                      foregroundColor: kLWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.archivo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onLogout();
                    },
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

/// Logo circular reutilizable
class LaboratoryLogoCircle extends StatelessWidget {
  const LaboratoryLogoCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: kLWhite,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          kLLabLogoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
