// ===================================================================
// sesion.dart
// quien entro a la app (rol, usuario, foto, idioma) y el acceso con
// cuentas guardadas (alumnos registrados e instructores del admin).
// las cuentas guardadas viven en AlmacenCuentas (archivo JSON).
// ===================================================================

import 'package:flutter/foundation.dart';

import '../modelos/enums.dart';
import 'almacen_cuentas.dart';
import 'simulados/datos_simulados.dart';

// --- resultado de intentar entrar con una cuenta guardada ---
enum EstadoAcceso {
  ok,
  cambiarContrasena,
  desactivado,
  incorrecto,
  noEncontrado,
}

class ResultadoAcceso {
  final EstadoAcceso estado;
  // ahora es la cuenta GUARDADA (la misma que recibe EstadoApp.usarCuenta)
  final CuentaGuardada? cuenta;
  ResultadoAcceso(this.estado, {this.cuenta});
}

// --- cuentas de prueba (las 3 de siempre) ---
class CuentaDemo {
  final String usuario;
  final String contrasena;
  final Rol rol;
  final String etiqueta;
  const CuentaDemo(this.usuario, this.contrasena, this.rol, this.etiqueta);
}

const contrasenaDemo = 'Activa2026!';

const cuentasDemo = <CuentaDemo>[
  CuentaDemo('mar_alumna', contrasenaDemo, Rol.alumno, 'Alumna'),
  CuentaDemo('mar_instructor', contrasenaDemo, Rol.instructor, 'Instructor'),
  CuentaDemo('mar_admin', contrasenaDemo, Rol.admin, 'Admin'),
];

class EstadoSesion extends ChangeNotifier {
  EstadoSesion([this._almacen]);

  /// archivo JSON con las cuentas guardadas (puede ser null)
  final AlmacenCuentas? _almacen;

  Rol? rol;

  /// cuenta que entro con contraseña temporal y todavia tiene que cambiarla
  CuentaGuardada? cuentaPendiente;

  // ---- idioma: 'es', 'en' o 'fr' ----
  String idioma = 'es';
  void cambiarIdioma(String codigo) {
    idioma = codigo;
    notifyListeners();
  }

  // ---- nombre de usuario por rol (editable en Editar perfil) ----
  final Map<Rol, String> _usuarios = {
    for (final c in cuentasDemo) c.rol: c.usuario,
  };
  String usuarioDe(Rol r) => _usuarios[r] ?? '';
  bool usuarioDisponible(String u, Rol r) {
    final x = u.trim().toLowerCase();
    final enDemo = _usuarios.entries.any((e) => e.key != r && e.value == x);
    final enGuardadas = _almacen?.usuarioTomado(x) ?? false;
    return !enDemo && !enGuardadas;
  }

  void cambiarUsuario(Rol r, String u) {
    _usuarios[r] = u.trim().toLowerCase();
    notifyListeners();
  }

  // ---- fotos ----
  final Map<Rol, Uint8List> _fotos = {};
  Uint8List? fotoDe(Rol r) => _fotos[r];
  void guardarFoto(Rol r, Uint8List bytes) {
    _fotos[r] = bytes;
    notifyListeners();
  }

  void quitarFoto(Rol r) {
    _fotos.remove(r);
    notifyListeners();
  }

  // ================= CUENTAS GUARDADAS =================

  /// 1) revisa las cuentas del JSON (usuario, correo o numero de control)
  ResultadoAcceso iniciarSesionGuardada(String usuario, String contrasena) {
    final a = _almacen;
    final c = a?.buscarAcceso(usuario);
    if (a == null || c == null) {
      return ResultadoAcceso(EstadoAcceso.noEncontrado);
    }
    if (!a.verificar(c, contrasena)) {
      return ResultadoAcceso(EstadoAcceso.incorrecto);
    }
    if (!c.activo) {
      return ResultadoAcceso(EstadoAcceso.desactivado);
    }
    if (c.debeCambiarContrasena) {
      cuentaPendiente = c; // primero tiene que crear su contraseña
      return ResultadoAcceso(EstadoAcceso.cambiarContrasena, cuenta: c);
    }
    rol = c.rol;
    notifyListeners();
    return ResultadoAcceso(EstadoAcceso.ok, cuenta: c);
  }

  void cancelarCambioPendiente() {
    cuentaPendiente = null;
    notifyListeners();
  }

  /// true si [pass] es la contraseña (temporal) que tiene ahora la cuenta
  bool esContrasenaActual(String pass) {
    final c = cuentaPendiente;
    if (c == null || _almacen == null) return false;
    return _almacen.verificar(c, pass);
  }

