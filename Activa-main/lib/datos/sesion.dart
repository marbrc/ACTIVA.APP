import 'package:flutter/foundation.dart';

import '../modelos/enums.dart';
import 'simulados/datos_simulados.dart';

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
  Rol? rol;

  // ---- idioma: 'es', 'en' o 'fr' ----
  String idioma = 'es';
  void cambiarIdioma(String codigo) {
    idioma = codigo;
    notifyListeners();
  }

  // ---- nombre de usuario por rol (editable en Editar perfil) ----
  final Map<Rol, String> _usuarios = {for (final c in cuentasDemo) c.rol: c.usuario};
  String usuarioDe(Rol r) => _usuarios[r] ?? '';
  bool usuarioDisponible(String u, Rol r) {
    final x = u.trim().toLowerCase();
    return !_usuarios.entries.any((e) => e.key != r && e.value == x);
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

  Rol? iniciarSesion(String usuario, String contrasena) {
    final u = usuario.trim().toLowerCase();

    // 1) usuario de cada rol (ya con el nombre que haya elegido)
    for (final c in cuentasDemo) {
      if (_usuarios[c.rol] == u && c.contrasena == contrasena) {
        rol = c.rol;
        notifyListeners();
        return rol;
      }
    }

    // 2) número de control o correo institucional
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
    notifyListeners();
  }
}