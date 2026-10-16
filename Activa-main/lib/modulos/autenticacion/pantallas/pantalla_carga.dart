// ===================================================================
// Pantalla de CARGA (splash): logo, lema y barra de progreso.
// Al terminar manda a la pantalla de bienvenida.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/fondo_olas.dart';
import '../../../nucleo/componentes/logo_app.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _EstadoPantallaCarga();
}

class _EstadoPantallaCarga extends State<PantallaCarga>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) context.go('/bienvenida');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoOlas(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // El logo crece con un pequeño rebote
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: const LogoApp(size: 150, glow: true, hero: true),
                ),
                const SizedBox(height: 26),
                const Text(
                  'ACTIVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conecta · Participa · Vive tu universidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresApp.sky.withValues(alpha: 0.95),
                    fontSize: 12.5,
                  ),
                ),
                const Spacer(flex: 3),
                AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) => Column(
                    children: [
                      Text(
                        'Cargando tu experiencia…',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: Curves.easeInOut.transform(_c.value),
                          minHeight: 6,
                          color: ColoresApp.sky,
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(Curves.easeInOut.transform(_c.value) * 100).round()}%',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
