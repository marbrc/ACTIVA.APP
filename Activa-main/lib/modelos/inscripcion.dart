import 'enums.dart';
import 'taller.dart';
import 'usuario.dart';

class Inscripcion {
  final String folio; // VOL-2026-0381
  final Alumno alumno;
  final Taller taller;
  final EstadoInscripcion estado;
  final DateTime fechaInscripcion;

  const Inscripcion({
    required this.folio,
    required this.alumno,
    required this.taller,
    this.estado = EstadoInscripcion.activa,
    required this.fechaInscripcion,
  });
  Inscripcion copyWith({EstadoInscripcion? estado, Taller? taller}) =>
      Inscripcion(
        folio: folio,
        alumno: alumno,
        taller: taller ?? this.taller,
        estado: estado ?? this.estado,
        fechaInscripcion: fechaInscripcion,
      );
}

class Asistencia {
  final int id;
  final String folio; // FK a inscripción
  final int actividadId;
  final DateTime fecha;
  final bool presente;
  final int horas;
  const Asistencia({
    required this.id,
    required this.folio,
    required this.actividadId,
    required this.fecha,
    required this.presente,
    required this.horas,
  });
}

class Aviso {
  final int id;
  final int tallerId;
  final TipoAviso tipo;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  const Aviso({
    required this.id,
    required this.tallerId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
  });
}
