import '../../modelos/categoria.dart';
import '../../modelos/enums.dart' hide Categoria;
import '../../modelos/inscripcion.dart';
import '../../modelos/taller.dart';
import '../../modelos/usuario.dart';


Instructor _ins(int id, String nom, String pat, String mat, String esp) =>
    Instructor(
      id: id,
      nombre: nom,
      apellidoPaterno: pat,
      apellidoMaterno: mat,
      correo: 'instructor$id@utng.edu.mx',
      especialidad: esp,
    );

final alumnoSimulado = Alumno(
  id: 1,
  nombre: 'JOSE EMMANUEL',
  apellidoPaterno: 'GARCIA',
  apellidoMaterno: 'CALVILLO',
  correo: '1225100516@utng.edu.mx',
  telefono: '418 123 4567',
  numeroControl: '1225100516',
  grupo: 'GTID235',
  carrera: 'Ingeniería en Desarrollo de Software',
);

const adminSimulado = Administrador(
  id: 100,
  nombre: 'Coordinación',
  apellidoPaterno: 'de Paraescolares',
  correo: 'paraescolares@utng.edu.mx',
  cargo: 'Coordinador',
);

const catDeportes = Categoria(id: 1, clave: 'deportes', nombre: 'Deportes', etiqueta: 'Deportiva', colorValue: 0xFFE08A3C, icono: 'deportes');
const catCultura = Categoria(id: 2, clave: 'cultura', nombre: 'Cultura', etiqueta: 'Cultural', colorValue: 0xFFD1457B, icono: 'cultura');
const catRecreativa = Categoria(id: 3, clave: 'recreativa', nombre: 'Recreativa', etiqueta: 'Recreativa', colorValue: 0xFF6C4FD1, icono: 'recreativa');
const catOtros = Categoria(id: 4, clave: 'otros', nombre: 'Otros', etiqueta: 'Otra', colorValue: 0xFF3C8DE0, icono: 'otros');

const categoriasSimulado = [catDeportes, catCultura, catRecreativa, catOtros];

final talleresSimulado = <Taller>[
  
  Taller(
    id: 1,
    nombre: 'Voleibol',
    descripcion:
        'El voleibol fomenta el trabajo en equipo, la comunicación y la superación personal.',
    categoria:catDeportes,
    lugar: 'Gimnasio-Auditorio',  
    cupoMaximo: 24,
    inscritos: 18,
    instructor: instructorSimulado,
    horarios: const [
      Horario(Dia.lunes, '17:00', '18:30'),
      Horario(Dia.jueves, '17:00', '18:30'),
    ],
    aprendizajes: const ['Trabajo en equipo', 'Disciplina', 'Condición física', 'Diversión'],
  ),
  Taller(
    id: 2,
    nombre: 'Fútbol soccer',
    descripcion: 'Desarrolla resistencia, táctica y espíritu de equipo en la cancha principal.',
    categoria: catCultura,
    lugar: 'Cancha principal',
    cupoMaximo: 30,
    inscritos: 30,
    instructor: _ins(3, 'Eduardo', 'Gutiérrez', '', 'Fútbol soccer'),
    horarios: const [
      Horario(Dia.martes, '17:00', '18:30'),
      Horario(Dia.jueves, '17:00', '18:30'),
    ],
    aprendizajes: const ['Resistencia', 'Táctica', 'Trabajo en equipo', 'Diversión'],
  ),
  Taller(
    id: 3,
    nombre: 'Danza folclórica',
    descripcion: 'Explora las raíces culturales a través del movimiento y la tradición.',
    categoria: catCultura,
    lugar: 'Aula de Danza',
    cupoMaximo: 20,
    inscritos: 10,
    instructor: _ins(4, 'Laura', 'Hernández', 'Pérez', 'Danza folclórica'),
    horarios: const [
      Horario(Dia.martes, '16:00', '18:00'),
      Horario(Dia.jueves, '16:00', '18:00'),
    ],
    aprendizajes: const ['Tradición', 'Expresión artística', 'Coordinación', 'Diversión'],
  ),
  Taller(
    id: 4,
    nombre: 'Ajedrez',
    descripcion: 'Estrategia, paciencia y pensamiento crítico en un espacio de práctica constante.',
    categoria: catRecreativa,
    lugar: 'Sala de Usos Múltiples',
    cupoMaximo: 20,
    inscritos: 15,
    instructor: _ins(5, 'Carlos', 'Medina', '', 'Ajedrez'),
    horarios: const [
      Horario(Dia.martes, '15:00', '16:30'),
      Horario(Dia.viernes, '15:00', '16:30'),
    ],
    aprendizajes: const ['Estrategia', 'Concentración', 'Paciencia', 'Pensamiento crítico'],
  ),
  Taller(
    id: 5,
    nombre: 'Teatro',
    descripcion: 'Expresión escénica, improvisación y montaje de obras breves durante el cuatrimestre.',
    categoria:catRecreativa,
    lugar: 'Auditorio',
    cupoMaximo: 20,
    inscritos: 14,
    instructor: _ins(6, 'Noé', 'Castañeda', '', 'Teatro'),
    horarios: const [
      Horario(Dia.lunes, '16:00', '18:00'),
      Horario(Dia.miercoles, '16:00', '18:00'),
    ],
    aprendizajes: const ['Expresión', 'Creatividad', 'Trabajo en equipo', 'Confianza'],
  ),
  Taller(
    id: 6,
    nombre: 'Zumba',
    descripcion: 'Actividad cardiovascular en formato de baile, ideal para mantenerse activo.',
    categoria:catRecreativa,
    lugar: 'Gimnasio-Auditorio',
    cupoMaximo: 25,
    inscritos: 12,
    instructor: _ins(7, 'Valeria', 'Castillo', '', 'Zumba'),
    horarios: const [
      Horario(Dia.martes, '18:00', '19:00'),
      Horario(Dia.jueves, '18:00', '19:00'),
    ],
    aprendizajes: const ['Cardio', 'Ritmo', 'Energía', 'Diversión'],
  ),
];

