// ===================================================================
// Hace que un widget aparezca poco a poco y deslizándose hacia arriba
// ===================================================================

// widget de Flutter
import 'package:flutter/material.dart';

// necesita estado porque maneja una animación
class AparicionSuave extends StatefulWidget {
  const AparicionSuave({
    super.key,
    // el widget que va a aparecer con animación
    required this.child,
    // cuanto espera antes de empezar (para que entren uno tras otro)
    this.delay = Duration.zero,
    // cuantos pixeles sube mientras aparece
    this.dy = 24,
    //cuanto dura la animación
    this.duration = const Duration(milliseconds: 700),
  });

  final Widget child;
  final Duration delay;
  final double dy;
  final Duration duration;

  @override
  State<AparicionSuave> createState() => _EstadoAparicionSuave();
}

// SingleTickerProviderStateMixin le da el "reloj" a la animación
class _EstadoAparicionSuave extends State<AparicionSuave>
    with SingleTickerProviderStateMixin {
  // el controlador avanza la animación de 0 a 1
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  // curva empieza rápido y termina suave
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    // espera el delay y luego arranca la animación
    Future.delayed(widget.delay, () {
      // mounted revisa que la pantalla siga abierta
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    // libera el controlador al cerrar la pantalla
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    // se redibuja cada vez que cambia la animación
    animation: _a,
    // el child se pasa aparte para que no se reconstruya cada vez
    child: widget.child,
    builder: (_, child) => Opacity(
      // de invisible (0) a visible (1)
      opacity: _a.value,
      child: Transform.translate(
        // empieza dy pixeles más abajo y sube hasta su lugar
        offset: Offset(0, (1 - _a.value) * widget.dy),
        child: child,
      ),
    ),
  );
}
