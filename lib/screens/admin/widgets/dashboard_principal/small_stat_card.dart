import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmallStatCard extends StatelessWidget {
  final String label;
  final String value;

  const SmallStatCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.archivo(fontSize: 16)),
          Text(value,
              style: GoogleFonts.archivo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
