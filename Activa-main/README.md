# ACTIVA

**Activación de Clubes y Talleres Institucionales para la Vida Académica** (UTNG).
App móvil hecha con Flutter para consultar actividades, inscribirse, pasar lista y administrar clubes y talleres.

## Cómo correrla

```
flutter pub get
flutter run
```
(Después de cambiar assets o paquetes usa Stop y Run completo, no hot reload.)

## Estructura del código (todo en español)

```
lib/
  aplicacion.dart            App principal (idioma español)
  main.dart
  nucleo/
    tema/tema_app.dart       Colores del logo, tipografía Century, transiciones y sonido al tocar
    rutas/rutas_app.dart     Pantallas y rutas (/carga, /bienvenida, /alumno, /instructor, /admin ...)
    servicios/sonidos.dart   Sonidos de la app
    componentes/             Botón, tarjeta, logo, fondo de olas, avisos, estructuras
    utilidades/
  datos/                     Estado de la app y datos de ejemplo
  modelos/                   Taller, Categoria, Usuario, Inscripcion...
  modulos/
    autenticacion/           Carga, bienvenida, inicio de sesión, registro, recuperar contraseña
    alumno/                  Inicio, explorar, detalle, mis actividades, avisos, perfil, favoritos, ayuda
    instructor/              Grupos, asistencia, avisos
    administrador/           Panel, actividades, alumnos, reportes
assets/
  images/logo_activa.png     Logo
  images/talleres/           Fotos reales de los clubes (ver LEEME.txt)
  fonts/                     Tipografía Century
  sounds/                    Sonidos (.wav)
```

## Fotos de los clubes
Guarda las fotos en `assets/images/talleres/` con el nombre del club en minúsculas y sin acentos
(`voleibol.jpg`, `futbol_soccer.jpg`, `ajedrez.jpg`...). Si falta alguna, se muestra el degradado con ícono.

## Tipografía Century
Los archivos de `assets/fonts/` son una fuente libre muy parecida a Century Gothic.
Para usar la original, copia `GOTHIC.TTF` y `GOTHICB.TTF` de `C:\Windows\Fonts` a `assets/fonts/`
y cambia los nombres en la sección `fonts:` de `pubspec.yaml`.
