import 'package:flutter/material.dart';

// IMPORTA TU MENU
import 'side_menu.dart';

// IMPORTA TODAS LAS PANTALLAS
import 'screens/inicio_screen.dart';
import 'screens/personal_screen.dart';
import 'screens/finanzas_screen.dart';
import 'screens/infraestructura_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/configuracion_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  /// ❌ ERROR ORIGINAL:
  /// final List<Widget> pages = const [...]
  ///
  /// NO se puede usar const porque PersonalScreen cambió estructura
  /// y Flutter no puede recargarlo en hot reload.

  /// ✅ SOLUCIÓN:
final List<Widget> pages = [
  const InicioScreen(),
  const PersonalScreen(),
  const FinanzasScreen(),
  const InfraestructuraScreen(),
  const ReportesScreen(),
  const ConfiguracionScreen(),
];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: Colors.white,

          // Drawer cuando es celular
          drawer: isSmall
              ? Drawer(
                  child: SideMenu(
                    selectedIndex: selectedIndex,
                    onSelect: (index) {
                      Navigator.pop(context);
                      setState(() => selectedIndex = index);
                    },
                  ),
                )
              : null,

          appBar: isSmall
              ? AppBar(
                  backgroundColor: const Color(0xff1d9bf0),
                  title: const Text("Panel Administrativo"),
                )
              : null,

          body: Row(
            children: [
              // Side menu para pantallas grandes
              if (!isSmall)
                SideMenu(
                  selectedIndex: selectedIndex,
                  onSelect: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: pages[selectedIndex],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
