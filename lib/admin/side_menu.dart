import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final Function(int) onSelect;
  final int selectedIndex;

  const SideMenu({
    super.key,
    required this.onSelect,
    required this.selectedIndex,
  });

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
            padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 25),
            color: const Color(0xff1d9bf0),
            child: const Text(
              "Administrador",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
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
                onPressed: () {},
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
    final bool active = index == selectedIndex;

    return InkWell(
      onTap: () => onSelect(index),
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
