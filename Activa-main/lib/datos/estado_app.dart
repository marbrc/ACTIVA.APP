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
import 'almacen_cuentas.dart';


class EstadoApp extends ChangeNotifier {
  EstadoApp([this._almacen]) {
    _cargarInstructoresGuardados();
  }

  /// Archivo JSON con las cuentas (alumnos registrados e instructores del admin)
  final AlmacenCuentas? _almacen;

  final List<Taller> _talleres = List.of(talleresSimulado);
  final List<Inscripcion> _inscripciones = List.of(inscripcionesSimulado);
  final Set<int> _favoritos = {};
  int _seq = 386; // siguiente consecutivo de folio

  List<Taller> get talleres => List.unmodifiable(_talleres);
  List<Inscripcion> get inscripciones => List.unmodifiable(_inscripciones);

  Taller tallerPorId(int id) => _talleres.firstWhere((t) => t.id == id);

  bool estaInscrito(int tallerId) => _inscripciones.any(
    (i) =>
        i.taller.id == tallerId &&
        i.estado == EstadoInscripcion.activa &&
        i.alumno.numeroControl == alumno.numeroControl,
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
      .where(
        (i) =>
            i.estado == EstadoInscripcion.activa &&
            i.alumno.numeroControl == alumno.numeroControl,
      )
      .toList();

  int get horasRealizadas => _inscripciones
      .where((i) => i.alumno.numeroControl == alumno.numeroControl)
      .fold(0, (a, i) => a + (_horas[i.folio] ?? 0));
  int horasDe(String folio) => _horas[folio] ?? 0;

   void cancelar(String folio) {
    final idx = _inscripciones.indexWhere((i) => i.folio == folio);
    if (idx < 0) return;
    final ins = _inscripciones[idx];
    _bajas[ins.taller.id] = (_bajas[ins.taller.id] ?? 0) + 1;

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
    // si la alumna entró con una cuenta guardada, el cambio también va al JSON
    final c = _almacen?.porId(alumno.id);
    if (c != null && c.rol == Rol.alumno) {
      c.nombre = alumno.nombre;
      c.apellidoPaterno = alumno.apellidoPaterno;
      c.apellidoMaterno = alumno.apellidoMaterno;
      c.telefono = alumno.telefono ?? '';
      _almacen!.guardar();
    }
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
        id: _avisoSeq++,        tallerId: tallerId,
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
  List<Alumno> get todosAlumnos {
    final vistos = {
      alumno.numeroControl,
      for (final a in companerosSimulado) a.numeroControl,
    };
    return [
      alumno,
      ...companerosSimulado,
      // alumnos que se registraron con "Crear cuenta"
      for (final c in _almacen?.alumnos ?? const <CuentaGuardada>[])
        if (vistos.add(c.numeroControl)) c.aAlumno(),
    ];
  }
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

    // ================= AVISOS: leídos / archivados =================
  final Set<int> _avisosLeidos = {};
  final Set<int> _avisosArchivados = {};
  int _avisoSeq = 1000;

  bool avisoLeido(int id) => _avisosLeidos.contains(id);
  List<Aviso> get avisosVisibles =>
      _avisos.where((a) => !_avisosArchivados.contains(a.id)).toList();
  List<Aviso> get avisosArchivados =>
      _avisos.where((a) => _avisosArchivados.contains(a.id)).toList();
  int get avisosSinLeer =>
      avisosVisibles.where((a) => !_avisosLeidos.contains(a.id)).length;

  void marcarAviso(int id, {bool leido = true}) {
    leido ? _avisosLeidos.add(id) : _avisosLeidos.remove(id);
    notifyListeners();
  }

  void marcarTodosLeidos() {
    _avisosLeidos.addAll(avisosVisibles.map((a) => a.id));
    notifyListeners();
  }

  void archivarAviso(int id, {bool archivar = true}) {
    archivar ? _avisosArchivados.add(id) : _avisosArchivados.remove(id);
    notifyListeners();
  }

  Aviso? eliminarAviso(int id) {
    final i = _avisos.indexWhere((a) => a.id == id);
    if (i < 0) return null;
    final a = _avisos.removeAt(i);
    notifyListeners();
    return a;
  }

  void restaurarAviso(Aviso a) {
    _avisos.add(a);
    _avisos.sort((x, y) => y.fecha.compareTo(x.fecha));
    notifyListeners();
  }

  // ================= CHATS: anclar y fondo =================
  final Set<int> _chatsAnclados = {};
  final Map<int, int> _fondosChat = {};

  bool chatAnclado(int id) => _chatsAnclados.contains(id);
  int fondoChat(int id) => _fondosChat[id] ?? 0;

  /// false si ya hay 3 anclados
  bool toggleAnclarChat(int id) {
    if (_chatsAnclados.contains(id)) {
      _chatsAnclados.remove(id);
    } else {
      if (_chatsAnclados.length >= 3) return false;
      _chatsAnclados.add(id);
    }
    notifyListeners();
    return true;
  }

  void ponerFondoChat(int id, int fondo) {
    _fondosChat[id] = fondo;
    notifyListeners();
  }

  List<Taller> chatsOrdenados(Rol rol) {
    final l = chatsDe(rol);
    int t(Taller x) => ultimoMensaje(x.id)?.fecha.millisecondsSinceEpoch ?? 0;
    l.sort((a, b) {
      final pa = chatAnclado(a.id), pb = chatAnclado(b.id);
      if (pa != pb) return pa ? -1 : 1;
      return t(b).compareTo(t(a));
    });
    return l;
  }

  // ================= INSTRUCTORES: duplicados =================
  bool existeCorreoInstructor(String c) =>
      _instructores.any((i) => i.correo == c.trim().toLowerCase());

  bool existeInstructor(String n, String p, String m) => _instructores.any(
    (i) => i.nombreCompleto.toLowerCase() == '$n $p $m'.trim().toLowerCase(),
  );

  // ================= SOLICITUDES (lógica mejorada) =================
  final Map<int, int> _bajas = {};
  int bajasDe(int tallerId) => _bajas[tallerId] ?? 0;

  bool haySolicitudPendiente(int tallerId, TipoSolicitud tipo) => _solicitudes.any(
    (s) =>
        s.tallerId == tallerId &&
        s.tipo == tipo &&
        s.estado == EstadoSolicitud.pendiente,
  );

  /// false si ya existe una igual pendiente
  bool enviarSolicitud({
    required Taller taller,
    required TipoSolicitud tipo,
    String mensaje = '',
  }) {
    if (haySolicitudPendiente(taller.id, tipo)) return false;
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
    return true;
  }

  void cancelarSolicitud(int id) {
    _solicitudes.removeWhere(
      (s) => s.id == id && s.estado == EstadoSolicitud.pendiente,
    );
    notifyListeners();
  }

  void responderSolicitud(
    int id, {
    required bool aprobar,
    String respuesta = '',
    int cupoExtra = 0,
  }) {
    final i = _solicitudes.indexWhere((s) => s.id == id);
    if (i < 0) return;
    final sol = _solicitudes[i];
    if (aprobar && cupoExtra > 0) {
      final t = tallerPorId(sol.tallerId);
      guardarTaller(t.copyWith(cupoMaximo: t.cupoMaximo + cupoExtra));
    }
    _solicitudes[i] = sol.copyWith(
      estado: aprobar ? EstadoSolicitud.atendida : EstadoSolicitud.rechazada,
      respuesta: respuesta.trim(),
      cupoExtra: aprobar ? cupoExtra : 0,
    );
    notifyListeners();
  }

  // ================= CUENTAS GUARDADAS (JSON) =================
  Alumno _alumnoDemo = alumnoSimulado;
  Instructor _instructorDemo = instructorSimulado;
  bool _alumnoEsDemo = true;
  bool _instructorEsDemo = true;

  /// Pone como "persona actual" a la cuenta guardada con la que se entró.
  /// Con null vuelve a las cuentas de prueba.
  void usarCuenta(CuentaGuardada? c) {
    if (_alumnoEsDemo) _alumnoDemo = alumno;
    if (_instructorEsDemo) _instructorDemo = instructor;

    if (c != null && c.rol == Rol.alumno) {
      alumno = c.aAlumno();
      _alumnoEsDemo = false;
    } else {
      alumno = _alumnoDemo;
      _alumnoEsDemo = true;
    }

    if (c != null && c.rol == Rol.instructor) {
      final id = c.id;
      instructor = _instructores.firstWhere(
        (i) => i.id == id,
        orElse: () => c.aInstructor(),
      );
      _instructorEsDemo = false;
    } else {
      instructor = _instructorDemo;
      _instructorEsDemo = true;
    }
    notifyListeners();
  }

  // al abrir la app: mete a los instructores del JSON y les regresa sus talleres
  void _cargarInstructoresGuardados() {
    final a = _almacen;
    if (a == null) return;
    for (final c in a.instructores) {
      final inst = c.aInstructor();
      _instructores.add(inst);
      for (final id in c.tallerIds) {
        final i = _talleres.indexWhere((t) => t.id == id);
        if (i >= 0) guardarTaller(_talleres[i].copyWith(instructor: inst));
      }
    }
  }

  // ================= ADMIN: instructores con cuenta =================
  bool tieneCuentaInstructor(int id) => _almacen?.porId(id) != null;

  Instructor? instructorPorId(int id) {
    for (final i in _instructores) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Taller> talleresDeInstructor(int id) =>
      _talleres.where((t) => t.instructor.id == id).toList();

  // los talleres guardan una copia del instructor: hay que actualizarla
  void _reemplazarInstructor(Instructor n) {
    final i = _instructores.indexWhere((x) => x.id == n.id);
    if (i >= 0) _instructores[i] = n;
    for (final t in List.of(_talleres)) {
      if (t.instructor.id == n.id) guardarTaller(t.copyWith(instructor: n));
    }
    if (instructor.id == n.id) instructor = n;
    notifyListeners();
  }

  /// Da de alta al instructor con su cuenta de acceso. La contraseña se
  /// guarda con hash y queda como temporal (la tiene que cambiar al entrar).
  Future<({Instructor? instructor, String? error})> crearInstructor({
    required String nombre,
    required String paterno,
    String materno = '',
    required String correo,
    required String especialidad,
    required String contrasenaTemporal,
  }) async {
    final a = _almacen;
    if (a == null) {
      return (instructor: null, error: 'Error: no se pudo abrir el almacenamiento');
    }
    final mail = correo.trim().toLowerCase();
    if (existeCorreoInstructor(mail) || a.correoTomado(mail)) {
      return (instructor: null, error: 'Error: ese correo ya está registrado');
    }
    if (existeInstructor(nombre, paterno, materno)) {
      return (instructor: null, error: 'Error: ya existe un instructor con ese nombre');
    }
    final c = CuentaGuardada(
      id: a.nuevoId(),
      rol: Rol.instructor,
      usuario: a.usuarioLibre(CuentaGuardada.usuarioDesdeCorreo(mail)),
      correo: mail,
      nombre: nombre.trim(),
      apellidoPaterno: paterno.trim(),
      apellidoMaterno: materno.trim(),
      especialidad: especialidad.trim(),
    );
    a.ponerContrasena(c, contrasenaTemporal, temporal: true);
    if (!await a.agregar(c)) {
      return (instructor: null, error: 'Error: no se pudo guardar la cuenta');
    }
    final inst = c.aInstructor();
    _instructores.add(inst);
    notifyListeners();
    return (instructor: inst, error: null);
  }

  /// Devuelve el texto del error, o null si todo salió bien.
  Future<String?> editarInstructor(
    int id, {
    required String nombre,
    required String paterno,
    String materno = '',
    required String correo,
    required String especialidad,
  }) async {
    final actual = instructorPorId(id);
    if (actual == null) return 'Error: no se encontró al instructor';
    final mail = correo.trim().toLowerCase();
    if (_instructores.any((i) => i.id != id && i.correo == mail) ||
        (_almacen?.correoTomado(mail, excepto: id) ?? false)) {
      return 'Error: ese correo ya está registrado';
    }
    _reemplazarInstructor(
      actual.copyWith(
        nombre: nombre.trim(),
        apellidoPaterno: paterno.trim(),
        apellidoMaterno: materno.trim(),
        correo: mail,
        especialidad: especialidad.trim(),
      ),
    );
    final c = _almacen?.porId(id);
    if (c != null) {
      c.nombre = nombre.trim();
      c.apellidoPaterno = paterno.trim();
      c.apellidoMaterno = materno.trim();
      c.correo = mail;
      c.especialidad = especialidad.trim();
      if (!await _almacen!.guardar()) {
        return 'Error: no se pudieron guardar los cambios';
      }
    }
    return null;
  }

  /// Activa o desactiva al instructor (desactivado no puede iniciar sesión).
  Future<String?> cambiarActivoInstructor(int id, bool activo) async {
    final actual = instructorPorId(id);
    if (actual == null) return 'Error: no se encontró al instructor';
    if (actual.activo == activo) return null;
    _reemplazarInstructor(actual.copyWith(activo: activo));
    final c = _almacen?.porId(id);
    if (c != null) {
      c.activo = activo;
      if (!await _almacen!.guardar()) {
        return 'Error: no se pudo guardar el cambio';
      }
    }
    return null;
  }

  /// Pone una contraseña temporal nueva (vuelve a pedir el cambio al entrar).
  Future<String?> restablecerContrasenaInstructor(
    int id,
    String temporal,
  ) async {
    final a = _almacen;
    final c = a?.porId(id);
    if (a == null || c == null) {
      return 'Error: este instructor no tiene cuenta de acceso';
    }
    a.ponerContrasena(c, temporal, temporal: true);
    return await a.guardar() ? null : 'Error: no se pudo guardar la contraseña';
  }

  /// Asigna el taller al instructor (el taller solo tiene un instructor, así
  /// que si lo tenía otro, se le quita). Devuelve el error o null.
  Future<String?> asignarTaller(int instructorId, int tallerId) async {
    final inst = instructorPorId(instructorId);
    if (inst == null) return 'Error: no se encontró al instructor';
    if (!inst.activo) return 'Error: el instructor está desactivado';
    final t = tallerPorId(tallerId);
    if (t.instructor.id == instructorId) return null;
    final nuevo = t.copyWith(instructor: inst);
    final choque = conflictoHorario(nuevo);
    if (choque != null) return 'Error: traslape de horario. $choque';
    guardarTaller(nuevo);
    final a = _almacen;
    if (a != null) {
      for (final c in a.instructores) {
        c.tallerIds.remove(tallerId);
      }
      a.porId(instructorId)?.tallerIds.add(tallerId);
      if (!await a.guardar()) return 'Error: no se pudo guardar la asignación';
    }
    return null;
  }
}
