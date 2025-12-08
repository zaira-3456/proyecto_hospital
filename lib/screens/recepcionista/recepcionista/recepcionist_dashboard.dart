// archivo: receptionist_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/actions_recepcionist.dart';
import 'widgets/side_menu_recepcionist.dart';
import 'registrar_paciente.dart';
import 'agendar_cita.dart';
import 'gestion_citas.dart';
import '../../../widgets/welcome_message_widget.dart';

class ReceptionistDashboard extends StatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  State<ReceptionistDashboard> createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> {
  String _selectedMenu = 'inicio';

  void _handleLogout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: isSmallScreen
          ? AppBar(
              title: Text(
                'Panel Recepcionista',
                style: GoogleFonts.archivo(),
              ),
              backgroundColor: const Color(0xff1991DB),
              foregroundColor: Colors.white,
            )
          : null,
      drawer: isSmallScreen
          ? Drawer(
              child: SideMenuReception(
                selectedMenu: _selectedMenu,
                onMenuSelected: (menu) {
                  setState(() {
                    _selectedMenu = menu;
                  });
                  Navigator.of(context).pop(); // Close drawer
                },
                onLogout: _handleLogout,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for desktop
          if (!isSmallScreen)
            SideMenuReception(
              selectedMenu: _selectedMenu,
              onMenuSelected: (menu) {
                setState(() {
                  _selectedMenu = menu;
                });
              },
              onLogout: _handleLogout,
            ),

          // Main content
          Expanded(
            child: _selectedMenu == 'citas'
                ? const GestionCitasPage()
                : _selectedMenu == 'registrar'
                    ? RegistroPacientePage(
                        returnRoute: const ReceptionistDashboard(),
                      )
                    : _selectedMenu == 'agendar'
                        ? AgendarCitaPage(
                            returnRoute: const ReceptionistDashboard(),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Panel Recepcionista',
                                          style: GoogleFonts.archivo(
                                            fontSize: isSmallScreen ? 20 : 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        WelcomeMessageWidget(
                                          prefix: 'Bienvenido de nuevo,',
                                          style: GoogleFonts.archivoNarrow(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Action Cards
                                _buildActionCards(context, isSmallScreen),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE TARJETAS =====
  Widget _buildActionCards(BuildContext context, bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (isWide) {
          // DESKTOP: TARJETAS EN FILA HORIZONTAL
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: (constraints.maxWidth - 24) / 2,
                child: ActionCard(
                  icon: Icons.person_add_alt_1,
                  text: "Registrar\npaciente",
                  width: (constraints.maxWidth - 24) / 2,
                  height: 180,
                  onTap: () {
                    setState(() {
                      _selectedMenu = 'registrar';
                    });
                  },
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 24) / 2,
                child: ActionCard(
                  icon: Icons.medical_information_outlined,
                  text: "Agendar\ncita",
                  width: (constraints.maxWidth - 24) / 2,
                  height: 180,
                  onTap: () {
                    setState(() {
                      _selectedMenu = 'agendar';
                    });
                  },
                ),
              ),
            ],
          );
        } else {
          // MÓVIL: TARJETAS APILADAS VERTICALMENTE
          return Column(
            children: [
              ActionCard(
                icon: Icons.person_add_alt_1,
                text: "Registrar\npaciente",
                width: double.infinity,
                height: 180,
                onTap: () {
                  setState(() {
                    _selectedMenu = 'registrar';
                  });
                },
              ),
              const SizedBox(height: 16),
              ActionCard(
                icon: Icons.medical_information_outlined,
                text: "Agendar\ncita",
                width: double.infinity,
                height: 180,
                onTap: () {
                  setState(() {
                    _selectedMenu = 'agendar';
                  });
                },
              ),
            ],
          );
        }
      },
    );
  }
}