final inscripcionesSimulado = <Inscripcion>[
  Inscripcion(
    folio: 'VOL-2026-0381',
    alumno: alumnoSimulado,
    taller: talleresSimulado[0],
    fechaInscripcion: DateTime(2026, 9, 15),
  ),
  Inscripcion(
    folio: 'DAN-2026-0382',
    alumno: alumnoSimulado,
    taller: talleresSimulado[2],
    fechaInscripcion: DateTime(2026, 9, 8),
  ),
];
// Horas acumuladas del alumno (en backend: suma de asistencias.horas)

const metaHoras = 60;
const periodoSimulado = 'Septiembre – Diciembre 2026';
const horasMesSimulado = 12;
const asistenciaSimulado = 94;

// En backend: suma de asistencias.horas por folio
const horasPorFolioSimulado = {'VOL-2026-0381': 22, 'DAN-2026-0382': 16};

final avisosSimulado = <Aviso>[
  Aviso(
    id: 1, tallerId: 1, tipo: TipoAviso.cambioHorario,
    titulo: 'Cambio de horario',
    mensaje: 'La actividad de Voleibol ahora será de 17:30 a 19:00 los lunes y jueves.',
    fecha: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Aviso(
    id: 2, tallerId: 1, tipo: TipoAviso.informativo,
    titulo: 'Aviso del instructor',
    mensaje: 'Marco A. López publicó un nuevo aviso para el grupo de Voleibol.',
    fecha: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Aviso(
    id: 3, tallerId: 4, tipo: TipoAviso.recordatorio,
    titulo: 'Cupo disponible',
    mensaje: 'Se liberó un cupo en la actividad de Ajedrez.',
    fecha: DateTime.now().subtract(const Duration(hours: 26)),
  ),
  Aviso(
    id: 4, tallerId: 3, tipo: TipoAviso.informativo,
    titulo: 'Inscripción confirmada',
    mensaje: 'Tu inscripción a Danza folclórica ha sido confirmada.',
    fecha: DateTime.now().subtract(const Duration(hours: 27)),
  ),
];
final instructorSimulado = _ins(2, 'Marco Antonio', 'López', 'Guerra', 'Voleibol');

Alumno _al(int id, String nom, String pat, String ctrl) => Alumno(
      id: id,
      nombre: nom,
      apellidoPaterno: pat,
      correo: '$ctrl@utng.edu.mx',
      numeroControl: ctrl,
      grupo: 'GTID235',
      carrera: 'Ingeniería en Desarrollo de Software',
    );

final companerosSimulado = <Alumno>[
  _al(11, 'Ana Sofía', 'Ramírez', '1225100412'),
  _al(12, 'Diego A.', 'Torres', '1225100455'),
  _al(13, 'Fernanda', 'Ibarra', '1225100291'),
  _al(14, 'Jorge L.', 'Camacho', '1225100367'),
  _al(15, 'Karla', 'Morales', '1225100324'),
  _al(16, 'Luis Á.', 'Prieto', '1225100498'),
];

// {numControl: [asistidas, sesiones]}
const asistenciaPreviaSimulado = {
  '1225100380': [12, 12],
  '1225100412': [11, 12],
  '1225100455': [10, 12],
  '1225100291': [12, 12],
  '1225100367': [8, 12],
  '1225100324': [11, 12],
  '1225100498': [12, 12],
};
const asistenciaInstructorSimulado = 91;
// Horas de los compañeros (la de María se calcula de sus inscripciones)
const horasAlumnosSimulado = {
  '1225100412': 45,
  '1225100455': 60,
  '1225100291': 22,
  '1225100367': 12,
  '1225100324': 60,
  '1225100498': 31,
};