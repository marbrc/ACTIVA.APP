// ===================================================================
// almacen_cuentas.dart
// Guarda las cuentas (alumnos registrados e instructores creados por el
// admin) en un archivo JSON. Las contraseñas NO se guardan en texto:
// solo la sal y el hash (SHA-256).
//
//  - Android / iOS / Windows: archivo activa_cuentas.json en la carpeta
//    de documentos de la app (path_provider).
//  - Web (Chrome): no se pueden escribir archivos, así que el mismo JSON
//    se guarda como texto en shared_preferences.
// ===================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/enums.dart';
import '../modelos/usuario.dart';

class CuentaGuardada {
  CuentaGuardada({
    required this.id,
    required this.rol,
    required this.usuario,
    required this.correo,
    required this.nombre,
    required this.apellidoPaterno,
    this.apellidoMaterno = '',
    this.telefono = '',
    this.especialidad = '',
    this.numeroControl = '',
    this.grupo = '',
    this.carrera = '',
    List<int>? tallerIds,
    this.activo = true,
    this.debeCambiarContrasena = false,
    this.sal = '',
    this.hash = '',
  }) : tallerIds = tallerIds ?? [];

  final int id;
  final Rol rol;
  String usuario;
  String correo;
  String nombre;
  String apellidoPaterno;
  String apellidoMaterno;
  String telefono;
  // instructor
  String especialidad;
  List<int> tallerIds; // talleres que el admin le asignó
  // alumno
  String numeroControl;
  String grupo;
  String carrera;
  // acceso
  bool activo;
  bool debeCambiarContrasena;
  String sal;
  String hash;

  Alumno aAlumno() => Alumno(
    id: id,
    nombre: nombre,
    apellidoPaterno: apellidoPaterno,
    apellidoMaterno: apellidoMaterno,
    correo: correo,
    telefono: telefono.isEmpty ? null : telefono,
    numeroControl: numeroControl,
    grupo: grupo,
    carrera: carrera,
  );

  Instructor aInstructor() => Instructor(
    id: id,
    nombre: nombre,
    apellidoPaterno: apellidoPaterno,
    apellidoMaterno: apellidoMaterno,
    correo: correo,
    telefono: telefono.isEmpty ? null : telefono,
    especialidad: especialidad,
    activo: activo,
  );

  Map<String, dynamic> aJson() => {
    'id': id,
    'rol': rol.name,
    'usuario': usuario,
    'correo': correo,
    'nombre': nombre,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'telefono': telefono,
    'especialidad': especialidad,
    'numeroControl': numeroControl,
    'grupo': grupo,
    'carrera': carrera,
    'tallerIds': tallerIds,
    'activo': activo,
    'debeCambiarContrasena': debeCambiarContrasena,
    'sal': sal,
    'hash': hash,
  };

  factory CuentaGuardada.deJson(Map<String, dynamic> j) => CuentaGuardada(
    id: j['id'] as int,
    rol: Rol.values.firstWhere(
      (r) => r.name == j['rol'],
      orElse: () => Rol.alumno,
    ),
    usuario: (j['usuario'] ?? '') as String,
    correo: (j['correo'] ?? '') as String,
    nombre: (j['nombre'] ?? '') as String,
    apellidoPaterno: (j['apellidoPaterno'] ?? '') as String,
    apellidoMaterno: (j['apellidoMaterno'] ?? '') as String,
    telefono: (j['telefono'] ?? '') as String,
    especialidad: (j['especialidad'] ?? '') as String,
    numeroControl: (j['numeroControl'] ?? '') as String,
    grupo: (j['grupo'] ?? '') as String,
    carrera: (j['carrera'] ?? '') as String,
    tallerIds: [for (final x in (j['tallerIds'] as List? ?? [])) x as int],
    activo: (j['activo'] ?? true) as bool,
    debeCambiarContrasena: (j['debeCambiarContrasena'] ?? false) as bool,
    sal: (j['sal'] ?? '') as String,
    hash: (j['hash'] ?? '') as String,
  );

  /// "profe.lopez@utng.edu.mx" -> "profe_lopez" (válido para validarUsuario)
  static String usuarioDesdeCorreo(String correo) {
    var u = correo
        .split('@')
        .first
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (!RegExp(r'^[a-z]').hasMatch(u)) u = 'inst_$u';
    if (u.length > 20) u = u.substring(0, 20);
    if (u.length < 4) u = u.padRight(4, '0');
    return u;
  }
}

class AlmacenCuentas {
  AlmacenCuentas._(this._cuentas, this._siguienteId);

  final List<CuentaGuardada> _cuentas;
  int _siguienteId;
  Future<bool> _cola = Future.value(true); // escrituras una tras otra

  static const _clave = 'activa_cuentas';
  static const _nombreArchivo = 'activa_cuentas.json';

