import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    this.iconColor = Colors.white,
    this.iconBgColor = const Color(0xff4da3ff),
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 450;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),

      /// 🎨 ESTILO F I G M A
      decoration: BoxDecoration(
        color: const Color(0xffe5f3ff), // azul clarito Figma
        borderRadius: BorderRadius.circular(5),

        /// SOMBRA SUAVE COMO FIGMA
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],

        /// BORDE SUAVECITO
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === FILA SUPERIOR (TEXTO + ÍCONO A LA DERECHA) ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff32465a),
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isSmall ? 26 : 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff0d1b2a),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // === ÍCONO REDONDO (BAJADO UN POCO) ===
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBgColor.withOpacity(0.9),

                    /// SOMBRA SUAVE DEL ICONO
                    boxShadow: [
                      BoxShadow(
                        color: iconBgColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: isSmall ? 22 : 26,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
