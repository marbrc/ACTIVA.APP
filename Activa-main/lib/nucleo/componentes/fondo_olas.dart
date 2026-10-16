// ===================================================================
// Fondo degradado azul con olas suaves, inspirado en la ola del logo
// ===================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tema/tema_app.dart';

class FondoOlas extends StatefulWidget {
  const FondoOlas({
    super.key,
    required this.child,
    this.animar = true,
    this.nivelOlas = 0.74,
  });

  final Widget child;
  // Si las olas se mueven o se quedan quietas
  final bool animar;
  // Altura de las olas (0 = arriba, 1 = abajo)
  final double nivelOlas;

  @override
  State<FondoOlas> createState() => _EstadoFondoOlas();
}

class _EstadoFondoOlas extends State<FondoOlas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12));

  @override
  void initState() {
    super.initState();
    if (widget.animar) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(gradient: ColoresApp.heroGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _PintorOlas(_c, widget.nivelOlas)),
              ),
            ),
            widget.child,
          ],
        ),
      );
}

class _PintorOlas extends CustomPainter {
  _PintorOlas(this.t, this.nivel) : super(repaint: t);
  final Animation<double> t;
  final double nivel;

  @override
  void paint(Canvas canvas, Size size) {
    final fase = t.value * 2 * math.pi;

    // Brillo suave arriba a la derecha
    final brillo = Paint()
      ..shader = RadialGradient(
        colors: [ColoresApp.wave.withValues(alpha: 0.35), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.05),
        radius: size.width * 0.8,
      ));
    canvas.drawRect(Offset.zero & size, brillo);

    _ola(canvas, size, nivel, 18, fase, ColoresApp.wave.withValues(alpha: 0.14));
    _ola(canvas, size, nivel + 0.07, 22, -fase + 1.8,
        ColoresApp.sky.withValues(alpha: 0.10));
  }

  void _ola(Canvas c, Size s, double base, double amp, double fase, Color color) {
    final camino = Path()..moveTo(0, s.height);
    for (double x = 0; x <= s.width; x += 6) {
      final y = s.height * base +
          amp * math.sin((x / s.width) * 2 * math.pi + fase);
      camino.lineTo(x, y);
    }
    camino
      ..lineTo(s.width, s.height)
      ..close();
    c.drawPath(camino, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PintorOlas old) => false;
}
