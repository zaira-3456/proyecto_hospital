import 'package:flutter/material.dart';
import 'finance_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FinanceSidebar extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;
  final VoidCallback onLogout;

  const FinanceSidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: kFLightBlue, // Light cyan background
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: kFPrimaryBlue, // Cyan
            child: Text(
              'Finanzas',
              style: GoogleFonts.archivo(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.home,
                  title: 'Inicio',
                  menuKey: 'inicio',
                ),
                _buildMenuItem(
                  icon: Icons.attach_money,
                  title: 'Ingresos',
                  menuKey: 'ingresos',
                ),
                _buildMenuItem(
                  icon: Icons.credit_card,
                  title: 'Gasto',
                  menuKey: 'gasto',
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: 'Proveedores',
                  menuKey: 'proveedores',
                ),
                _buildMenuItem(
                  icon: Icons.description,
                  title: 'Reportes',
                  menuKey: 'reportes',
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Saldos',
                  menuKey: 'saldos',
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: kFPrimaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cerrar sesión',
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String menuKey,
  }) {
    final isSelected = selectedMenu == menuKey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? kFPrimaryBlue : Colors.black87,
          size: 26,
        ),
        title: Text(
          title,
          style: GoogleFonts.archivo(
            color: isSelected ? kFPrimaryBlue : Colors.black87,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onMenuSelected(menuKey),
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}


