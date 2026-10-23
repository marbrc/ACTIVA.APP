import '../../modelos/comunicacion.dart';
import '../../modelos/enums.dart';
import 'datos_simulados.dart';

DateTime _hace(int minutos) =>
    DateTime.now().subtract(Duration(minutes: minutos));

// {tallerId: mensajes}
final chatsSimulado = <int, List<MensajeChat>>{
  1: [
    MensajeChat(
      id: 1,
      tallerId: 1,
      rol: Rol.instructor,
      autor: instructorSimulado.nombreCompleto,
      texto: 'Buenas tardes equipo 🏐 Recuerden traer ropa deportiva y agua.',
      fecha: _hace(300),
    ),
    MensajeChat(
      id: 2,
      tallerId: 1,
      rol: Rol.alumno,
      autor: 'Ana Sofía Ramírez',
      texto: '¡Va profe! ¿Mañana sí hay práctica?',
      fecha: _hace(280),
    ),
    MensajeChat(
      id: 3,
      tallerId: 1,
      rol: Rol.instructor,
      autor: instructorSimulado.nombreCompleto,
      texto: 'Sí, a las 5:00 pm en el Gimnasio-Auditorio.',
      fecha: _hace(270),
    ),
  ],
  3: [
    MensajeChat(
      id: 4,
      tallerId: 3,
      rol: Rol.alumno,
      autor: 'Karla Morales',
      texto: 'Chicas y chicos, ¿alguien tiene el vestuario del ensayo?',
      fecha: _hace(600),
    ),
  ],
};

final encuestasSimulado = <RespuestaEncuesta>[
  RespuestaEncuesta(
    id: 1,
    tallerId: 1,
    numeroControl: '1225100412',
    califClub: 5,
    califInstructor: 5,
    comentario: 'Muy buen ambiente y el profe explica excelente.',
    fecha: _hace(2000),
  ),
  RespuestaEncuesta(
    id: 2,
    tallerId: 1,
    numeroControl: '1225100455',
    califClub: 4,
    califInstructor: 5,
    fecha: _hace(1900),
  ),
  RespuestaEncuesta(
    id: 3,
    tallerId: 1,
    numeroControl: '1225100291',
    califClub: 5,
    califInstructor: 4,
    comentario: 'Me gustaría que hubiera más sesiones por semana.',
    fecha: _hace(1800),
  ),
  RespuestaEncuesta(
    id: 4,
    tallerId: 2,
    numeroControl: '1225100367',
    califClub: 3,
    califInstructor: 3,
    comentario: 'Falta organización en los horarios de cancha.',
    fecha: _hace(1700),
  ),
  RespuestaEncuesta(
    id: 5,
    tallerId: 3,
    numeroControl: '1225100324',
    califClub: 5,
    califInstructor: 5,
    comentario: 'Me encantó, muy divertido.',
    fecha: _hace(1600),
  ),
  RespuestaEncuesta(
    id: 6,
    tallerId: 4,
    numeroControl: '1225100498',
    califClub: 4,
    califInstructor: 4,
    fecha: _hace(1500),
  ),
];

final solicitudesSimulado = <SolicitudAdmin>[
  SolicitudAdmin(
    id: 2,
    tallerId: 1,
    instructorId: instructorSimulado.id,
    instructorNombre: instructorSimulado.nombreCompleto,
    tipo: TipoSolicitud.bajaAlumno,
    mensaje: 'Un alumno se dio de baja, ya hay un lugar disponible.',
    fecha: _hace(180),
  ),
  SolicitudAdmin(
    id: 1,
    tallerId: 1,
    instructorId: instructorSimulado.id,
    instructorNombre: instructorSimulado.nombreCompleto,
    tipo: TipoSolicitud.clubLleno,
    mensaje: 'Ya hay lista de espera.',
    fecha: _hace(4000),
    estado: EstadoSolicitud.atendida,
  ),
];