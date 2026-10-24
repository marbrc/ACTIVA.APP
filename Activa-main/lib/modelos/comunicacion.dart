import 'enums.dart';

class MensajeChat {
  final int id;
  final int tallerId;
  final Rol rol;
  final String autor;
  final String texto;
  final DateTime fecha;
  const MensajeChat({
    required this.id,
    required this.tallerId,
    required this.rol,
    required this.autor,
    required this.texto,
    required this.fecha,
  });
}

class RespuestaEncuesta {
  final int id;
  final int tallerId;
  final String numeroControl;
  final int califClub;
  final int califInstructor;
  final String comentario;
  final DateTime fecha;
  const RespuestaEncuesta({
    required this.id,
    required this.tallerId,
    required this.numeroControl,
    required this.califClub,
    required this.califInstructor,
    this.comentario = '',
    required this.fecha,
  });
}

enum TipoSolicitud { clubLleno, ampliarCupo, bajaAlumno, otro }

extension TipoSolicitudX on TipoSolicitud {
  String get etiqueta => switch (this) {
    TipoSolicitud.clubLleno => 'El club ya se llenó',
    TipoSolicitud.ampliarCupo => 'Necesito más lugares',
    TipoSolicitud.bajaAlumno => 'Un alumno se dio de baja',
    TipoSolicitud.otro => 'Otro motivo',
  };
}

enum EstadoSolicitud { pendiente, atendida, rechazada }

class SolicitudAdmin {
  final int id;
  final int tallerId;
  final int instructorId;
  final String instructorNombre;
  final TipoSolicitud tipo;
  final String mensaje;
  final DateTime fecha;
  final EstadoSolicitud estado;
  final String respuesta; // lo que contesta el admin
  final int cupoExtra; // lugares que agregó el admin
  const SolicitudAdmin({
    required this.id,
    required this.tallerId,
    required this.instructorId,
    required this.instructorNombre,
    required this.tipo,
    this.mensaje = '',
    required this.fecha,
    this.estado = EstadoSolicitud.pendiente,
    this.respuesta = '',
    this.cupoExtra = 0,
  });

  SolicitudAdmin copyWith({EstadoSolicitud? estado, String? respuesta, int? cupoExtra}) =>
      SolicitudAdmin(
        id: id,
        tallerId: tallerId,
        instructorId: instructorId,
        instructorNombre: instructorNombre,
        tipo: tipo,
        mensaje: mensaje,
        fecha: fecha,
        estado: estado ?? this.estado,
        respuesta: respuesta ?? this.respuesta,
        cupoExtra: cupoExtra ?? this.cupoExtra,
      );
}