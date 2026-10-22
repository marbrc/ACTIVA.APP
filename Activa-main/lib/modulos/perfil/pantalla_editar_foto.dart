// ===================================================================
// pantalla_editar_foto.dart
// aqui la usuaria elige una foto (galeria o camara), la recorta con
// los dedos (mover y pellizcar), la gira, le pone filtros y brillo
// y al final se guarda como su foto de perfil. sirve para los 3 roles
// ===================================================================

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../datos/sesion.dart';
import '../../modelos/enums.dart';
import '../../nucleo/componentes/avatar_activa.dart';
import '../../nucleo/componentes/avisos.dart';
import '../../nucleo/componentes/boton_activa.dart';
import '../../nucleo/componentes/estructura_subpantalla.dart';
import '../../nucleo/tema/tema_app.dart';

// un filtro = nombre + matriz de color (20 numeros)
class _Filtro {
  final String nombre;
  final List<double> matriz;
  const _Filtro(this.nombre, this.matriz);
}

// matriz para subir o bajar la saturacion
List<double> _saturacion(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  return [
    r * (1 - s) + s,
    g * (1 - s),
    b * (1 - s),
    0,
    0,
    r * (1 - s),
    g * (1 - s) + s,
    b * (1 - s),
    0,
    0,
    r * (1 - s),
    g * (1 - s),
    b * (1 - s) + s,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

final _filtros = <_Filtro>[
  const _Filtro('Original', [
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]),
  _Filtro('Vívido', _saturacion(1.6)),
  _Filtro('B y N', _saturacion(0)),
  const _Filtro('Sepia', [
    0.393,
    0.769,
    0.189,
    0,
    0,
    0.349,
    0.686,
    0.168,
    0,
    0,
    0.272,
    0.534,
    0.131,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]),
  const _Filtro('Frío', [
    0.9,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1.15,
    0,
    10,
    0,
    0,
    0,
    1,
    0,
  ]),
  const _Filtro('Cálido', [
    1.1,
    0,
    0,
    0,
    10,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0.88,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]),
  const _Filtro('Suave', [
    0.82,
    0,
    0,
    0,
    28,
    0,
    0.82,
    0,
    0,
    28,
    0,
    0,
    0.82,
    0,
    28,
    0,
    0,
    0,
    1,
    0,
  ]),
  const _Filtro('Contraste', [
    1.3,
    0,
    0,
    0,
    -38,
    0,
    1.3,
    0,
    0,
    -38,
    0,
    0,
    1.3,
    0,
    -38,
    0,
    0,
    0,
    1,
    0,
  ]),
];

class PantallaEditarFoto extends StatefulWidget {
  const PantallaEditarFoto({super.key});
  @override
  State<PantallaEditarFoto> createState() => _EstadoPantallaEditarFoto();
}

class _EstadoPantallaEditarFoto extends State<PantallaEditarFoto> {
  Uint8List? _bytes; // la foto original elegida
  int _ancho = 0, _alto = 0; // tamaño real de la foto
  int _filtro = 0; // filtro elegido
  double _brillo = 0; // de -0.3 a 0.3
  bool _guardando = false;

  final _ctrl = TransformationController(); // mover y zoom
  final _clave = GlobalKey(); // para tomar la "captura" del recorte

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // lado del cuadro de recorte segun el ancho de la pantalla
  double get _lado =>
      (MediaQuery.of(context).size.width - 48).clamp(220.0, 320.0).toDouble();

  // escala para que la foto cubra todo el cuadro (tipo cover)
  double get _k => _lado / math.min(_ancho, _alto);

  Rol get _rol => context.read<EstadoSesion>().rol ?? Rol.alumno;

  // abre galeria o camara
  Future<void> _elegir(ImageSource fuente) async {
    try {
      final x = await ImagePicker().pickImage(source: fuente);
      if (x == null) return; // cancelo
      await _cargar(await x.readAsBytes());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: const Text('No se pudo abrir la foto')),
      );
    }
  }

  // lee el tamaño de la foto y la deja centrada en el recorte
  Future<void> _cargar(Uint8List datos) async {
    final img = await decodeImageFromList(datos);
    if (!mounted) return;
    setState(() {
      _bytes = datos;
      _ancho = img.width;
      _alto = img.height;
      _filtro = 0;
      _brillo = 0;
    });
    final cw = _ancho * _k, ch = _alto * _k;
    _ctrl.value = Matrix4.identity()
      ..setTranslationRaw(-(cw - _lado) / 2, -(ch - _lado) / 2, 0);
  }

  // gira la foto 90 grados a la derecha
  Future<void> _girar() async {
    final src = await decodeImageFromList(_bytes!);
    final grabador = ui.PictureRecorder();
    final lienzo = Canvas(grabador);
    lienzo.translate(src.height.toDouble(), 0);
    lienzo.rotate(math.pi / 2);
    lienzo.drawImage(src, Offset.zero, Paint());
    final nueva = await grabador.endRecording().toImage(src.height, src.width);
    final datos = await nueva.toByteData(format: ui.ImageByteFormat.png);
    if (datos == null) return;
    await _cargar(datos.buffer.asUint8List());
  }

  // toma la captura del cuadro (con filtro y brillo) y la guarda
  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final caja =
          _clave.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await caja.toImage(pixelRatio: 2.5);
      final datos = await img.toByteData(format: ui.ImageByteFormat.png);
      if (datos == null) throw Exception('sin datos');
      if (!mounted) return;
      context.read<EstadoSesion>().guardarFoto(
        _rol,
        datos.buffer.asUint8List(),
      );
      final m = ScaffoldMessenger.of(context);
      context.pop();
      m.showSnackBar(
        avisoSnack(content: const Text('Foto de perfil actualizada')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: const Text('No se pudo guardar la foto')),
      );
    }
  }

  // matriz de brillo (solo suma a rojo, verde y azul)
  List<double> get _matrizBrillo {
    final o = _brillo * 255;
    return [1, 0, 0, 0, o, 0, 1, 0, 0, o, 0, 0, 1, 0, o, 0, 0, 0, 1, 0];
  }

  // ---------- paso 1: elegir foto ----------
  Widget _vistaElegir() {
    final tiene = context.watch<EstadoSesion>().fotoDe(_rol) != null;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        Center(
          child: AvatarActiva(
            rol: _rol,
            iniciales: 'MAR',
            radio: 64,
            borde: true,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Tu foto de perfil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ColoresApp.navy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Elige una foto, recórtala y ponle el filtro que más te guste.',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColoresApp.muted),
        ),
        const SizedBox(height: 28),
        BotonActiva(
          etiqueta: 'Elegir de la galería',
          icono: Icons.photo_library_rounded,
          alPresionar: () => _elegir(ImageSource.gallery),
        ),
        const SizedBox(height: 14),
        BotonActiva(
          etiqueta: 'Tomar una foto',
          icono: Icons.photo_camera_rounded,
          variante: VarianteBoton.contorno,
          alPresionar: () => _elegir(ImageSource.camera),
        ),
        if (tiene) ...[
          const SizedBox(height: 14),
          BotonActiva(
            etiqueta: 'Quitar foto actual',
            icono: Icons.delete_outline_rounded,
            variante: VarianteBoton.contorno,
            alPresionar: () {
              context.read<EstadoSesion>().quitarFoto(_rol);
              ScaffoldMessenger.of(context).showSnackBar(
                avisoSnack(
                  content: const Text('Foto eliminada, cambios guardados'),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // ---------- paso 2: recortar y filtros ----------
  Widget _vistaEditor() {
    final lado = _lado;
    final cw = _ancho * _k, ch = _alto * _k;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      children: [
        const Text(
          'Mueve y pellizca para recortar',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColoresApp.muted),
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: lado,
            height: lado,
            child: Stack(
              children: [
                // esta parte es la que se guarda
                RepaintBoundary(
                  key: _clave,
                  child: ClipRect(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_matrizBrillo),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(
                          _filtros[_filtro].matriz,
                        ),
                        child: SizedBox(
                          width: lado,
                          height: lado,
                          child: InteractiveViewer(
                            transformationController: _ctrl,
                            constrained: false,
                            minScale: 1,
                            maxScale: 4,
                            boundaryMargin: EdgeInsets.zero,
                            child: SizedBox(
                              width: cw,
                              height: ch,
                              child: Image.memory(
                                _bytes!,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // guia circular (no se guarda, solo es de ayuda)
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(lado, lado),
                    painter: _GuiaCircular(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        // lista de filtros con miniatura
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filtros.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final activo = i == _filtro;
              return GestureDetector(
                onTap: () => setState(() => _filtro = i),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activo
                              ? ColoresApp.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 58,
                          height: 58,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(_filtros[i].matriz),
                            child: Image.memory(
                              _bytes!,
                              fit: BoxFit.cover,
                              cacheWidth: 160,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _filtros[i].nombre,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
                        color: activo ? ColoresApp.primary : ColoresApp.muted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // brillo
        Row(
          children: [
            const Icon(Icons.wb_sunny_outlined, color: ColoresApp.primary),
            Expanded(
              child: Slider(
                value: _brillo,
                min: -0.3,
                max: 0.3,
                onChanged: (v) => setState(() => _brillo = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: BotonActiva(
                etiqueta: 'Girar',
                icono: Icons.rotate_right_rounded,
                variante: VarianteBoton.contorno,
                alPresionar: _girar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonActiva(
                etiqueta: 'Otra foto',
                icono: Icons.image_outlined,
                variante: VarianteBoton.contorno,
                alPresionar: () => setState(() => _bytes = null),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        BotonActiva(
          etiqueta: 'Guardar foto',
          icono: Icons.check_rounded,
          cargando: _guardando,
          alPresionar: _guardar,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return EstructuraSubpantalla(
      title: 'Foto de perfil',
      fallback: '/alumno',
      // cambia entre los 2 pasos con un fundido
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(_bytes == null),
          child: _bytes == null ? _vistaElegir() : _vistaEditor(),
        ),
      ),
    );
  }
}

// dibuja la sombra oscura con un hoyo redondo en medio
class _GuiaCircular extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final todo = Path()..addRect(Offset.zero & size);
    final hoyo = Path()
      ..addOval(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: size.width / 2 - 2,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, todo, hoyo),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2 - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