  // ------------------------------------------------ carga / guardado
  static Future<AlmacenCuentas> cargar() async {
    try {
      final texto = await _leer();
      if (texto != null && texto.trim().isNotEmpty) {
        final m = jsonDecode(texto) as Map<String, dynamic>;
        final lista = [
          for (final c in (m['cuentas'] as List? ?? []))
            CuentaGuardada.deJson(c as Map<String, dynamic>),
        ];
        final maxId = lista.fold<int>(0, (a, c) => c.id > a ? c.id : a);
        final guardado = (m['siguienteId'] as int?) ?? 1000;
        return AlmacenCuentas._(
          lista,
          [guardado, maxId + 1, 1000].reduce((a, b) => a > b ? a : b),
        );
      }
    } catch (e) {
      debugPrint('No se pudieron leer las cuentas guardadas: $e');
    }
    return AlmacenCuentas._([], 1000);
  }

  static Future<File> _archivo() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}$_nombreArchivo');
  }

  static Future<String?> _leer() async {
    if (kIsWeb) {
      return (await SharedPreferences.getInstance()).getString(_clave);
    }
    final f = await _archivo();
    return await f.exists() ? await f.readAsString() : null;
  }

  /// Escribe todo el JSON. Devuelve false si no se pudo guardar.
  Future<bool> guardar() {
    final texto = const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'siguienteId': _siguienteId,
      'cuentas': [for (final c in _cuentas) c.aJson()],
    });
    _cola = _cola.then((_) async {
      try {
        if (kIsWeb) {
          return (await SharedPreferences.getInstance()).setString(
            _clave,
            texto,
          );
        }
        await (await _archivo()).writeAsString(texto, flush: true);
        return true;
      } catch (e) {
        debugPrint('No se pudieron guardar las cuentas: $e');
        return false;
      }
    });
    return _cola;
  }

  // ------------------------------------------------ consultas
  List<CuentaGuardada> get cuentas => List.unmodifiable(_cuentas);
  List<CuentaGuardada> get instructores =>
      _cuentas.where((c) => c.rol == Rol.instructor).toList();
  List<CuentaGuardada> get alumnos =>
      _cuentas.where((c) => c.rol == Rol.alumno).toList();

  int nuevoId() => _siguienteId++;

  CuentaGuardada? porId(int id) {
    for (final c in _cuentas) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Busca por usuario, correo o número de control (solo alumnos).
  CuentaGuardada? buscarAcceso(String texto) {
    final u = texto.trim().toLowerCase();
    if (u.isEmpty) return null;
    for (final c in _cuentas) {
      if (c.usuario == u ||
          c.correo.toLowerCase() == u ||
          (c.rol == Rol.alumno && c.numeroControl == u)) {
        return c;
      }
    }
    return null;
  }

  bool correoTomado(String correo, {int? excepto}) => _cuentas.any(
    (c) => c.id != excepto && c.correo.toLowerCase() == correo.trim().toLowerCase(),
  );

  bool controlTomado(String control, {int? excepto}) => _cuentas.any(
    (c) =>
        c.id != excepto &&
        c.rol == Rol.alumno &&
        c.numeroControl == control.trim(),
  );

  bool usuarioTomado(String usuario, {int? excepto}) => _cuentas.any(
    (c) => c.id != excepto && c.usuario == usuario.trim().toLowerCase(),
  );

  /// Si "base" ya existe, le agrega un número (profe, profe2, profe3...)
  String usuarioLibre(String base) {
    var u = base;
    var n = 2;
    while (usuarioTomado(u)) {
      final sufijo = '$n';
      final corte = base.length + sufijo.length > 20
          ? 20 - sufijo.length
          : base.length;
      u = '${base.substring(0, corte)}$sufijo';
      n++;
    }
    return u;
  }

  // ------------------------------------------------ altas
  Future<bool> agregar(CuentaGuardada c) async {
    _cuentas.add(c);
    final ok = await guardar();
    if (!ok) _cuentas.remove(c);
    return ok;
  }

  // ------------------------------------------------ contraseñas
  static String _sal() {
    final r = Random.secure();
    return base64UrlEncode(List.generate(16, (_) => r.nextInt(256)));
  }

  static String _hash(String sal, String contrasena) =>
      sha256.convert(utf8.encode('$sal:$contrasena')).toString();

  /// Guarda la contraseña (ya con hash). [temporal] = true obliga a
  /// cambiarla en el siguiente inicio de sesión.
  void ponerContrasena(
    CuentaGuardada c,
    String contrasena, {
    bool temporal = false,
  }) {
    c.sal = _sal();
    c.hash = _hash(c.sal, contrasena);
    c.debeCambiarContrasena = temporal;
  }

  bool verificar(CuentaGuardada c, String contrasena) =>
      c.hash.isNotEmpty && c.hash == _hash(c.sal, contrasena);

  /// Contraseña temporal de 10 caracteres que cumple las reglas de la app
  /// (mayúscula, número y carácter especial). Sin letras ambiguas (O, 0, l, 1).
  static String generarTemporal() {
    const mayus = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const minus = 'abcdefghijkmnpqrstuvwxyz';
    const nums = '23456789';
    const esp = '@#!%*?';
    final r = Random.secure();
    String uno(String s) => s[r.nextInt(s.length)];
    final chars = [
      uno(mayus),
      uno(mayus),
      uno(nums),
      uno(nums),
      uno(esp),
      for (var i = 0; i < 5; i++) uno(minus),
    ]..shuffle(r);
    return chars.join();
  }
}