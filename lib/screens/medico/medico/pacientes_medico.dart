import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_medico.dart';
import '../../recepcionista/recepcionista/registrar_paciente.dart';
import '../../login/services/database_service.dart';

import 'widgets/diseno_medico.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  List<DoctorPatient> _patients = [];
  List<DoctorPatient> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final db = DatabaseService();
    final patientsData = await db.getPatients();

    final List<DoctorPatient> loadedPatients = [];

    for (var p in patientsData) {
      // Calcular edad
      int edad = 0;
      if (p['fechaNacimiento'] != null) {
        try {
          // Asumiendo formato dd/MM/yyyy o similar si es String, o Timestamp
          // En RegistroPacientePage se guarda como String dd/MM/yyyy
          final parts = (p['fechaNacimiento'] as String).split('/');
          if (parts.length == 3) {
            final birthDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            final now = DateTime.now();
            edad = now.year - birthDate.year;
            if (now.month < birthDate.month ||
                (now.month == birthDate.month && now.day < birthDate.day)) {
              edad--;
            }
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }

      loadedPatients.add(DoctorPatient(
        id: p['id'] ?? '',
        nombre: p['nombreCompleto'] ?? 'Sin nombre',
        sexo: p['genero'] ?? 'No especificado',
        edad: edad,
        telefono: p['telefono'] ?? '',
        email: p['correo'] ?? '',
        condicion: 'General', // Placeholder
        estado: 'Activo',
        fecha: 'Pendiente',
        hora: '--:--',
      ));
    }

    if (mounted) {
      setState(() {
        _patients = loadedPatients;
        _filteredPatients = loadedPatients;
        _isLoading = false;
      });
    }
  }

  void _filterPatients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPatients = _patients;
      });
    } else {
      setState(() {
        _filteredPatients = _patients
            .where((p) =>
                p.nombre.toLowerCase().contains(query.toLowerCase()) ||
                p.condicion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorLayout(
      selectedIndex: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gestión de Pacientes',
                          style: GoogleFonts.archivo(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const DoctorLogoCircle(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Información de tus pacientes',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 14,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Buscador + botón
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: kMLightBlue,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            height: 44,
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterPatients,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Buscar pacientes por nombre o condición..',
                                      hintStyle: GoogleFonts.archivoNarrow(
                                        fontSize: 14,
                                        color: kMGreyText,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMPrimaryBlue,
                              foregroundColor: kMWhite,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              textStyle: GoogleFonts.archivoNarrow(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegistroPacientePage(
                                    returnRoute: const DoctorDashboardScreen(),
                                  ),
                                ),
                              ).then((_) => _loadPatients()); // Reload after return
                            },
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text('Nuevo Paciente'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Lista de tarjetas de paciente
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_filteredPatients.isEmpty)
                      const Center(child: Text('No se encontraron pacientes.'))
                    else
                      Column(
                        children: _filteredPatients
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: _PatientCard(patient: p, compact: narrow),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final DoctorPatient patient;
  final bool compact;

  const _PatientCard({required this.patient, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kMLightBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: kMBlue15,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: kMWhite,
                  child: Icon(Icons.person, color: kMPrimaryBlue, size: 30),
                ),
              ),
              const SizedBox(width: 14),

              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nombre,
                      style: GoogleFonts.archivo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${patient.sexo}, ${patient.edad} años',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kMGreyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patient.email,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 13,
                        color: kMGreyText,
                      ),
                    ),
                  ],
                ),
              ),

              if (!compact) const SizedBox(width: 10),

              // Teléfono
              if (!compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: kMPrimaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          patient.telefono,
                          style: GoogleFonts.archivoNarrow(
                            fontSize: 13,
                            color: kMGreyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Línea inferior: condición + estado + próxima cita
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Condición: ',
                      style: GoogleFonts.archivoNarrow(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        patient.condicion,
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 13,
                          color: kMGreyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: patient.estado),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    patient.fecha,
                    style: GoogleFonts.archivoNarrow(fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    patient.hora,
                    style: GoogleFonts.archivoNarrow(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.more_vert, size: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (status == 'Activo') {
      bg = kMGreenBright;
    } else {
      bg = kMYellow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: GoogleFonts.archivoNarrow(fontSize: 12, color: kMBlack),
      ),
    );
  }
}

class DoctorPatient {
  final String id;
  final String nombre;
  final String sexo;
  final int edad;
  final String telefono;
  final String email;
  final String condicion;
  final String estado;
  final String fecha;
  final String hora;

  DoctorPatient({
    required this.id,
    required this.nombre,
    required this.sexo,
    required this.edad,
    required this.telefono,
    required this.email,
    required this.condicion,
    required this.estado,
    required this.fecha,
    required this.hora,
  });
}
