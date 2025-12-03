import 'package:flutter/material.dart';
import 'side_menu.dart';

// IMPORTA TUS PANTALLAS
import 'screens/inicio_screen.dart';
import 'screens/personal_screen.dart';
import 'screens/finanzas_screen.dart';
import 'screens/infraestructura_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/configuracion_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  final List<Widget> pages = const [
    InicioScreen(),
    PersonalScreen(),
    FinanzasScreen(),
    InfraestructuraScreen(),
    ReportesScreen(),
    ConfiguracionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool isMobile = width < 650;
    bool isTablet = width >= 650 && width < 1000;
    bool isDesktop = width >= 1000;

    return Scaffold(
      key: _scaffoldKey,

      // APPBAR SOLO EN MÓVIL
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xff2196F3),
              title: const Text("Administrador"),
              // ❌ ELIMINADO el botón sobrante
            )
          : null,

      // DRAWER SOLO PARA MÓVIL
      drawer: isMobile
          ? Drawer(
              child: SideMenu(
                selectedIndex: selectedIndex,
                onSelect: (i) {
                  setState(() => selectedIndex = i);
                  Navigator.pop(context); // Cierra el Drawer
                },
              ),
            )
          : null,

      // CUERPO PRINCIPAL
      body: Row(
        children: [
          // MENÚ LATERAL PARA TABLET Y ESCRITORIO
          if (!isMobile)
            SizedBox(
              width: isTablet ? 180 : 250,
              child: SideMenu(
                selectedIndex: selectedIndex,
                onSelect: (i) {
                  setState(() => selectedIndex = i);
                },
              ),
            ),

          // CONTENIDO
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}
