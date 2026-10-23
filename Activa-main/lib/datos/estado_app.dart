import 'package:activa/modelos/taller.dart';
import 'package:flutter/foundation.dart';

import '../modelos/enums.dart';
import '../modelos/inscripcion.dart';
import 'simulados/datos_simulados.dart';
import '../modelos/categoria.dart';
import '../nucleo/utilidades/formateadores.dart';
import '../modelos/usuario.dart';
import '../modelos/comunicacion.dart';
import 'simulados/datos_comunicacion.dart';

import '../../../nucleo/componentes/dialogo_confirmar.dart';

class EstadoApp extends ChangeNotifier {
  final List<Taller> _talleres = List.of(talleresSimulado);
  final List<Inscripcion> _inscripciones = List.of(inscripcionesSimulado);
  final Set<int> _favoritos = {};
  int _seq = 386; // siguiente consecutivo de folio

  List<Taller> get talleres => List.unmodifiable(_talleres);
  List<Inscripcion> get inscripciones => List.unmodifiable(_inscripciones);

  Taller tallerPorId(int id) => _talleres.firstWhere((t) => t.id == id);

  bool estaInscrito(int tallerId) => _inscripciones.any(
    (i) => i.taller.id == tallerId && i.estado == EstadoInscripcion.activa,
  );

  Inscripcion? inscripcionPorFolio(String folio) {
    for (final i in _inscripciones) {
      if (i.folio == folio) return i;
    }
    return null;
  }

  bool esFavorito(int id) => _favoritos.contains(id);

  void toggleFavorito(int id) {
    _favoritos.contains(id) ? _favoritos.remove(id) : _favoritos.add(id);
    notifyListeners();
  }

  /// Devuelve la inscripción creada, o null si no se pudo.
  Inscripcion? inscribir(Taller t) {
    final actual = tallerPorId(t.id);
    if (!actual.hayCupo || estaInscrito(t.id)) return null;

    final actualizado = actual.copyWith(inscritos: actual.inscritos + 1);
    _talleres[_talleres.indexWhere((x) => x.id == t.id)] = actualizado;

    final ins = Inscripcion(
      folio: _folio(actualizado),
      alumno: alumno,
      taller: actualizado,
      fechaInscripcion: DateTime.now(),
    );
    _inscripciones.add(ins);
    notifyListeners(); // avisa a todas las pantallas que escuchan
    return ins;
  }

