import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/diseno_laboratorio.dart';
import 'solicitudes_laboratorio.dart';
import 'resultados_laboratorio.dart';


class LaboratoryDashboardScreen extends StatefulWidget {
  const LaboratoryDashboardScreen({super.key});

  @override
  State<LaboratoryDashboardScreen> createState() => _LaboratoryDashboardScreenState();
}

class _LaboratoryDashboardScreenState extends State<LaboratoryDashboardScreen> {
  bool _isLoading = true;
  int _totalRequests = 0;
  int _pendingRequests = 0;
  int _inProgressRequests = 0;
  int _completedRequests = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // TODO: Load actual stats from Firebase when ready
      // For now, just stop loading to show the UI
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Mock data for now
          _totalRequests = 0;
          _pendingRequests = 0;
          _inProgressRequests = 0;
          _completedRequests = 0;
        });
      }
    } catch (e) {
      print('❌ Error cargando estadísticas de laboratorio: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLBgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Control',
            style: GoogleFonts.archivo(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gestión de solicitudes y resultados de estudios clínicos',
            style: GoogleFonts.archivoNarrow(
              fontSize: 15,
              color: kLGreyText,
            ),
          ),
          const SizedBox(height: 32),

          // Stats cards
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _StatCard(
                  title: 'Total Solicitudes',
                  value: '$_totalRequests',
                  icon: Icons.assignment,
                  color: kLPrimaryBlue,
                ),
                _StatCard(
                  title: 'Pendientes',
                  value: '$_pendingRequests',
                  icon: Icons.pending_actions,
                  color: kLYellow,
                ),
                _StatCard(
                  title: 'En Proceso',
                  value: '$_inProgressRequests',
                  icon: Icons.hourglass_empty,
                  color: kLOrange,
                ),
                _StatCard(
                  title: 'Completados',
                  value: '$_completedRequests',
                  icon: Icons.check_circle,
                  color: kLGreenBright,
                ),
              ],
            ),

          const SizedBox(height: 40),

          // Quick actions
          Text(
            'Accesos Rápidos',
            style: GoogleFonts.archivo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _QuickActionButton(
                icon: Icons.assignment_outlined,
                label: 'Ver Solicitudes',
                color: kLPrimaryBlue,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LaboratoryRequestsScreen(),
                    ),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.upload_file,
                label: 'Cargar Resultados',
                color: kLPrimaryBlue,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LaboratoryResultsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kLWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.archivoNarrow(
              fontSize: 14,
              color: kLGreyText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.archivo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kLBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kLBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
