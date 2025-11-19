import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xff9fd1f8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Administrador",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 40),

          _menuItem(Icons.home, "Inicio"),
          _menuItem(Icons.people, "Personal"),
          _menuItem(Icons.attach_money, "Finanzas"),
          _menuItem(Icons.apartment, "Infraestructura"),
          _menuItem(Icons.description, "Reportes"),
          _menuItem(Icons.settings, "Configuración"),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Cerrar sesión",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 25),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          )
        ],
      ),
    );
  }
}
