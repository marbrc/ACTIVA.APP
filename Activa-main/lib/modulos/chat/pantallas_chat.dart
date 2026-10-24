import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../datos/estado_app.dart';
import '../../datos/sesion.dart';
import '../../modelos/comunicacion.dart';
import '../../modelos/enums.dart';
import '../../modelos/taller.dart';
import '../../nucleo/componentes/avisos.dart';
import '../../nucleo/componentes/estructura_subpantalla.dart';
import '../../nucleo/componentes/tarjeta_app.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../nucleo/utilidades/formateadores.dart';
import '../../nucleo/utilidades/textos.dart';

String _hora(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

// ───────── Fondos disponibles ─────────
class _Fondo {
  const _Fondo(this.nombre, this.colores, {this.puntos = false});
  final String nombre;
  final List<Color> colores;
  final bool puntos;
}

const _fondos = <_Fondo>[
  _Fondo('Clásico', [Color(0xFFF2F7FE), Color(0xFFF2F7FE)]),
  _Fondo('Océano', [Color(0xFFD9EEFF), Color(0xFFBFE3FF)]),
  _Fondo('Atardecer', [Color(0xFFFFE6D5), Color(0xFFFFD1E0)]),
  _Fondo('Menta', [Color(0xFFDDF7EF), Color(0xFFC4EFE0)]),
  _Fondo('Lavanda', [Color(0xFFE8E2FF), Color(0xFFD3CBFA)]),
  _Fondo('Noche', [Color(0xFF0A3175), Color(0xFF05245A)]),
  _Fondo('Puntos', [Color(0xFFF2F7FE), Color(0xFFE6F0FD)], puntos: true),
  _Fondo('Arena', [Color(0xFFFFF4DC), Color(0xFFFFE9B8)]),
];

class _PuntosPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0x1A1B78E2);
    for (double y = 12; y < s.height; y += 28) {
      for (double x = (y ~/ 28).isEven ? 12 : 26; x < s.width; x += 28) {
        c.drawCircle(Offset(x, y), 2.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

BoxDecoration _decoFondo(_Fondo f) => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: f.colores,
  ),
);

// ───────── Lista de chats ─────────
class PantallaListaChats extends StatefulWidget {
  const PantallaListaChats({super.key});
  @override
  State<PantallaListaChats> createState() => _EstadoListaChats();
}

class _EstadoListaChats extends State<PantallaListaChats> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _anclar(EstadoApp s, Taller t) {
    if (!s.toggleAnclarChat(t.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(
          content: const Text('Solo puedes anclar 3 chats'),
          tipo: TipoToast.advertencia,
        ),
      );
    }
  }

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
    child: Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.w800, color: ColoresApp.navy, fontSize: 13)),
  );

  Widget _tarjeta(EstadoApp s, Taller t) {
    final ultimo = s.ultimoMensaje(t.id);
    final fijo = s.chatAnclado(t.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TarjetaApp(
        onTap: () => context.push('/chat/${t.id}'),
        child: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: t.categoria.color.withValues(alpha: 0.15),
            child: Icon(Icons.groups_rounded, color: t.categoria.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                ultimo == null
                    ? 'Sé el primero en escribir'
                    : '${ultimo.autor.split(' ').first}: ${ultimo.texto}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (ultimo != null)
              Text(_hora(ultimo.fecha),
                  style: const TextStyle(color: Colors.black45, fontSize: 11)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _anclar(s, t),
              child: Icon(
                fijo ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 20,
                color: fijo ? ColoresApp.primary : Colors.black38,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
    final s = context.watch<EstadoApp>();
    final q = _q.text.trim().toLowerCase();
    final todos = s
        .chatsOrdenados(rol)
        .where((t) => t.nombre.toLowerCase().contains(q))
        .toList();
    final fijos = todos.where((t) => s.chatAnclado(t.id)).toList();
    final resto = todos.where((t) => !s.chatAnclado(t.id)).toList();

    return EstructuraSubpantalla(
      title: context.tr('perfil.chats'),
      fallback: EstadoSesion.rutaDe(rol),
      child: s.chatsDe(rol).isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no tienes chats. Al inscribirte a un club podrás platicar con tu grupo aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _q,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar chat',
                  ),
                ),
                const SizedBox(height: 12),
                if (todos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Center(child: Text('Sin resultados')),
                  ),
                if (fijos.isNotEmpty) ...[
                  _titulo('📌 Anclados'),
                  for (final t in fijos) _tarjeta(s, t),
                ],
                if (resto.isNotEmpty) ...[
                  if (fijos.isNotEmpty) _titulo('Todos los chats'),
                  for (final t in resto) _tarjeta(s, t),
                ],
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
    context.read<EstadoApp>().enviarMensaje(tallerId: widget.tallerId, rol: rol, texto: t);
    _texto.clear();
  }

  void _elegirFondo(EstadoApp s) {
    final actual = s.fondoChat(widget.tallerId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Fondo del chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          const SizedBox(height: 16),
          Wrap(spacing: 16, runSpacing: 16, children: [
            for (final (i, f) in _fondos.indexed)
              GestureDetector(
                onTap: () {
                  s.ponerFondoChat(widget.tallerId, i);
                  Navigator.pop(ctx);
                },
                child: Column(children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: f.colores),
                      border: Border.all(
                        color: i == actual ? ColoresApp.primary : ColoresApp.line,
                        width: i == actual ? 3 : 1.5,
                      ),
                    ),
                    child: i == actual
                        ? const Icon(Icons.check_rounded, color: ColoresApp.primary)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(f.nombre, style: const TextStyle(fontSize: 11)),
                ]),
              ),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _separador(DateTime d) {
    final hoy = DateTime.now();
    final txt = mismoDia(d, hoy)
        ? 'Hoy'
        : mismoDia(d, hoy.subtract(const Duration(days: 1)))
        ? 'Ayer'
        : fechaConDia(d);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(txt, style: const TextStyle(color: ColoresApp.muted, fontSize: 11)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
    final s = context.watch<EstadoApp>();
    final t = s.tallerPorId(widget.tallerId);
    final yo = s.nombreChat(rol);
    final fijo = s.chatAnclado(t.id);
    final fondo = _fondos[s.fondoChat(t.id).clamp(0, _fondos.length - 1)];
    final orden = s.mensajesDe(t.id); // del más viejo al más nuevo
    final mensajes = orden.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ColoresApp.navy,
              side: const BorderSide(color: ColoresApp.line),
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
            onPressed: () => context.canPop() ? context.pop() : context.go('/chats'),
          ),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.nombre, style: const TextStyle(fontSize: 17)),
          Text('${s.alumnosDe(t.id).length + 1} integrantes',
              style: const TextStyle(fontSize: 11, color: ColoresApp.muted)),
        ]),
        actions: [
          IconButton(
            tooltip: fijo ? 'Desanclar' : 'Anclar chat',
            icon: Icon(fijo ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: fijo ? ColoresApp.primary : null),
            onPressed: () {
              if (!s.toggleAnclarChat(t.id)) {
                ScaffoldMessenger.of(context).showSnackBar(avisoSnack(
                  content: const Text('Solo puedes anclar 3 chats'),
                  tipo: TipoToast.advertencia,
                ));
              }
            },
          ),
          IconButton(
            tooltip: 'Fondo del chat',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _elegirFondo(s),
          ),
        ],
      ),
      body: Container(
        decoration: _decoFondo(fondo),
        child: CustomPaint(
          painter: fondo.puntos ? _PuntosPainter() : null,
          child: SafeArea(
            child: Column(children: [
              Expanded(
                child: mensajes.isEmpty
                    ? const Center(
                        child: Text('Todavía no hay mensajes 👋',
                            style: TextStyle(color: Colors.black54)))
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: mensajes.length,
                        itemBuilder: (_, i) {
                          final m = mensajes[i];
                          final primeroDelDia = i == mensajes.length - 1 ||
                              !mismoDia(mensajes[i + 1].fecha, m.fecha);
                          return Column(children: [
                            if (primeroDelDia) _separador(m.fecha),
                            _Burbuja(mensaje: m, mio: m.rol == rol && m.autor == yo),
                          ]);
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: ColoresApp.line)),
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _texto,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _enviar(rol),
                      decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _enviar(rol),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ]),
              ),
            ]),
          ),
        ),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  color: esInstructor || esAdmin ? ColoresApp.teal : ColoresApp.navy,
                ),
              ),
            ),
          Text(mensaje.texto,
              style: TextStyle(color: mio ? Colors.white : ColoresApp.ink, height: 1.3)),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_hora(mensaje.fecha),
                style: TextStyle(fontSize: 10, color: mio ? Colors.white70 : Colors.black38)),
          ),
        ]),
      ),
    );
  }
}