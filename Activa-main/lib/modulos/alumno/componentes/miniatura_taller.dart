// ===================================================================
// MiniaturaTaller (cuadrito) y BannerTaller (imagen grande) de cada actividad.
// Si existe una foto real en assets/images/talleres/<nombre>.jpg la usan;
// si no, dibujan el degradado con el ícono de la categoría.
// Ejemplos de nombre de archivo: voleibol.jpg, futbol_soccer.jpg,
// danza_folclorica.jpg, ajedrez.jpg, teatro.jpg, zumba.jpg
// ===================================================================

import 'package:flutter/material.dart';
import '../../../modelos/categoria.dart';
import '../../../modelos/taller.dart';

// Convierte "Fútbol soccer" en "futbol_soccer" (nombre del archivo de la foto)
String nombreArchivoFoto(String nombre) {
  const de = 'áàäâéèëêíìïîóòöôúùüûñ';
  const a = 'aaaaeeeeiiiioooouuuun';
  var s = nombre.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    s = s.replaceAll(de[i], a[i]);
  }
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return s.replaceAll(RegExp(r'^_+|_+$'), '');
}

String rutaFotoTaller(Taller t) =>
    'assets/images/talleres/${nombreArchivoFoto(t.nombre)}.jpg';

// cuadrito pequeño con la foto (o el ícono) de la actividad
class MiniaturaTaller extends StatelessWidget {
  const MiniaturaTaller(this.taller, {super.key, this.size = 56});
  final Taller taller;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = taller.categoria;
    final radio = BorderRadius.circular(18);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radio,
        boxShadow: [
          BoxShadow(
            color: c.color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radio,
        child: Image.asset(
          rutaFotoTaller(taller),
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Si no hay foto, usa el degradado con ícono
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.color, Color.lerp(c.color, Colors.black, 0.25)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(iconoDe(c.icono), color: Colors.white, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

// banner grande que va arriba de las tarjetas
class BannerTaller extends StatelessWidget {
  const BannerTaller(this.taller, {super.key, this.height = 110, this.child});
  final Taller taller;
  final double height;
  // Widget extra encima (ej. el corazón), debe ser un Positioned
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = taller.categoria;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            rutaFotoTaller(taller),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.color, Color.lerp(c.color, Colors.black, 0.3)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -20,
                    top: -24,
                    child: _Circulo(size: height * 0.9, alpha: 0.10),
                  ),
                  Positioned(
                    right: -14,
                    bottom: -30,
                    child: _Circulo(size: height * 0.8, alpha: 0.12),
                  ),
                  Center(
                    child: Icon(
                      iconoDe(c.icono),
                      size: height * 0.45,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sombrita abajo para que el texto/botones se lean sobre la foto
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

// círculo blanco transparente, solo adorno
class _Circulo extends StatelessWidget {
  const _Circulo({required this.size, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}
