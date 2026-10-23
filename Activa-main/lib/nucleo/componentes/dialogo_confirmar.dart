import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../datos/sesion.dart';
import '../tema/tema_app.dart';

/// Muestra la ventanita y devuelve true si la persona confirmó.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Confirmar',
  String textoCancelar = 'Cancelar',
  IconData icono = Icons.help_outline_rounded,
  bool peligro = false,
}) async {
  final color = peligro ? ColoresApp.danger : ColoresApp.primary;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      icon: CircleAvatar(
        radius: 26,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icono, color: color, size: 28),
      ),
      title: Text(
        titulo,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: ColoresApp.navy,
          fontSize: 20,
        ),
      ),
      content: Text(
        mensaje,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: 8,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(110, 46),
            shape: const StadiumBorder(),
          ),
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: Text(textoCancelar),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(110, 46),
            shape: const StadiumBorder(),
            backgroundColor: color,
          ),
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Pregunta "¿Cerrar sesión?" y, si confirma, sale a la bienvenida.
Future<void> cerrarSesionConfirmando(BuildContext context) async {
  final ok = await confirmarAccion(
    context,
    titulo: '¿Cerrar sesión?',
    mensaje: 'Tendrás que iniciar sesión otra vez para entrar a ACTIVA.',
    textoConfirmar: 'Cerrar sesión',
    icono: Icons.logout_rounded,
    peligro: true,
  );
  if (!ok || !context.mounted) return;
  context.read<EstadoSesion>().cerrarSesion();
  context.go('/bienvenida');
}