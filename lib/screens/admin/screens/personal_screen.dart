import 'package:flutter/material.dart';
import '../widgets/dashboard_personal/agregar_personal_screen.dart';
import '../widgets/dashboard_personal/edit_personal_dialog.dart';
import '../widgets/dashboard_personal/create_user_dialog.dart';

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
  final String id;
  final String nombre;
  final String puesto;
  final String turno;
  final String estado;
  final String area;
  final String tipo;
  final String? curp;
  final String? rfc;
  final String? genero;
  final String? telefono;
  final String? correo;
  final String? direccion;
  final DateTime? fechaNacimiento;

  PersonalEmpleado({
    required this.id,
    required this.nombre,
    required this.puesto,
    required this.turno,
    required this.estado,
    required this.area,
    required this.tipo,
    this.curp,
    this.rfc,
    this.genero,
    this.telefono,
    this.correo,
    this.direccion,
    this.fechaNacimiento,
  });

  factory PersonalEmpleado.fromMap(Map<String, dynamic> map) {
    return PersonalEmpleado(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      puesto: map['puesto'] ?? '',
      turno: map['turno'] ?? '',
      estado: map['estado'] ?? '',
      area: map['area'] ?? '',
      tipo: map['tipo'] ?? '',
      curp: map['curp'],
      rfc: map['rfc'],
      genero: map['genero'],
      telefono: map['telefono'],
      correo: map['correo'],
      direccion: map['direccion'],
      fechaNacimiento: map['fechaNacimiento'] != null
          ? (map['fechaNacimiento'] is DateTime
              ? map['fechaNacimiento']
              : DateTime.tryParse(map['fechaNacimiento'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'puesto': puesto,
      'turno': turno,
      'estado': estado,
      'area': area,
      'tipo': tipo,
      'curp': curp,
      'rfc': rfc,
      'genero': genero,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
      'fechaNacimiento': fechaNacimiento,
    };
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
              ///     BOTONES AGREGAR PERSONAL Y USUARIOS
              /// ==================================================
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
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
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateUserDialog(),
                        ),
                      ).then((result) {
                        // Refresh if user was created successfully
                        if (result == true) {
                          setState(() {});
                        }
                      });
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text(
                      "Crear Usuario del Sistema",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final useScroll = screenWidth < 800;
    
    Widget headerRow = Container(
      width: useScroll ? 800 : null,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xffc0e6ff),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (useScroll) ...[
            const SizedBox(width: 200, child: Text("Nombre", style: _headerStyle)),
            const SizedBox(width: 150, child: Text("Puesto", style: _headerStyle)),
            const SizedBox(width: 150, child: Text("Turno", style: _headerStyle)),
            const SizedBox(width: 150, child: Text("Estado", style: _headerStyle)),
            const SizedBox(width: 100, child: Text("Acciones", style: _headerStyle)),
          ] else ...[
            const Expanded(flex: 3, child: Text("Nombre", style: _headerStyle)),
            const Expanded(flex: 2, child: Text("Puesto", style: _headerStyle)),
            const Expanded(flex: 2, child: Text("Turno", style: _headerStyle)),
            const Expanded(flex: 2, child: Text("Estado", style: _headerStyle)),
            const SizedBox(width: 100, child: Text("Acciones", style: _headerStyle)),
          ],
        ],
      ),
    );
    
    if (useScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: headerRow,
      );
    }
    return headerRow;
  }

  /// ================================================================
  ///                     TABLA COMPLETA
  /// ================================================================
  Widget _dataTable(List<PersonalEmpleado> empleados) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useScroll = screenWidth < 800;
    
    Widget tableContent = Container(
      width: useScroll ? 800 : null,
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
        children: empleados.map((e) => _rowItem(e, useScroll)).toList(),
      ),
    );
    
    if (useScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: tableContent,
      );
    }
    return tableContent;
  }

  /// ================================================================
  ///                     FILA DE LA TABLA
  /// ================================================================
  Widget _rowItem(PersonalEmpleado emp, bool useFixedWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffe6e6e6)))),
      child: Row(
        children: [
          if (useFixedWidth) ...[
            SizedBox(width: 200, child: Text(emp.nombre)),
            SizedBox(width: 150, child: Text(emp.puesto)),
            SizedBox(width: 150, child: Text(emp.turno)),
            SizedBox(width: 150, child: _estadoBadge(emp.estado)),
          ] else ...[
            Expanded(flex: 3, child: Text(emp.nombre)),
            Expanded(flex: 2, child: Text(emp.puesto)),
            Expanded(flex: 2, child: Text(emp.turno)),
            Expanded(flex: 2, child: _estadoBadge(emp.estado)),
          ],
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar',
                  onPressed: () => _showEditDialog(emp),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar',
                  onPressed: () => _confirmDelete(emp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================================================================
  ///                     CONFIRMAR ELIMINACIÓN
  /// ================================================================
  void _confirmDelete(PersonalEmpleado emp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de eliminar a ${emp.nombre}?\n\nEsta acción también eliminará sus credenciales de acceso si existen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _deletePersonnel(emp);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  /// ================================================================
  ///                     ELIMINAR PERSONAL
  /// ================================================================
  Future<void> _deletePersonnel(PersonalEmpleado emp) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Eliminar personal
      final success = await _dbService.deletePersonnel(emp.id);

      // Intentar eliminar credenciales usando el nombre completo
      await _dbService.deleteUserCredentialsByName(emp.nombre);

      // Cerrar loading
      if (mounted) Navigator.pop(context);

      if (success) {
        // Mostrar éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${emp.nombre} eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh UI
          setState(() {});
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(PersonalEmpleado emp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPersonalDialog(
          personnel: {
            'id': emp.id,
            'nombre': emp.nombre,
            'puesto': emp.puesto,
            'area': emp.area,
            'turno': emp.turno,
            'estado': emp.estado,
          },
        );
      },
    ).then((result) {
      // Refresh data if the edit was successful
      if (result == true) {
        setState(() {});
      }
    });
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
