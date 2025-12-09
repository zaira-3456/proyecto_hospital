import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SideMenu extends StatefulWidget {
  final Function(int) onSelect;
  final int selectedIndex;

  const SideMenu({
    super.key,
    required this.onSelect,
    required this.selectedIndex,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String _userName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Buscar en colección users por el email del usuario actual
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: currentUser.displayName ?? currentUser.email)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty && mounted) {
          setState(() {
            _userName = userDoc.docs.first.data()['name'] ?? 'Usuario';
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
    return Container(
      width: 260,
      color: const Color(0xffc7e7ff), // Fondo completo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          //                    ENCABEZADO
          // =====================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            color: const Color(0xff1d9bf0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Administrador",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =====================================================
          //                    OPCIONES
          // =====================================================
          _menuItem(Icons.home_filled, "Inicio", 0),
          _menuItem(Icons.people_alt_rounded, "Personal", 1),
          _menuItem(Icons.attach_money_rounded, "Finanzas", 2),
          _menuItem(Icons.apartment_rounded, "Infraestructura", 3),
          _menuItem(Icons.description_rounded, "Reportes", 4),
          _menuItem(Icons.settings_rounded, "Configuración", 5),

          const Spacer(),

          // =====================================================
          //                 BOTÓN CERRAR SESIÓN
          // =====================================================
          Padding(
            padding: const EdgeInsets.all(30),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1d9bf0),
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  elevation: 1,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    fontSize: 17,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // =====================================================
  //               WIDGET DE OPCIÓN DEL MENÚ
  // =====================================================
  Widget _menuItem(IconData icon, String label, int index) {
    final bool active = index == widget.selectedIndex;

    return InkWell(
      onTap: () => widget.onSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        color: active
            ? const Color(0xff1d9bf0).withOpacity(0.15)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.black87),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
