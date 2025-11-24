import 'package:flutter/material.dart';

class SideMenuReception extends StatelessWidget {
  final bool isDrawer;

  const SideMenuReception({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDrawer ? double.infinity : 360, 
      color: const Color(0xffBEE8FF),
      child: Column( 
        children: [
          // ===== HEADER "RECEPCIÓN" =====
          Container(
            width: double.infinity, 
            height: 100,
            color: const Color(0xff1991DB), 
            alignment: Alignment.centerLeft, 
            padding: const EdgeInsets.only(left: 50), 
            child: const Text( 
              "Recepción",
              style: TextStyle( 
                fontFamily: 'Archivo', 
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.w700, 
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ===== LISTA DE OPCIONES DEL MENÚ (CON SCROLL) =====
          Expanded( 
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 44), 
              child: Column( 
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // OPCIÓN 1: INICIO
                  _MenuOption( 
                    icon: Icons.home, 
                    text: "Inicio", 
                    onTap: () { 
                      if (isDrawer) Navigator.pop(context); 
                    },
                  ),

                  const SizedBox(height: 10), 


                  //AGREGAR MÁS OPCIONES AQUÍ
                ],
              ),
            ),
          ),

          const SizedBox(height: 20), 

          Padding( 
            padding: const EdgeInsets.only(bottom: 40), 
            child: SizedBox( 
              width: 227, 
              height: 50, 
              child: ElevatedButton( 
                style: ElevatedButton.styleFrom( 
                  backgroundColor: const Color(0xff1991DB), 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder( 
                    borderRadius: BorderRadius.circular(10), 
                  ),
                  elevation: 0, 
                  padding: EdgeInsets.zero, 
                ),
                onPressed: () { 
                  if (isDrawer) Navigator.pop(context); 
                  // Implementar lógica de cerrar sesión
                  // Ejemplo: Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text( 
                  "Cerrar sesión",
                  style: TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 18, 
                    fontWeight: FontWeight.w600, 
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MenuOption extends StatelessWidget {
  final IconData icon; 
  final String text; 
  final VoidCallback onTap; 

  const _MenuOption({ 
    required this.icon, 
    required this.text, 
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: onTap,
      child: Container( 
        width: 272, 
        height: 50, 
        decoration: BoxDecoration( 
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(8), 
        ),
        child: Row( 
          children: [
            Icon(
              icon, 
              size: 50, 
              color: Colors.black,
            ),
            const SizedBox(width: 10), 
            Expanded(
              child: Text( 
                text, // 
                style: const TextStyle( 
                  fontFamily: 'Archivo', 
                  fontSize: 24,
                  fontWeight: FontWeight.w500, 
                  color: Colors.black, 
                ),
                overflow: TextOverflow.ellipsis, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}