  /// guarda la contraseña nueva y deja entrar. null si no se pudo
  Future<CuentaGuardada?> cambiarContrasenaPendiente(String nueva) async {
    final c = cuentaPendiente;
    final a = _almacen;
    if (c == null || a == null) return null;

    // por si falla el guardado, se puede regresar a como estaba
    final salAntes = c.sal;
    final hashAntes = c.hash;
    final temporalAntes = c.debeCambiarContrasena;

    a.ponerContrasena(c, nueva); // temporal: false
    if (!await a.guardar()) {
      c.sal = salAntes;
      c.hash = hashAntes;
      c.debeCambiarContrasena = temporalAntes;
      return null;
    }
    rol = c.rol;
    cuentaPendiente = null;
    notifyListeners();
    return c;
  }

  /// crea la cuenta de un alumno nuevo (pantalla Crear cuenta).
  /// devuelve el texto del error, o null si todo salio bien
    Future<String?> registrarAlumno({
    required String nombreCompleto,
    required String numeroControl,
    required String grupo,
    required String correo,
    required String carrera,
    required String contrasena,
    String? soloNombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
  }) async {
    final a = _almacen;
    if (a == null) return 'Error: no se pudo abrir el almacenamiento';

    final mail = correo.trim().toLowerCase();
    final control = numeroControl.trim();

    // 1) que no exista ya ese correo o numero de control
    final correoDemo = {
      alumnoSimulado.correo,
      instructorSimulado.correo,
      adminSimulado.correo,
    }.contains(mail);
    if (correoDemo || a.correoTomado(mail)) {
      return 'Error: ese correo ya está registrado';
    }
    final controlDemo =
        control == alumnoSimulado.numeroControl ||
        companerosSimulado.any((x) => x.numeroControl == control);
    if (controlDemo || a.controlTomado(control)) {
      return 'Error: ese número de control ya está registrado';
    }

       // 2) nombre y apellidos: si vienen separados se usan tal cual,
    //    si no, se separa como antes (los 2 últimos son apellidos)
    final String nombre, paterno, materno;
    if (soloNombre != null && apellidoPaterno != null) {
      nombre = soloNombre.trim();
      paterno = apellidoPaterno.trim();
      materno = (apellidoMaterno ?? '').trim();
    } else {
      final p = nombreCompleto.trim().split(RegExp(r'\s+'));
      if (p.length >= 3) {
        nombre = p.sublist(0, p.length - 2).join(' ');
        paterno = p[p.length - 2];
        materno = p.last;
      } else {
        nombre = p.first;
        paterno = p.length > 1 ? p[1] : '';
        materno = '';
      }
    }

    // 3) usuario automatico a partir del correo (que no se repita)
    final base = CuentaGuardada.usuarioDesdeCorreo(mail);
    var usuario = base;
    var n = 2;
    while (_usuarioOcupado(usuario)) {
      final sufijo = '$n';
      final corte = base.length + sufijo.length > 20
          ? 20 - sufijo.length
          : base.length;
      usuario = '${base.substring(0, corte)}$sufijo';
      n++;
    }

    // 4) guarda la cuenta (la contraseña se guarda con hash)
    final c = CuentaGuardada(
      id: a.nuevoId(),
      rol: Rol.alumno,
      usuario: usuario,
      correo: mail,
      nombre: nombre,
      apellidoPaterno: paterno,
      apellidoMaterno: materno,
      numeroControl: control,
      grupo: grupo.trim().toUpperCase(),
      carrera: carrera,
    );
    a.ponerContrasena(c, contrasena);
    if (!await a.agregar(c)) {
      return 'Error: no se pudo guardar la cuenta';
    }
    return null;
  }

  bool _usuarioOcupado(String u) =>
      _usuarios.containsValue(u) || (_almacen?.usuarioTomado(u) ?? false);

  // ================= CUENTAS DE PRUEBA =================

  /// 2) cuentas de prueba, numero de control o correo de los datos simulados
  Rol? iniciarSesion(String usuario, String contrasena) {
    final u = usuario.trim().toLowerCase();

    // usuario de cada rol (ya con el nombre que haya elegido)
    for (final c in cuentasDemo) {
      if (_usuarios[c.rol] == u && c.contrasena == contrasena) {
        rol = c.rol;
        notifyListeners();
        return rol;
      }
    }

    // numero de control o correo institucional
    if (contrasena == contrasenaDemo) {
      Rol? encontrado;
      if (u == alumnoSimulado.numeroControl || u == alumnoSimulado.correo) {
        encontrado = Rol.alumno;
      } else if (u == instructorSimulado.correo) {
        encontrado = Rol.instructor;
      } else if (u == adminSimulado.correo) {
        encontrado = Rol.admin;
      }
      if (encontrado != null) {
        rol = encontrado;
        notifyListeners();
        return encontrado;
      }
    }
    return null;
  }

  static String rutaDe(Rol r) => switch (r) {
    Rol.alumno => '/alumno',
    Rol.instructor => '/instructor',
    Rol.admin => '/admin',
  };

  void cerrarSesion() {
    rol = null;
    cuentaPendiente = null;
    notifyListeners();
  }
}