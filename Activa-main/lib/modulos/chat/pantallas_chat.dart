import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../datos/estado_app.dart';
import '../../datos/sesion.dart';
import '../../modelos/comunicacion.dart';
import '../../modelos/enums.dart';
import '../../nucleo/componentes/estructura_subpantalla.dart';
import '../../nucleo/componentes/tarjeta_app.dart';
import '../../nucleo/tema/tema_app.dart';

String _hora(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

// ───────── Lista de chats ─────────
class PantallaListaChats extends StatelessWidget {
  const PantallaListaChats({super.key});

  @override
  Widget build(BuildContext context) {
    final rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
    final s = context.watch<EstadoApp>();
    final chats = s.chatsDe(rol);

    return EstructuraSubpantalla(
      title: 'Chats grupales',
      fallback: EstadoSesion.rutaDe(rol),
      child: chats.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no tienes chats. Al inscribirte a un club podrás '
                  'platicar con tu grupo aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final t in chats)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Builder(
                      builder: (_) {
                        final ultimo = s.ultimoMensaje(t.id);
                        return TarjetaApp(
                          onTap: () => context.push('/chat/${t.id}'),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: t.categoria.color.withValues(
                                  alpha: 0.15,
                                ),
                                child: Icon(
                                  Icons.groups_rounded,
                                  color: t.categoria.color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ultimo == null
                                          ? 'Sé el primero en escribir'
                                          : '${ultimo.autor.split(' ').first}: ${ultimo.texto}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (ultimo != null)
                                Text(
                                  _hora(ultimo.fecha),
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

// ───────── Conversación ─────────
class PantallaChatGrupal extends StatefulWidget {
  const PantallaChatGrupal({super.key, required this.tallerId});
  final int tallerId;

  @override
  State<PantallaChatGrupal> createState() => _EstadoChatGrupal();
}

class _EstadoChatGrupal extends State<PantallaChatGrupal> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _enviar(Rol rol) {
    final t = _texto.text.trim();
    if (t.isEmpty) return;
    context.read<EstadoApp>().enviarMensaje(
      tallerId: widget.tallerId,
      rol: rol,
      texto: t,
    );
    _texto.clear();
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
    final s = context.watch<EstadoApp>();
    final t = s.tallerPorId(widget.tallerId);
    final yo = s.nombreChat(rol);
    // reverse: true -> el mensaje más nuevo queda abajo
    final mensajes = s.mensajesDe(t.id).reversed.toList();

    return EstructuraSubpantalla(
      title: t.nombre,
      fallback: '/chats',
      child: Column(
        children: [
          Expanded(
            child: mensajes.isEmpty
                ? const Center(
                    child: Text(
                      'Todavía no hay mensajes 👋',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: mensajes.length,
                    itemBuilder: (_, i) {
                      final m = mensajes[i];
                      return _Burbuja(
                        mensaje: m,
                        mio: m.rol == rol && m.autor == yo,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: ColoresApp.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _enviar(rol),
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _enviar(rol),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje, required this.mio});
  final MensajeChat mensaje;
  final bool mio;

  @override
  Widget build(BuildContext context) {
    final esInstructor = mensaje.rol == Rol.instructor;
    final esAdmin = mensaje.rol == Rol.admin;
    return Align(
      alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          color: mio ? ColoresApp.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mio ? 18 : 4),
            bottomRight: Radius.circular(mio ? 4 : 18),
          ),
          border: mio ? null : Border.all(color: ColoresApp.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!mio)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  esInstructor
                      ? '${mensaje.autor} · Instructor'
                      : esAdmin
                      ? '${mensaje.autor} · Admin'
                      : mensaje.autor,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: esInstructor || esAdmin
                        ? ColoresApp.teal
                        : ColoresApp.navy,
                  ),
                ),
              ),
            Text(
              mensaje.texto,
              style: TextStyle(
                color: mio ? Colors.white : ColoresApp.ink,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _hora(mensaje.fecha),
                style: TextStyle(
                  fontSize: 10,
                  color: mio ? Colors.white70 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}