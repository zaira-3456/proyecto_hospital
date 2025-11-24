// archivo: receptionist_dashboard.dart

import 'package:flutter/material.dart';
import 'widgets/actions_recepcionist.dart';
import 'widgets/side_menu_recepcionist.dart';
import 'registrar_paciente.dart';

class ReceptionistDashboard extends StatelessWidget {
  const ReceptionistDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          
          // BREAKPOINTS RESPONSIVOS
          bool isMobile = width < 900; 
          bool isTablet = width >= 900 && width < 1280; 
          bool isDesktop = width >= 1280;
          return Row(
            children: [
              if (!isMobile) const SideMenuReception(),
              
              // ÁREA DE CONTENIDO PRINCIPAL
              Expanded( 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER DESKTOP/TABLET =====
                    if (!isMobile) 
                      Container(
                        padding: const EdgeInsets.only( 
                          left: 10, 
                          right: 80,
                          top: 20, 
                          bottom: 0, 
                        ),
                        child: Row( 
                          children: [
                            const Text( 
                              "Panel Recepcionista",
                              style: TextStyle( 
                                fontFamily: 'Archivo',
                                fontSize: 40, 
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const Spacer(), // Empuja el logo a la derecha

                            // LOGO 50x50
                            SizedBox( 
                              width: 50, 
                              height: 50,
                              child: Image.asset( 
                                "assets/images/logo.png",
                                fit: BoxFit.contain, 
                                errorBuilder: (context, error, stackTrace) { 
                                  return Container( 
                                    decoration: BoxDecoration( 
                                      border: Border.all(color: Colors.grey), 
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.image, size: 30), 
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ===== HEADER MÓVIL =====
                    if (isMobile) 
                      Container( 
                        padding: const EdgeInsets.symmetric( 
                            horizontal: 20, // 20px a los lados
                            vertical: 15 // 15px arriba y abajo
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
                            const SizedBox(width: 10), // Espacio entre ícono y texto
                            const Expanded( 
                              child: Text( 
                                "Panel Recepcionista",
                                style: TextStyle( 
                                  fontFamily: 'Archivo', 
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600, 
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ===== TEXTO "BIENVENIDO" =====
                    Padding( 
                      padding: EdgeInsets.only( 
                        left: 10,
                        right: isMobile ? 20 : 40, 
                        top: 10,
                      ),
                      child: Text( 
                        "Bienvenido de nuevo, Wendy",
                        style: TextStyle( 
                          fontFamily: 'Archivo', 
                          fontSize: isMobile ? 20 : 32, // MÓVIL: 20px, DESKTOP/TABLET: 32px
                          fontWeight: FontWeight.w400, 
                          color: Colors.black87, 
                        ),
                      ),
                    ),


                    // ===== CONTENEDOR PARA TARJETAS (ESPACIO RESTANTE) =====
                    Expanded(
                      child: Center( 
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 20 : 30),
                          child: _buildActionCards(context, isMobile, isTablet, isDesktop, width), 
                        ),
                      ),
                    ),
                  ],
                ),
              )
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

  // ===== CONSTRUCCIÓN DE TARJETAS =====
  Widget _buildActionCards(BuildContext context, bool isMobile, bool isTablet, bool isDesktop, double width) { 
    
    // CALCULAR ANCHO DISPONIBLE PARA LAS TARJETAS
    double availableWidth = isMobile 
        ? width - 40 
        : width - 360 - 60;
    
    // CALCULAR TAMAÑO DE TARJETAS
    double cardWidth;
    double cardHeight = 200;
    
    if (isMobile) { 
      // ===== MÓVIL: TARJETAS APILADAS VERTICALMENTE =====
      cardWidth = availableWidth; 
      if (cardWidth > 500) cardWidth = 500; 
      
      return Column( 
        mainAxisSize: MainAxisSize.min, 
        children: [
          ActionCard( // Primera tarjeta
            icon: Icons.person_add_alt_1, 
            text: "Registrar\npaciente",
            width: cardWidth,
            height: cardHeight, 
            onTap: () { 
              Navigator.push(context, // Navega a la pantalla de registro
                MaterialPageRoute(
                  builder: (context) => RegistroPacientePage(
                    returnRoute: const ReceptionistDashboard(),
                  )
                )
              );
            }, 
          ),
          const SizedBox(height: 25), 
          ActionCard( // Segunda tarjeta
            icon: Icons.medical_information_outlined, 
            text: "Agendar\ncita", 
            width: cardWidth, 
            height: cardHeight,
            onTap: () {}, // Acción al presionar (vacía por ahora)
          ),
        ],
      );
    } else if (isTablet) {
      // ===== TABLET: TARJETAS APILADAS VERTICALMENTE =====
      cardWidth = availableWidth; 
      if (cardWidth > 600) cardWidth = 600; 
      
      return Column(
        mainAxisSize: MainAxisSize.min, // Solo ocupa el espacio necesario
        children: [
          ActionCard( 
            icon: Icons.person_add_alt_1,
            text: "Registrar\npaciente",
            width: cardWidth,
            height: cardHeight, 
            onTap: () { 
              Navigator.push(context, // Navega a la pantalla de registro
                MaterialPageRoute(
                  builder: (context) => RegistroPacientePage(
                    returnRoute: const ReceptionistDashboard(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 25), // Espacio de 25px entre tarjetas verticales
          ActionCard( // Segunda tarjeta
            icon: Icons.medical_information_outlined,
            text: "Agendar\ncita",
            width: cardWidth, 
            height: cardHeight, 
            onTap: () {}, // Acción al presionar (vacía por ahora)
          ),
        ],
      );
    } else {
      // ===== DESKTOP: TARJETAS EN FILA HORIZONTAL =====
      cardWidth = (availableWidth - 60) / 2; 
      if (cardWidth > 400) cardWidth = 400; 
      
      return Wrap(
        spacing: 60,
        runSpacing: 10,
        alignment: WrapAlignment.center, // Centra las tarjetas
        children: [
          ActionCard( // Primera tarjeta
            icon: Icons.person_add_alt_1,
            text: "Registrar\npaciente",
            width: cardWidth, // Ancho calculado
            height: 200, // Alto fijo
            onTap: () { 
              Navigator.push(context, // Navega a la pantalla de registro
                MaterialPageRoute(
                  builder: (context) => RegistroPacientePage(
                    returnRoute: const ReceptionistDashboard(),
                  ),
                ),
              );
            },
          ),
          ActionCard( // Segunda tarjeta
            icon: Icons.medical_information_outlined,
            text: "Agendar\ncita",
            width: cardWidth, 
            height: 200,
            onTap: () {}, 
          ),
        ],
      );
    }
  }
}