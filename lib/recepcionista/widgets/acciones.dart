import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final double width;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.text,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xffe7f3ff),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: Colors.black87),
              const SizedBox(width: 15),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}