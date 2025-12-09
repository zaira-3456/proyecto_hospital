// Modelo de datos para la estructura Firebase

// ============================================
// ENUMS
// ============================================

enum TipoCita {
  consultaGeneral,
  especialidad,
  seguimiento;

  String get displayName {
    switch (this) {
      case TipoCita.consultaGeneral:
        return 'Consulta General';
      case TipoCita.especialidad:
        return 'Especialidad';
      case TipoCita.seguimiento:
        return 'Seguimiento';
    }
  }

  static TipoCita fromString(String value) {
    switch (value) {
      case 'Consulta General':
        return TipoCita.consultaGeneral;
      case 'Especialidad':
        return TipoCita.especialidad;
      case 'Seguimiento':
        return TipoCita.seguimiento;
      default:
        return TipoCita.consultaGeneral;
    }
  }
}

enum EstadoCita {
  confirmada,
  cancelada;

  String get displayName {
    switch (this) {
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoCita fromString(String value) {
    switch (value) {
      case 'Confirmada':
        return EstadoCita.confirmada;
      case 'Cancelada':
        return EstadoCita.cancelada;
      default:
        return EstadoCita.confirmada;
    }
  }
}

// ============================================
// MODELOS
// ============================================

class Area {
  final String id;
  final String nombre;

  Area({required this.id, required this.nombre});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(id: json['id'] as String, nombre: json['nombre'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}

class Doctor {
  final String id;
  final String nombre;
  final String areaId;
  final Map<String, List<String>> disponibilidad;

  Doctor({
    required this.id,
    required this.nombre,
    required this.areaId,
    required this.disponibilidad,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      areaId: json['areaId'] as String,
      disponibilidad: Map<String, List<String>>.from(
        (json['disponibilidad'] as Map).map(
          (key, value) =>
              MapEntry(key as String, List<String>.from(value as List)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'areaId': areaId,
      'disponibilidad': disponibilidad,
    };
  }
}

class DisponibilidadDia {
  final DateTime fecha;
  final int citasDisponibles;
  final int citasOcupadas;
  final int citasTotal;

  DisponibilidadDia({
    required this.fecha,
    required this.citasDisponibles,
    required this.citasOcupadas,
    required this.citasTotal,
  });

  EstadoDisponibilidad get estado {
    double porcentajeOcupado = citasOcupadas / citasTotal;
    if (porcentajeOcupado >= 0.9) return EstadoDisponibilidad.muyOcupado;
    if (porcentajeOcupado >= 0.5)
      return EstadoDisponibilidad.medianamenteOcupado;
    return EstadoDisponibilidad.disponible;
  }

  factory DisponibilidadDia.fromJson(Map<String, dynamic> json) {
    return DisponibilidadDia(
      fecha: DateTime.parse(json['fecha'] as String),
      citasDisponibles: json['citasDisponibles'] as int,
      citasOcupadas: json['citasOcupadas'] as int,
      citasTotal: json['citasTotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'citasDisponibles': citasDisponibles,
      'citasOcupadas': citasOcupadas,
      'citasTotal': citasTotal,
    };
  }
}

enum EstadoDisponibilidad { disponible, medianamenteOcupado, muyOcupado }

// ============================================
// MODELO PACIENTE
// ============================================

class Paciente {
  final String id;
  final String nombre;
  final String telefono;
  final String? nss;
  final String? curp;
  final String? correo;

  Paciente({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.nss,
    this.curp,
    this.correo,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String,
      nss: json['nss'] as String?,
      curp: json['curp'] as String?,
      correo: json['correo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'nss': nss,
      'curp': curp,
      'correo': correo,
    };
  }
}

// ============================================
// MODELO CITA
// ============================================

class Cita {
  final String id;
  final Paciente paciente;
  final Doctor doctor;
  final DateTime fecha;
  final String hora;
  final TipoCita tipo;
  final EstadoCita estado;
  final DateTime createdAt;

  Cita({
    required this.id,
    required this.paciente,
    required this.doctor,
    required this.fecha,
    required this.hora,
    required this.tipo,
    required this.estado,
    required this.createdAt,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] as String,
      paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      fecha: DateTime.parse(json['fecha'] as String),
      hora: json['hora'] as String,
      tipo: TipoCita.values.firstWhere(
        (e) => e.toString() == json['tipo'],
        orElse: () => TipoCita.consultaGeneral,
      ),
      estado: EstadoCita.values.firstWhere(
        (e) => e.toString() == json['estado'],
        orElse: () => EstadoCita.confirmada,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': paciente.toJson(),
      'doctor': doctor.toJson(),
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'tipo': tipo.toString(),
      'estado': estado.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Cita copyWith({
    String? id,
    Paciente? paciente,
    Doctor? doctor,
    DateTime? fecha,
    String? hora,
    TipoCita? tipo,
    EstadoCita? estado,
    DateTime? createdAt,
  }) {
    return Cita(
      id: id ?? this.id,
      paciente: paciente ?? this.paciente,
      doctor: doctor ?? this.doctor,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
