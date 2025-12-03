import 'package:flutter/material.dart';
import '../widgets/dashboard_personal/agregar_personal_screen.dart';

// Database Service
import '../../login/services/database_service.dart';

/// ===========================================================
///                    MODELOS (LISTOS PARA BD)
/// ===========================================================

class PersonalStats {
  final int total;
  final int enfermeros;
  final int medicos;
  final int administrativos;

  PersonalStats({
    required this.total,
    required this.enfermeros,
    required this.medicos,
    required this.administrativos,
  });

  factory PersonalStats.fromMap(Map<String, int> map) {
    return PersonalStats(
      total: map['total'] ?? 0,
      enfermeros: map['enfermeros'] ?? 0,
      medicos: map['medicos'] ?? 0,
      administrativos: map['administrativos'] ?? 0,
    );
  }
}

class PersonalEmpleado {
  final String nombre;
  final String puesto;
  final String turno;
  final String estado;

  PersonalEmpleado({
    required this.nombre,
    required this.puesto,
    required this.turno,
    required this.estado,
  });

  factory PersonalEmpleado.fromMap(Map<String, dynamic> map) {
    return PersonalEmpleado(
      nombre: map['nombre'] ?? '',
      puesto: map['puesto'] ?? '',
      turno: map['turno'] ?? '',
      estado: map['estado'] ?? '',
    );
  }
}

/// ===========================================================
///                      PANTALLA PRINCIPAL
/// ===========================================================

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  final _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _dbService.getPersonnelByType(),
        _dbService.getPersonnelList(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.blue));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text('No hay datos disponibles'),
          );
        }

        final statsMap = snapshot.data![0] as Map<String, int>;
        final personalList = snapshot.data![1] as List<Map<String, dynamic>>;

        final stats = PersonalStats.fromMap(statsMap);
        final empleados = personalList
            .map((e) => PersonalEmpleado.fromMap(e))
            .toList();

        final width = MediaQuery.of(context).size.width;
        final bool isSmall = width < 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Gestión de Personal",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 30),

              /// ==================================================
              ///       TARJETAS SUPERIORES  (RESPONSIVAS)
              /// ==================================================
              if (isSmall)
                Column(
                  children: [
                    _statCard("Total Personal", stats.total, Icons.groups),
                    const SizedBox(height: 15),
                    _statCard("Enfermeros", stats.enfermeros,
                        Icons.monitor_heart_outlined),
                    const SizedBox(height: 15),
                    _statCard("Médicos", stats.medicos,
                        Icons.medical_services_outlined),
                    const SizedBox(height: 15),
                    _statCard("Administrativos", stats.administrativos,
                        Icons.person_outline),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            "Total Personal", stats.total, Icons.groups)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _statCard("Enfermeros", stats.enfermeros,
                            Icons.monitor_heart_outlined)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _statCard("Médicos", stats.medicos,
                            Icons.medical_services_outlined)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _statCard("Administrativos",
                            stats.administrativos, Icons.person_outline)),
                  ],
                ),

              const SizedBox(height: 30),

              /// ==================================================
              ///     BOTÓN AGREGAR PERSONAL
              /// ==================================================
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AgregarPersonalScreen()),
                  ).then((_) {
                    // Refresh data after returning from add screen
                    setState(() {});
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0), 
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "+ Agregar Personal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 30),

              /// ==================================================
              ///              TABLA DE PERSONAL
              /// ==================================================
              _headerTable(),
              _dataTable(empleados),
            ],
          ),
        );
      },
    );
  }

  /// ================================================================
  ///               TARJETA (Preparada para BD)
  /// ================================================================
    /// ================================================================
  ///               TARJETA (Nuevo estilo igual al dashboard)
  /// ================================================================
 Widget _statCard(String title, int value, IconData icon) {
final iconBg = {
  "Total Personal": const Color(0xff0079C1),      // Azul EXACTO
  "Enfermeros": const Color(0xffB00000),          // Rojo EXACTO
  "Médicos": const Color(0xff8C4BAF),             // Morado EXACTO
  "Administrativos": const Color(0xff000000),     // Negro EXACTO
}[title] ?? const Color(0xff0079C1);


  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
    decoration: BoxDecoration(
      color: const Color(0xffe5f3ff),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.black.withOpacity(0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        /// TEXTOS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff32465a),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "$value",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d1b2a),
                ),
              ),
            ],
          ),
        ),

        /// ÍCONO A LA DERECHA — MÁS BRILLANTE
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBg.withOpacity(0.40),  // AUMENTAMOS OPACIDAD
            boxShadow: [
              BoxShadow(
                color: iconBg.withOpacity(0.35), // SOMBRA MÁS REALISTA
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 28,
            color: iconBg,   // ÍCONO FUERTE
          ),
        ),
      ],
    ),
  );
}



  /// ================================================================
  ///                     HEADER TABLA
  /// ================================================================
  Widget _headerTable() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xffc0e6ff),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("Nombre", style: _headerStyle)),
          Expanded(flex: 2, child: Text("Puesto", style: _headerStyle)),
          Expanded(flex: 2, child: Text("Turno", style: _headerStyle)),
          Expanded(flex: 2, child: Text("Estado", style: _headerStyle)),
        ],
      ),
    );
  }

  /// ================================================================
  ///                     TABLA COMPLETA
  /// ================================================================
  Widget _dataTable(List<PersonalEmpleado> empleados) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: empleados.map((e) => _rowItem(e)).toList(),
      ),
    );
  }

  /// ================================================================
  ///                     FILA DE LA TABLA
  /// ================================================================
  Widget _rowItem(PersonalEmpleado emp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffe6e6e6)))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(emp.nombre)),
          Expanded(flex: 2, child: Text(emp.puesto)),
          Expanded(flex: 2, child: Text(emp.turno)),
          Expanded(flex: 2, child: _estadoBadge(emp.estado)),
        ],
      ),
    );
  }

  Widget _estadoBadge(String estado) {
    final activo = estado == "Activo";

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: activo ? const Color(0xffa7eacb) : const Color(0xffffd28c),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}

const TextStyle _headerStyle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 17);
