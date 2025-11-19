import 'package:flutter/material.dart';

class SideMenuReception extends StatelessWidget {
  final bool isDrawer;

  const SideMenuReception({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDrawer ? double.infinity : 250,
      color: const Color(0xffbfe3fa),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITULO SUPERIOR
          Container(
            width: double.infinity,
            color: const Color(0xff1d9bf0),
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
            child: const Text(
              "Recepción",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // OPCION DE MENU
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: const [
                Icon(Icons.home, size: 24, color: Colors.black87),
                SizedBox(width: 12),
                Text(
                  "Inicio",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),

          const Spacer(),

          // BOTON CERRAR SESIÓN
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1d9bf0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (isDrawer) {
                  Navigator.pop(context);
                }
                // Aquí añade tu lógica de cerrar sesión
              },
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
}
