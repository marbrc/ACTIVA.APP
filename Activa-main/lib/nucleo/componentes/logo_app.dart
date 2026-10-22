// ===================================================================
// Logo real de ACTIVA (assets/images/logo_activa.png)
// glow = brillo azul alrededor, hero = "viaja" entre pantallas
// ===================================================================

import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

class LogoApp extends StatelessWidget {
  const LogoApp({
    super.key,
    this.size = 56,
    this.glow = false,
    this.hero = false,
  });

  final double size;
  final bool glow;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: glow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.24),
              boxShadow: [
                BoxShadow(
                  color: ColoresApp.wave.withValues(alpha: 0.45),
                  blurRadius: size * 0.35,
                  offset: Offset(0, size * 0.12),
                ),
              ],
            )
          : null,
      child: Image.asset(
        'assets/images/logo_activa.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        // Si por algo no carga la imagen, muestra un ícono
        errorBuilder: (_, _, _) => Icon(
          Icons.directions_run,
          size: size * 0.6,
          color: ColoresApp.primary,
        ),
      ),
    );
    return hero ? Hero(tag: 'activa-logo', child: logo) : logo;
  }
}
