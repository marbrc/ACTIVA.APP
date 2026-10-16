// ===================================================================
// Avisos bonitos (reemplazan al SnackBar normal) con ícono y sonido.
// Se usan igual que antes:
//   ScaffoldMessenger.of(context).showSnackBar(avisoSnack(content: Text('...')));
// El tipo (éxito, error, info) se detecta por las palabras del mensaje.
// ===================================================================

import 'package:flutter/material.dart';
import '../servicios/sonidos.dart';
import '../tema/tema_app.dart';

enum TipoToast { exito, error, advertencia, info }

// Adivina el tipo de aviso a partir del texto
TipoToast _tipoDe(String texto) {
  final t = texto.toLowerCase();
  const error = ['incorrect', 'error', 'no se pudo', 'inválid', 'invalid'];
  const exito = [
    'creada', 'creado', 'agregad', 'guardad', 'publicad',
    'actualizad', 'generad', 'cambios', 'te diste de baja',
  ];
  const advertencia = ['acepta', 'próximamente', 'proximamente', 'simulad', 'requerid'];
  if (error.any(t.contains)) return TipoToast.error;
  if (advertencia.any(t.contains)) return TipoToast.advertencia;
  if (exito.any(t.contains)) return TipoToast.exito;
  return TipoToast.info;
}

SnackBar avisoSnack({
  required Widget content,
  Duration duration = const Duration(seconds: 3),
}) {
  final texto = content is Text ? (content.data ?? '') : '';
  final tipo = _tipoDe(texto);

  // Sonido según el tipo de aviso
  Sonidos.reproducir(switch (tipo) {
    TipoToast.exito => Sonido.exito,
    TipoToast.error => Sonido.error,
    _ => Sonido.aviso,
  });

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: duration,
    content: _CuerpoAviso(texto: texto, tipo: tipo),
  );
}

class _CuerpoAviso extends StatelessWidget {
  const _CuerpoAviso({required this.texto, required this.tipo});
  final String texto;
  final TipoToast tipo;

  @override
  Widget build(BuildContext context) {
    final (color, icono) = switch (tipo) {
      TipoToast.exito => (ColoresApp.teal, Icons.check_rounded),
      TipoToast.error => (ColoresApp.danger, Icons.close_rounded),
      TipoToast.advertencia => (ColoresApp.warning, Icons.schedule_rounded),
      TipoToast.info => (ColoresApp.wave, Icons.info_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColoresApp.deep, ColoresApp.navy],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.deep.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // El ícono "salta" un poquito al aparecer
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
