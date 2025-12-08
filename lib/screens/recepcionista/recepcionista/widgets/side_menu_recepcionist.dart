import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenuReception extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;
  final VoidCallback onLogout;

  const SideMenuReception({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xffBEE8FF),
      child: Column(
        children: [
          // ===== HEADER "RECEPCIÓN" =====
          Container(
            width: double.infinity,
            height: 80,
            color: const Color(0xff1991DB),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              "Recepción",
              style: GoogleFonts.archivo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ===== LISTA DE OPCIONES DEL MENÚ (CON SCROLL) =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OPCIÓN 1: INICIO
                  _MenuOption(
                    icon: Icons.home,
                    text: "Inicio",
                    isSelected: selectedMenu == 'inicio',
                    onTap: () => onMenuSelected('inicio'),
                  ),

                  const SizedBox(height: 8),

                  // OPCIÓN 2: CITAS
                  _MenuOption(
                    icon: Icons.calendar_today,
                    text: "Citas",
                    isSelected: selectedMenu == 'citas',
                    onTap: () => onMenuSelected('citas'),
                  ),

                  const SizedBox(height: 8),

                  //AGREGAR MÁS OPCIONES AQUÍ
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1991DB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                onPressed: onLogout,
                child: Text(
                  "Cerrar sesión",
                  style: GoogleFonts.archivo(
                    fontSize: 14,
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
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff1991DB).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xff1991DB) : Colors.black87,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xff1991DB) : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
