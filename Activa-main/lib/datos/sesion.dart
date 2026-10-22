// ===================================================================
// sesion.dart
// guarda quien inicio sesion (alumna, instructor o admin) y la foto
// de perfil de cada rol. es un ChangeNotifier igual que EstadoApp
// ===================================================================

import 'package:flutter/foundation.dart';

import '../modelos/enums.dart';
import 'simulados/datos_simulados.dart';

// una cuenta de prueba (usuario + contraseña + rol)
class CuentaDemo {
  final String usuario;
  final String contrasena;
  final Rol rol;
  final String etiqueta;
  const CuentaDemo(this.usuario, this.contrasena, this.rol, this.etiqueta);
}

// contraseña unica para las 3 cuentas de prueba
const contrasenaDemo = 'Activa2026!';

// las 3 cuentas que pidio mar: usuario_rol
const cuentasDemo = <CuentaDemo>[
  CuentaDemo('mar_alumna', contrasenaDemo, Rol.alumno, 'Alumna'),
  CuentaDemo('mar_instructor', contrasenaDemo, Rol.instructor, 'Instructor'),
  CuentaDemo('mar_admin', contrasenaDemo, Rol.admin, 'Admin'),
];

class EstadoSesion extends ChangeNotifier {
  // rol de la sesion actual (null = nadie ha entrado)
  Rol? rol;

  // una foto por rol, guardada en memoria como bytes png
  final Map<Rol, Uint8List> _fotos = {};

  Uint8List? fotoDe(Rol r) => _fotos[r];

  void guardarFoto(Rol r, Uint8List bytes) {
    _fotos[r] = bytes;
    notifyListeners(); // avisa a todos los avatares
  }

  void quitarFoto(Rol r) {
    _fotos.remove(r);
    notifyListeners();
  }

  // revisa usuario y contraseña, devuelve el rol o null si estan mal
  Rol? iniciarSesion(String usuario, String contrasena) {
    final u = usuario.trim().toLowerCase();

    // 1) cuentas de prueba usuario_rol
    for (final c in cuentasDemo) {
      if (c.usuario == u && c.contrasena == contrasena) {
        rol = c.rol;
        notifyListeners();
        return rol;
      }
    }

    // 2) tambien entra con numero de control o correo institucional
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

  // ruta del panel de cada rol
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
