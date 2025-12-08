import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/diseno_laboratorio.dart';
import '../login/services/database_service.dart';

class LaboratoryRequestsScreen extends StatefulWidget {
  const LaboratoryRequestsScreen({super.key});

  @override
  State<LaboratoryRequestsScreen> createState() => _LaboratoryRequestsScreenState();
}

class _LaboratoryRequestsScreenState extends State<LaboratoryRequestsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];
  String _filterEstado = 'todos'; // todos | pendiente | en_proceso | completado

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseService();
    final requests = _filterEstado == 'todos'
        ? await db.getStudyRequests()
        : await db.getStudyRequests(estado: _filterEstado);
    
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return kLYellow;
      case 'en_proceso':
        return kLOrange;
      case 'completado':
        return kLPrimaryBlue;
      default:
        return kLGreyText;
    }
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'completado':
        return 'Completado';
      default:
        return estado;
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
                      'Solicitudes de Estudios',
                      style: GoogleFonts.archivo(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestiona las solicitudes de estudios clínicos',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        color: kLGreyText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRequests,
                  tooltip: 'Recargar',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _filterEstado == 'todos',
                  onTap: () {
                    setState(() => _filterEstado = 'todos');
                    _loadRequests();
                  },
                ),
                _FilterChip(
                  label: 'Pendientes',
                  selected: _filterEstado == 'pendiente',
                  onTap: () {
                    setState(() => _filterEstado = 'pendiente');
                    _loadRequests();
                  },
                ),
                _FilterChip(
                  label: 'En Proceso',
                  selected: _filterEstado == 'en_proceso',
                  onTap: () {
                    setState(() => _filterEstado = 'en_proceso');
                    _loadRequests();
                  },
                ),
                _FilterChip(
                  label: 'Completados',
                  selected: _filterEstado == 'completado',
                  onTap: () {
                    setState(() => _filterEstado = 'completado');
                    _loadRequests();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_requests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: kLGreyText),
                      const SizedBox(height: 16),
                      Text(
                        'No hay solicitudes',
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
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RequestCard(
                      request: request,
                      onTap: () => _showRequestDetails(request),
                      estadoColor: _getEstadoColor(request['estado'] ?? ''),
                      estadoText: _getEstadoText(request['estado'] ?? ''),
                      fechaSolicitud: _formatDate(request['fechaSolicitud']),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (_) => _RequestDetailsDialog(
        request: request,
        onStatusChanged: _loadRequests,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kLPrimaryBlue : kLWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kLPrimaryBlue : kLGreyBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.archivoNarrow(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? kLWhite : kLBlack,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;
  final Color estadoColor;
  final String estadoText;
  final String fechaSolicitud;

  const _RequestCard({
    required this.request,
    required this.onTap,
    required this.estadoColor,
    required this.estadoText,
    required this.fechaSolicitud,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
                      const SizedBox(height: 4),
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
                    color: estadoColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estadoText,
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: estadoColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: kLGreyText),
                const SizedBox(width: 6),
                Text(
                  'Dr. ${request['medicoNombre'] ?? 'Desconocido'}',
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 13,
                    color: kLGreyText,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: kLGreyText),
                const SizedBox(width: 6),
                Text(
                  fechaSolicitud,
                  style: GoogleFonts.archivoNarrow(
                    fontSize: 13,
                    color: kLGreyText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(request['prioridad']).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request['prioridad'] ?? 'normal',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(request['prioridad']),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'urgente':
        return kLRed;
      case 'alta':
        return kLOrange;
      case 'baja':
        return kLPrimaryBlue;
      default:
        return kLGreyText;
    }
  }
}

class _RequestDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onStatusChanged;

  const _RequestDetailsDialog({
    required this.request,
    required this.onStatusChanged,
  });

  @override
  State<_RequestDetailsDialog> createState() => _RequestDetailsDialogState();
}

class _RequestDetailsDialogState extends State<_RequestDetailsDialog> {
  String? _selectedStatus;
  final _observacionesController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.request['estado'];
    _observacionesController.text = widget.request['observaciones'] ?? '';
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;

    setState(() => _isUpdating = true);

    try {
      final db = DatabaseService();
      final success = await db.updateStudyStatus(
        requestId: widget.request['id'],
        nuevoEstado: _selectedStatus!,
        observaciones: _observacionesController.text.isEmpty 
            ? null 
            : _observacionesController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estado actualizado exitosamente',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kLPrimaryBlue,
          ),
        );
        Navigator.pop(context);
        widget.onStatusChanged();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar estado',
              style: GoogleFonts.archivoNarrow(),
            ),
            backgroundColor: kLRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: GoogleFonts.archivoNarrow(),
          ),
          backgroundColor: kLRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de Solicitud',
              style: GoogleFonts.archivo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            _DetailRow('Paciente:', widget.request['pacienteNombre'] ?? 'N/A'),
            _DetailRow('Médico:', widget.request['medicoNombre'] ?? 'N/A'),
            _DetailRow('Tipo de Estudio:', widget.request['tipoEstudio'] ?? 'N/A'),
            _DetailRow('Prioridad:', widget.request['prioridad'] ?? 'N/A'),
            
            if (widget.request['notas'] !=null && widget.request['notas'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notas:',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.request['notas'],
                style: GoogleFonts.archivoNarrow(fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            Text(
              'Actualizar Estado',
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'en_proceso', child: Text('En Proceso')),
                DropdownMenuItem(value: 'completado', child: Text('Completado')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
            
            const SizedBox(height: 16),
            Text(
              'Observaciones',
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observacionesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Observaciones adicionales...',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kLPrimaryBlue,
                    foregroundColor: kLWhite,
                  ),
                  onPressed: _isUpdating ? null : _updateStatus,
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Actualizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.archivoNarrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.archivoNarrow(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
