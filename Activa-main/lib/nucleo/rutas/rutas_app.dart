import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../servicios/sonidos.dart';
import '../../modulos/autenticacion/pantallas/pantalla_carga.dart';
import '../../modulos/alumno/pantallas/pantallas_ayuda.dart';
import '../../modulos/autenticacion/pantallas/pantalla_olvide_contrasena.dart';
import '../../modulos/autenticacion/pantallas/pantalla_inicio_sesion.dart';
import '../../modulos/autenticacion/pantallas/pantalla_contrasena_actualizada.dart';
import '../../modulos/autenticacion/pantallas/pantalla_registro.dart';
import '../../modulos/autenticacion/pantallas/pantalla_bienvenida.dart';
import '../../modulos/alumno/pantallas/pantalla_detalle_actividad.dart';
import '../../modulos/alumno/pantallas/pantalla_inscripcion_exitosa.dart';
import '../../modulos/alumno/pantallas/pantalla_explorar.dart';
import '../../modulos/alumno/pantallas/pantalla_inicio_alumno.dart';
import '../../modulos/alumno/pantallas/pantalla_mis_actividades.dart';
import '../../modulos/alumno/pantallas/pantalla_avisos.dart';
import '../../modulos/alumno/pantallas/pantallas_perfil.dart';
import '../../modulos/alumno/pantallas/estructura_alumno.dart';
import '../componentes/pantalla_provisional.dart';
import '../../modulos/instructor/pantallas/pantallas_asistencia.dart';
import '../../modulos/instructor/pantallas/pantallas_grupos.dart';
import '../../modulos/instructor/pantallas/pantalla_inicio_instructor.dart';
import '../../modulos/instructor/pantallas/pantalla_perfil_instructor.dart';
import '../../modulos/instructor/pantallas/estructura_instructor.dart';
import '../../modulos/instructor/pantallas/pantallas_avisos_instructor.dart';
import '../../modulos/administrador/pantallas/pantallas_actividades_admin.dart';
import '../../modulos/administrador/pantallas/pantalla_inicio_admin.dart';
import '../../modulos/administrador/pantallas/pantallas_personas_admin.dart';
import '../../modulos/administrador/pantallas/pantallas_reportes_perfil_admin.dart';
import '../../modulos/administrador/pantallas/estructura_admin.dart';

// Suena cada vez que se abre una pantalla nueva
class ObservadorSonoro extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) Sonidos.reproducir(Sonido.navegar);
  }
}

final enrutadorApp = GoRouter(
  initialLocation: '/carga',
  observers: [ObservadorSonoro()],
  routes: [
    GoRoute(path: '/carga', builder: (_, __) => const PantallaCarga()),
    GoRoute(path: '/bienvenida', builder: (_, __) => const PantallaBienvenida()),
    GoRoute(path: '/inicio-sesion', builder: (_, __) => const PantallaInicioSesion()),
    GoRoute(path: '/registro', builder: (_, __) => const PantallaRegistro()),
    GoRoute(path: '/olvide-contrasena', builder: (_, __) => const PantallaOlvideContrasena()),
    GoRoute(path: '/contrasena-actualizada', builder: (_, __) => const PantallaContrasenaActualizada()),

    // Alumno: 5 pestañas
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => EstructuraAlumno(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/alumno', builder: (_, __) => const PantallaInicioAlumno()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/alumno/explorar',
            builder: (_, s) => PantallaExplorar(initialCat: s.uri.queryParameters['cat']),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/alumno/actividades', builder: (_, __) => const PantallaMisActividades()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/alumno/avisos', builder: (_, __) => const PantallaAvisos()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/alumno/perfil', builder: (_, __) => const PantallaPerfil()),
        ]),
      ],
    ),

    // Pantalla completa (sin barra inferior)
    GoRoute(
      path: '/actividad/:id',
      builder: (_, s) =>
          PantallaDetalleActividad(tallerId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/inscripcion/:folio',
      builder: (_, s) =>
          PantallaInscripcionExitosa(folio: s.pathParameters['folio']!),
    ),
    GoRoute(path: '/perfil/academico', builder: (_, __) => const PantallaDatosAcademicos()),
    GoRoute(path: '/perfil/comprobantes', builder: (_, __) => const PantallaComprobantes()),
    GoRoute(path: '/perfil/progreso', builder: (_, __) => const PantallaProgreso()),
    GoRoute(path: '/perfil/favoritos', builder: (_, __) => const PantallaFavoritos()),
    GoRoute(path: '/perfil/idioma', builder: (_, __) => const PantallaIdioma()),
    GoRoute(path: '/perfil/privacidad', builder: (_, __) => const PantallaAvisoPrivacidad()),
    GoRoute(path: '/perfil/ayuda', builder: (_, __) => const PantallaAyuda()),
    GoRoute(path: '/perfil/editar', builder: (_, __) => const PantallaEditarPerfil()),
    GoRoute(path: '/perfil/configuracion', builder: (_, __) => const PantallaConfiguracion()),    // Instructor: 5 pestañas
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => EstructuraInstructor(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/instructor', builder: (_, __) => const PantallaInicioInstructor()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/instructor/grupos', builder: (_, __) => const PantallaGrupos()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/instructor/asistencia', builder: (_, __) => const PantallaAsistenciaPestana()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/instructor/avisos', builder: (_, __) => const PantallaAvisosInstructor()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/instructor/perfil', builder: (_, __) => const PantallaPerfilInstructor()),
        ]),
      ],
    ),
    GoRoute(
      path: '/instructor/grupo/:id',
      builder: (_, s) =>
          PantallaAlumnosGrupo(tallerId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/instructor/pasar-lista/:id',
      builder: (_, s) => PantallaPasarLista(
        tallerId: int.parse(s.pathParameters['id']!),
        fecha: DateTime.parse(s.uri.queryParameters['fecha']!),
      ),
    ),
    GoRoute(path: '/instructor/nuevo-aviso', builder: (_, __) => const PantallaNuevoAviso()),
       // Administrador: 5 pestañas
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => EstructuraAdmin(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/admin', builder: (_, __) => const PantallaInicioAdmin()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/admin/actividades', builder: (_, __) => const PantallaActividadesAdmin()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/admin/alumnos', builder: (_, __) => const PantallaAlumnosAdmin()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/admin/reportes', builder: (_, __) => const PantallaReportes()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/admin/perfil', builder: (_, __) => const PantallaPerfilAdmin()),
        ]),
      ],
    ),
    GoRoute(path: '/admin/actividad/nuevo', builder: (_, __) => const PantallaFormularioActividad()),
    GoRoute(
      path: '/admin/actividad/:id/editar',
      builder: (_, s) =>
          PantallaFormularioActividad(tallerId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(path: '/admin/instructores', builder: (_, __) => const PantallaInstructores()),
    GoRoute(path: '/admin/instructores/nuevo', builder: (_, __) => const PantallaNuevoInstructor()),
  ],
);