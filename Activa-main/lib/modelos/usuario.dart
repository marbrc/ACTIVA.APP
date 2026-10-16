import 'enums.dart';

class Usuario {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String? telefono;
  final String? foto;
  final Rol rol;
  final bool activo;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    this.apellidoMaterno = '',
    required this.correo,
    this.telefono,
    this.foto,
    required this.rol,
    this.activo = true,
  });

  String get nombreCompleto =>
      '$nombre $apellidoPaterno $apellidoMaterno'.trim();
}

class Alumno extends Usuario {
  final String numeroControl;
  final String grupo;
  final String carrera;

  const Alumno({
    required super.id,
    required super.nombre,
    required super.apellidoPaterno,
    super.apellidoMaterno,
    required super.correo,
    super.telefono,
    super.foto,
    required this.numeroControl,
    required this.grupo,
    required this.carrera,
  }) : super(rol: Rol.alumno);

    Alumno copyWith({
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? telefono,
  }) =>
      Alumno(
        id: id,
        nombre: nombre ?? this.nombre,
        apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
        apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
        correo: correo,
        telefono: telefono ?? this.telefono,
        foto: foto,
        numeroControl: numeroControl,
        grupo: grupo,
        carrera: carrera,
      );
}



class Instructor extends Usuario {
  final String especialidad;

  const Instructor({
    required super.id,
    required super.nombre,
    required super.apellidoPaterno,
    super.apellidoMaterno,
    required super.correo,
    super.telefono,
    super.foto,
    required this.especialidad,
  }) : super(rol: Rol.instructor);
}

class Administrador extends Usuario {
  final String cargo;

  const Administrador({
    required super.id,
    required super.nombre,
    required super.apellidoPaterno,
    super.apellidoMaterno,
    required super.correo,
    required this.cargo,
  }) : super(rol: Rol.admin);
}