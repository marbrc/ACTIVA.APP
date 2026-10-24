import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../datos/estado_app.dart';
import '../../datos/sesion.dart';
import '../../modelos/comunicacion.dart';
import '../../modelos/enums.dart';
import '../tema/tema_app.dart';
import 'tarjeta_app.dart';

/// Tarjeta de acceso directo a los chats grupales (alumno, instructor y admin).
class AccesoChats extends StatelessWidget {
  const AccesoChats({super.key});

  @override
  Widget build(BuildContext context) {
    final rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
    final s = context.watch<EstadoApp>();
    final chats = s.chatsDe(rol);
    final ultimo = chats
        .map((t) => s.ultimoMensaje(t.id))
        .whereType<MensajeChat>()
        .fold<MensajeChat?>(null, (a, m) => a == null || m.fecha.isAfter(a.fecha) ? m : a);

    return TarjetaApp(
      onTap: () => context.push('/chats'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_rounded, color: ColoresApp.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chats grupales',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  chats.isEmpty
                      ? 'Inscríbete a un club para chatear'
                      : ultimo == null
                      ? '${chats.length} ${chats.length == 1 ? 'grupo' : 'grupos'}'
                      : '${ultimo.autor.split(' ').first}: ${ultimo.texto}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: ColoresApp.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: ColoresApp.muted),
        ],
      ),
    );
  }
}