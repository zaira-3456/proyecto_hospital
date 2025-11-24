import 'package:flutter/material.dart';

class FinanceStatCard extends StatelessWidget {
  final String titulo;
  final double valor;
  final double variacion; 
  final Color color;

  const FinanceStatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.variacion,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool positivo = variacion >= 0;

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),

      /// 🎨 ESTILO IGUAL A F I G M A
      decoration: BoxDecoration(
        color: const Color(0xffe5f3ff), // Fondo azul suave
        borderRadius: BorderRadius.circular(5),

        /// SOMBRA SUAVE
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],

        /// Borde ligero
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TÍTULO
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff32465a),
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 10),

          /// VALOR PRINCIPAL
          Text(
            "\$${valor.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          /// VARIACIÓN
          if (variacion != 0)
            Text(
              "${positivo ? '+' : ''}${variacion.toStringAsFixed(1)}% vs mes anterior",
              style: TextStyle(
                fontSize: 13,
                color: positivo ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
