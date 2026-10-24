import 'dart:typed_data';

import 'categoria.dart';
import 'enums.dart';
import 'usuario.dart';

class Horario {
  final Dia dia;
  final String horaInicio; // "17:00"
  final String horaFin;
  const Horario(this.dia, this.horaInicio, this.horaFin);

  static int _m(String s) {
    final p = s.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  int get inicioMin => _m(horaInicio);
  int get finMin => _m(horaFin);
  int get minutos => finMin - inicioMin;

  // UML: validarTraslape()
  bool traslapaCon(Horario o) =>
      dia == o.dia && inicioMin < o.finMin && o.inicioMin < finMin;
}

class Taller {
  final int id;
  final String nombre;
  final String descripcion;
  final Categoria categoria;
  final String lugar;
  final int cupoMaximo;
  final int horasOtorga;
  final bool activo;
  final Instructor instructor;
  final List<Horario> horarios;
  final List<String> aprendizajes;
  final int inscritos; // en backend real se calcula contando inscripciones
  final Uint8List? foto; // foto elegida al crear la actividad

  const Taller({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.lugar,
    required this.cupoMaximo,
    this.horasOtorga = 60,
    this.activo = true,
    required this.instructor,
    required this.horarios,
    this.aprendizajes = const [],
    this.foto,
    required this.inscritos,
  });

  Taller copyWith({
    String? nombre,
    String? descripcion,
    Categoria? categoria,
    String? lugar,
    int? cupoMaximo,
    int? horasOtorga,
    bool? activo,
    Instructor? instructor,
    List<Horario>? horarios,
    List<String>? aprendizajes,
    Uint8List? foto,
    int? inscritos,
  }) => Taller(
    id: id,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    categoria: categoria ?? this.categoria,
    lugar: lugar ?? this.lugar,
    cupoMaximo: cupoMaximo ?? this.cupoMaximo,
    horasOtorga: horasOtorga ?? this.horasOtorga,
    activo: activo ?? this.activo,
    instructor: instructor ?? this.instructor,
    horarios: horarios ?? this.horarios,
    aprendizajes: aprendizajes ?? this.aprendizajes,
    foto: foto ?? this.foto,
    inscritos: inscritos ?? this.inscritos,
  );

  int get cuposDisponibles => cupoMaximo - inscritos;
  bool get hayCupo => cuposDisponibles > 0;

  // "Lun y Jue | 17:00 – 18:30"
  String get horarioTexto {
    final dias = horarios.map((h) => h.dia.corto).join(' y ');
    final h = horarios.first;
    return '$dias | ${h.horaInicio} – ${h.horaFin}';
  }

  // Horas que suma una sesión (el modelo guarda horas enteras: 1.5 h -> 2)
  int get horasPorSesion => (horarios.first.minutos / 60).round();

  Horario horarioDe(DateTime d) => horarios.firstWhere(
    (h) => h.dia.weekday == d.weekday,
    orElse: () => horarios.first,
  );

  // Fecha de la sesión más reciente (hoy o hacia atrás, máx. 7 días)
  DateTime sesionReciente([DateTime? desde]) {
    final hoy = desde ?? DateTime.now();
    final base = DateTime(hoy.year, hoy.month, hoy.day);
    for (var i = 0; i < 7; i++) {
      final d = base.subtract(Duration(days: i));
      if (horarios.any((h) => h.dia.weekday == d.weekday)) return d;
    }
    return base;
  }
}

class Actividad {
  final int id;
  final int tallerId;
  final String nombre;
  final DateTime fecha;
  final int horas;
  const Actividad({
    required this.id,
    required this.tallerId,
    required this.nombre,
    required this.fecha,
    required this.horas,
  });
}