  static const _acentos = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ñ': 'n',
  };

  String _folio(Taller t) {
    final limpio = t.nombre
        .toLowerCase()
        .split('')
        .map((c) => _acentos[c] ?? c)
        .join()
        .replaceAll(RegExp(r'[^a-z]'), '');
    final prefijo = limpio.substring(0, 3).toUpperCase(); // VOL, FUT, DAN...
    return '$prefijo-2026-${(_seq++).toString().padLeft(4, '0')}';
  }

  final List<Categoria> _categorias = List.of(categoriasSimulado);

  List<Categoria> get categorias =>
      List.unmodifiable(_categorias.where((c) => c.activa));

  void agregarCategoria(Categoria c) {
    _categorias.add(c);
    notifyListeners();
  }

  Alumno alumno = alumnoSimulado;
  final Map<String, int> _horas = Map.of(horasPorFolioSimulado);
  final List<Aviso> _avisos = List.of(avisosSimulado);

  List<Aviso> get avisos => List.unmodifiable(_avisos);

  List<Inscripcion> get misInscripciones => _inscripciones
      .where((i) => i.estado == EstadoInscripcion.activa)
      .toList();

  int get horasRealizadas => _horas.values.fold(0, (a, b) => a + b);
  int horasDe(String folio) => _horas[folio] ?? 0;

  void cancelar(String folio) {
    final idx = _inscripciones.indexWhere((i) => i.folio == folio);
    if (idx < 0) return;
    final ins = _inscripciones[idx];
    _inscripciones[idx] = ins.copyWith(estado: EstadoInscripcion.cancelada);
    final ti = _talleres.indexWhere((t) => t.id == ins.taller.id);
    _talleres[ti] = _talleres[ti].copyWith(
      inscritos: _talleres[ti].inscritos - 1,
    );
    notifyListeners(); // se libera el lugar en Explorar
  }

  // Limitación: asume "nombres + paterno + materno" (los 2 últimos son apellidos).
  void actualizarPerfil(String nombreCompleto, String telefono) {
    final p = nombreCompleto.trim().split(RegExp(r'\s+'));
    alumno = p.length >= 3
        ? alumno.copyWith(
            nombre: p.sublist(0, p.length - 2).join(' '),
            apellidoPaterno: p[p.length - 2],
            apellidoMaterno: p.last,
            telefono: telefono.trim(),
          )
        : alumno.copyWith(
            nombre: p.first,
            apellidoPaterno: p.length > 1 ? p[1] : '',
            apellidoMaterno: '',
            telefono: telefono.trim(),
          );
    notifyListeners();
  }

  Instructor instructor = instructorSimulado;
  final Map<int, List<Alumno>> _roster = {1: List.of(companerosSimulado)};
  // clave "tallerId|yyyy-mm-dd" -> {numControl: presente}
  final Map<String, Map<String, bool>> _asistencias = {};

  // para el historial de asistencia del instructor
  Map<String, Map<String, bool>> get asistencias =>
      Map.unmodifiable(_asistencias);

  List<Taller> get misGrupos =>
      _talleres.where((t) => t.instructor.id == instructor.id).toList();

  List<Alumno> alumnosDe(int tallerId) {
    final lista = List<Alumno>.of(_roster[tallerId] ?? const []);
    if (estaInscrito(tallerId)) lista.insert(0, alumno);
    return lista;
  }

  String _key(int tallerId, DateTime f) => '$tallerId|${fechaIso(f)}';

  Map<String, bool> asistenciaDe(int tallerId, DateTime f) =>
      Map.of(_asistencias[_key(tallerId, f)] ?? {});

  void guardarAsistencia(Taller t, DateTime f, Map<String, bool> marcas) {
    final k = _key(t.id, f);
    final antes = _asistencias[k] ?? {};
    final ins = _inscripciones
        .where(
          (i) => i.taller.id == t.id && i.estado == EstadoInscripcion.activa,
        )
        .firstOrNull;
    if (ins != null) {
      final nc = alumno.numeroControl;
      final eraP = antes[nc] == true;
      final esP = marcas[nc] == true;
      final actual = _horas[ins.folio] ?? 0;
      if (!eraP && esP) _horas[ins.folio] = actual + t.horasPorSesion;
      if (eraP && !esP) {
        final nuevo = actual - t.horasPorSesion;
        _horas[ins.folio] = nuevo < 0 ? 0 : nuevo;
      }
    }
    _asistencias[k] = Map.of(marcas);
    notifyListeners();
  }

  List<Aviso> get avisosPublicados {
    final ids = misGrupos.map((t) => t.id).toSet();
    return _avisos.where((a) => ids.contains(a.tallerId)).toList();
  }

  void publicarAviso({
    required int tallerId,
    required TipoAviso tipo,
    required String titulo,
    required String mensaje,
  }) {
    _avisos.insert(
      0,
      Aviso(
        id: _avisos.length + 1,
        tallerId: tallerId,
        tipo: tipo,
        titulo: titulo.trim(),
        mensaje: mensaje.trim(),
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Administrador admin = adminSimulado;
  int _tallerSeq = 7;
  int _instSeq = 20;
  final Map<String, int> _horasOtros = Map.of(horasAlumnosSimulado);
  final List<({String tipo, String formato, DateTime fecha})> _reportes = [];
  late final List<Instructor> _instructores = {
    for (final t in talleresSimulado) t.instructor.id: t.instructor,
  }.values.toList();

  List<Instructor> get instructores => List.unmodifiable(_instructores);
  List<Alumno> get todosAlumnos => [alumno, ...companerosSimulado];
  List<({String tipo, String formato, DateTime fecha})> get reportes =>
      List.unmodifiable(_reportes);

  int horasAlumno(Alumno a) => a.numeroControl == alumno.numeroControl
      ? horasRealizadas
      : (_horasOtros[a.numeroControl] ?? 0);

  int get totalInscripciones => _talleres.fold(0, (a, t) => a + t.inscritos);
  int get totalCupos => _talleres
      .where((t) => t.activo)
      .fold(0, (a, t) => a + t.cuposDisponibles);
  int alumnosDeInstructor(int id) => _talleres
      .where((t) => t.instructor.id == id)
      .fold(0, (a, t) => a + t.inscritos);

  int get siguienteTallerId => _tallerSeq;

  void guardarTaller(Taller t) {
    final i = _talleres.indexWhere((x) => x.id == t.id);
    if (i < 0) {
      _talleres.add(t);
      _tallerSeq++;
    } else {
      _talleres[i] = t;
      for (var k = 0; k < _inscripciones.length; k++) {
        if (_inscripciones[k].taller.id == t.id) {
          _inscripciones[k] = _inscripciones[k].copyWith(taller: t);
        }
      }
    }
    notifyListeners();
  }

  /// Devuelve el motivo del choque, o null si no hay traslape.
  String? conflictoHorario(Taller t) {
    for (final o in _talleres) {
      if (o.id == t.id || !o.activo) continue;
      final mismoLugar =
          o.lugar.trim().toLowerCase() == t.lugar.trim().toLowerCase();
      final mismoInstr = o.instructor.id == t.instructor.id;
      if (!mismoLugar && !mismoInstr) continue;
      for (final a in t.horarios) {
        for (final b in o.horarios) {
          if (a.traslapaCon(b)) {
            final cuando = '${a.dia.corto} de ${b.horaInicio} a ${b.horaFin}';
            return mismoInstr
                ? '${t.instructor.nombreCompleto} ya imparte ${o.nombre} el $cuando'
                : '${o.lugar} está ocupado por ${o.nombre} el $cuando';
          }
        }
      }
    }
    return null;
  }

  void agregarInstructor({
    required String nombre,
    required String paterno,
    String materno = '',
    required String correo,
    required String especialidad,
  }) {
    _instructores.add(
      Instructor(
        id: _instSeq++,
        nombre: nombre.trim(),
        apellidoPaterno: paterno.trim(),
        apellidoMaterno: materno.trim(),
        correo: correo.trim().toLowerCase(),
        especialidad: especialidad.trim(),
      ),
    );
    notifyListeners();
  }

  void registrarReporte(String tipo, String formato) {
    _reportes.insert(0, (tipo: tipo, formato: formato, fecha: DateTime.now()));
    notifyListeners();
  }

    // ================= CHATS GRUPALES =================
  final Map<int, List<MensajeChat>> _chats = {
    for (final e in chatsSimulado.entries) e.key: List.of(e.value),
  };
  int _msgSeq = 100;

  List<MensajeChat> mensajesDe(int tallerId) =>
      List.unmodifiable(_chats[tallerId] ?? const []);

  MensajeChat? ultimoMensaje(int tallerId) {
    final l = _chats[tallerId];
    return (l == null || l.isEmpty) ? null : l.last;
  }

  List<Taller> chatsDe(Rol rol) => switch (rol) {
    Rol.alumno =>
      misInscripciones.map((i) => tallerPorId(i.taller.id)).toList(),
    Rol.instructor => misGrupos,
    Rol.admin => _talleres.where((t) => t.activo).toList(),
  };

  String nombreChat(Rol rol) => switch (rol) {
    Rol.alumno => alumno.nombreCompleto,
    Rol.instructor => instructor.nombreCompleto,
    Rol.admin => 'Coordinación',
  };

  void enviarMensaje({
    required int tallerId,
    required Rol rol,
    required String texto,
  }) {
    final t = texto.trim();
    if (t.isEmpty) return;
    _chats.putIfAbsent(tallerId, () => []).add(
      MensajeChat(
        id: _msgSeq++,
        tallerId: tallerId,
        rol: rol,
        autor: nombreChat(rol),
        texto: t,
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ================= ENCUESTAS =================
  final List<RespuestaEncuesta> _encuestas = List.of(encuestasSimulado);
  int _encSeq = 100;

  List<RespuestaEncuesta> get encuestas => List.unmodifiable(_encuestas);

  bool encuestaContestada(int tallerId) => _encuestas.any(
    (e) => e.tallerId == tallerId && e.numeroControl == alumno.numeroControl,
  );

  void enviarEncuesta({
    required int tallerId,
    required int club,
    required int instructorCalif,
    String comentario = '',
  }) {
    if (encuestaContestada(tallerId)) return;
    _encuestas.insert(
      0,
      RespuestaEncuesta(
        id: _encSeq++,
        tallerId: tallerId,
        numeroControl: alumno.numeroControl,
        califClub: club,
        califInstructor: instructorCalif,
        comentario: comentario.trim(),
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  int respuestasDeClub(int tallerId) =>
      _encuestas.where((e) => e.tallerId == tallerId).length;

  double? promedioClub(int tallerId) {
    final l = _encuestas.where((e) => e.tallerId == tallerId).toList();
    if (l.isEmpty) return null;
    return l.fold<int>(0, (a, e) => a + e.califClub) / l.length;
  }

  List<RespuestaEncuesta> _encuestasDeInstructor(int instructorId) {
    final ids = _talleres
        .where((t) => t.instructor.id == instructorId)
        .map((t) => t.id)
        .toSet();
    return _encuestas.where((e) => ids.contains(e.tallerId)).toList();
  }

  int respuestasDeInstructor(int instructorId) =>
      _encuestasDeInstructor(instructorId).length;

  double? promedioInstructor(int instructorId) {
    final l = _encuestasDeInstructor(instructorId);
    if (l.isEmpty) return null;
    return l.fold<int>(0, (a, e) => a + e.califInstructor) / l.length;
  }

  double? get promedioGeneralClubes {
    if (_encuestas.isEmpty) return null;
    return _encuestas.fold<int>(0, (a, e) => a + e.califClub) /
        _encuestas.length;
  }

  // ================= SOLICITUDES AL ADMIN =================
  final List<SolicitudAdmin> _solicitudes = List.of(solicitudesSimulado);
  int _solSeq = 100;

  List<SolicitudAdmin> get solicitudes => List.unmodifiable(_solicitudes);

  List<SolicitudAdmin> get solicitudesDelInstructor =>
      _solicitudes.where((s) => s.instructorId == instructor.id).toList();

  int get solicitudesPendientes =>
      _solicitudes.where((s) => s.estado == EstadoSolicitud.pendiente).length;

  void enviarSolicitud({
    required Taller taller,
    required TipoSolicitud tipo,
    String mensaje = '',
  }) {
    _solicitudes.insert(
      0,
      SolicitudAdmin(
        id: _solSeq++,
        tallerId: taller.id,
        instructorId: instructor.id,
        instructorNombre: instructor.nombreCompleto,
        tipo: tipo,
        mensaje: mensaje.trim(),
        fecha: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void atenderSolicitud(int id) {
    final i = _solicitudes.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _solicitudes[i] = _solicitudes[i].copyWith(
      estado: EstadoSolicitud.atendida,
    );
    notifyListeners();
  }

  int listasRegistradasDe(int instructorId) {
    final ids = _talleres
        .where((t) => t.instructor.id == instructorId)
        .map((t) => t.id)
        .toSet();
    return _asistencias.keys
        .where((k) => ids.contains(int.tryParse(k.split('|').first)))
        .length;
  }
}
