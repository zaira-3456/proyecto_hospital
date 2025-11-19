import 'package:flutter/material.dart';
import '../recepcionista/widgets/menu_recepcionista.dart';
import '../recepcionista/widgets/acciones.dart';

class ReceptionistDashboard extends StatelessWidget {
  const ReceptionistDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isSmall = width < 800;

          return Row(
            children: [
              // MENU LATERAL (solo en pantallas grandes)
              if (!isSmall) const SideMenuReception(),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: Column(
                  children: [
                    // APPBAR para móvil con menú hamburguesa
                    if (isSmall)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu, size: 28),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Recepcionista",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // CONTENIDO SCROLLEABLE
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: isSmall ? 20 : 40,
                          left: isSmall ? 20 : 50,
                          right: isSmall ? 20 : 50,
                          bottom: 40,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITULO PRINCIPAL
                            const Text(
                              "Panel Recepcionista",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // SUBTÍTULO
                            const Text(
                              "Bienvenido de nuevo, Wendy",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // TARJETAS RESPONSIVAS
                            _buildActionCards(width, isSmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // DRAWER para móvil
      drawer: const Drawer(
        child: SideMenuReception(isDrawer: true),
      ),
    );
  }

  Widget _buildActionCards(double width, bool isSmall) {
    if (isSmall) {
      // MÓVIL: tarjetas en columna
      return Column(
        children: [
          ActionCard(
            icon: Icons.person_add_alt_1,
            text: "Registrar\npaciente",
            width: double.infinity,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          ActionCard(
            icon: Icons.medical_information_outlined,
            text: "Agendar\ncita",
            width: double.infinity,
            onTap: () {},
          ),
        ],
      );
    } else {
      // ESCRITORIO: tarjetas en fila
      return Row(
        children: [
          ActionCard(
            icon: Icons.person_add_alt_1,
            text: "Registrar\npaciente",
            width: 260,
            onTap: () {},
          ),
          const SizedBox(width: 40),
          ActionCard(
            icon: Icons.medical_information_outlined,
            text: "Agendar\ncita",
            width: 260,
            onTap: () {},
          ),
        ],
      );
    }
  }
}
