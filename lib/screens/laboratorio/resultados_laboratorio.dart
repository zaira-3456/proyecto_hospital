import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/diseno_laboratorio.dart';
import '../login/services/database_service.dart';

class LaboratoryResultsScreen extends StatefulWidget {
  const LaboratoryResultsScreen({super.key});

  @override
  State<LaboratoryResultsScreen> createState() => _LaboratoryResultsScreenState();
}

class _LaboratoryResultsScreenState extends State<LaboratoryResultsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _completedRequests = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedRequests();
  }

  Future<void> _loadCompletedRequests() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseService();
    final requests = await db.getStudyRequests(estado: 'completado');
    
    if (mounted) {
      setState(() {
        _completedRequests = requests;
        _isLoading = false;
      });
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLBgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultados de Estudios',
                      style: GoogleFonts.archivo(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Historial de estudios completados',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        color: kLGreyText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCompletedRequests,
                  tooltip: 'Recargar',
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_completedRequests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: kLGreyText),
                      const SizedBox(height: 16),
                      Text(
                        'No hay estudios completados',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 16,
                          color: kLGreyText,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _completedRequests.length,
                itemBuilder: (context, index) {
                  final request = _completedRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ResultCard(
                      request: request,
                      fechaSolicitud: _formatDate(request['fechaSolicitud']),
                      fechaCompletado: _formatDate(request['fechaCompletado']),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String fechaSolicitud;
  final String fechaCompletado;

  const _ResultCard({
    required this.request,
    required this.fechaSolicitud,
    required this.fechaCompletado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kLGreyBorder.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kLPrimaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: kLPrimaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['pacienteNombre'] ?? 'Sin nombre',
                      style: GoogleFonts.archivo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request['tipoEstudio'] ?? 'Sin tipo',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        color: kLGreyText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kLPrimaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Completado',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kLPrimaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _InfoItem(
                icon: Icons.person_outline,
                label: 'Médico',
                value: request['medicoNombre'] ?? 'Desconocido',
              ),
              _InfoItem(
                icon: Icons.calendar_today,
                label: 'Solicitado',
                value: fechaSolicitud,
              ),
              _InfoItem(
                icon: Icons.event_available,
                label: 'Completado',
                value: fechaCompletado,
              ),
            ],
          ),
          if (request['observaciones'] != null && 
              request['observaciones'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes, size: 16, color: kLGreyText),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observaciones:',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kLGreyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['observaciones'],
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 13,
                          color: kLBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kLGreyText),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.archivoNarrow(
                fontSize: 11,
                color: kLGreyText,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.archivoNarrow(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: kLBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
