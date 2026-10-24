import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/estilo_aviso.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../datos/estado_app.dart';
import '../../../modelos/enums.dart';
import '../../../nucleo/componentes/avisos.dart';

import '../../../nucleo/componentes/dialogo_confirmar.dart';

import '../../../nucleo/componentes/accesos_rapidos.dart';

import '../../../modelos/inscripcion.dart';

class PantallaAvisosInstructor extends StatefulWidget {
  const PantallaAvisosInstructor({super.key, this.conAtras = false});
  final bool conAtras;
  @override
  State<PantallaAvisosInstructor> createState() => _EstadoAvisosInstructor();
}

class _EstadoAvisosInstructor extends State<PantallaAvisosInstructor> {
  int _vista = 0; // 0 recientes, 1 historial
  final _buscar = TextEditingController();
  int? _grupo;
  TipoAviso? _tipo;
  final Set<int> _abiertos = {};

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  Future<bool> _preguntar() => confirmarAccion(
    context,
    titulo: '¿Eliminar aviso?',
    mensaje: 'Los alumnos dejarán de verlo.',
    textoConfirmar: 'Eliminar',
    icono: Icons.delete_outline_rounded,
    peligro: true,
  );

  void _borrar(EstadoApp s, Aviso a) {
    final quitado = s.eliminarAviso(a.id);
    if (quitado == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Aviso eliminado'),
        action: SnackBarAction(label: 'Deshacer', onPressed: () => s.restaurarAviso(quitado)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final todos = s.avisosPublicados..sort((x, y) => y.fecha.compareTo(x.fecha));
    final q = _buscar.text.trim().toLowerCase();
    final hace7 = DateTime.now().subtract(const Duration(days: 7));
    final estaSemana = todos.where((a) => a.fecha.isAfter(hace7)).length;

    bool pasa(Aviso a) =>
        (_grupo == null || a.tallerId == _grupo) &&
        (_tipo == null || a.tipo == _tipo) &&
        (q.isEmpty ||
            a.titulo.toLowerCase().contains(q) ||
            a.mensaje.toLowerCase().contains(q));
    final lista = todos
        .where(pasa)
        .where((a) => _vista == 1 || a.fecha.isAfter(hace7))
        .toList();

    String etiquetaGrupo(DateTime f) {
      final d = DateTime.now().difference(f).inDays;
      return d < 7 ? 'Esta semana' : d < 30 ? 'Este mes' : 'Anteriores';
    }

    final hijos = <Widget>[];
    String? ultima;
    for (final a in lista) {
      if (_vista == 1) {
        final et = etiquetaGrupo(a.fecha);
        if (et != ultima) {
          ultima = et;
          hijos.add(Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 0, 8),
            child: Text(et,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: ColoresApp.navy, fontSize: 13)),
          ));
        }
      }
      hijos.add(_tarjeta(s, a));
    }

    final cuerpo = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (!widget.conAtras)
          const Text('Mis avisos',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
        Text('${todos.length} publicados · $estaSemana esta semana',
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/instructor/nuevo-aviso'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo aviso'),
        ),
        const SizedBox(height: 12),
        const AccesoChats(),
        const SizedBox(height: 14),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, icon: Icon(Icons.bolt_rounded), label: Text('Recientes')),
            ButtonSegment(value: 1, icon: Icon(Icons.history_rounded), label: Text('Historial')),
          ],
          selected: {_vista},
          onSelectionChanged: (v) => setState(() => _vista = v.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _buscar,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Buscar en mis avisos',
            suffixIcon: q.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(_buscar.clear),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ChoiceChip(
              label: const Text('Todos los grupos'),
              selected: _grupo == null,
              onSelected: (_) => setState(() => _grupo = null),
            ),
            for (final g in s.misGrupos) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(g.nombre),
                selected: _grupo == g.id,
                onSelected: (v) => setState(() => _grupo = v ? g.id : null),
              ),
            ],
            for (final t in TipoAviso.values) ...[
              const SizedBox(width: 8),
              FilterChip(
                label: Text(t.etiqueta),
                selected: _tipo == t,
                onSelected: (v) => setState(() => _tipo = v ? t : null),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                todos.isEmpty
                    ? 'Aún no has publicado avisos'
                    : _vista == 0
                    ? 'Sin avisos esta semana. Revisa el Historial'
                    : 'Sin resultados',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ...hijos,
        if (lista.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Toca un aviso para verlo completo · desliza ← para eliminar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black38, fontSize: 12)),
          ),
      ],
    );

    return widget.conAtras
        ? EstructuraSubpantalla(title: 'Mis avisos', fallback: '/instructor/perfil', child: cuerpo)
        : SafeArea(child: cuerpo);
  }

  Widget _tarjeta(EstadoApp s, Aviso a) {
    final (color, icono) = estiloAviso(a.tipo);
    final abierto = _abiertos.contains(a.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('mi-aviso-${a.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _preguntar(),
        onDismissed: (_) => _borrar(s, a),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: ColoresApp.danger,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        child: TarjetaApp(
          onTap: () => setState(() => abierto ? _abiertos.remove(a.id) : _abiertos.add(a.id)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.18),
              child: Icon(icono, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(a.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Text(tiempoRelativo(a.fecha),
                      style: const TextStyle(color: Colors.black45, fontSize: 11)),
                ]),
                Text('${s.tallerPorId(a.tallerId).nombre} · ${a.tipo.etiqueta}',
                    style: const TextStyle(color: ColoresApp.primary, fontSize: 11)),
                const SizedBox(height: 2),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: Text(a.mensaje,
                      maxLines: abierto ? null : 2,
                      overflow: abierto ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ),
                if (abierto) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.groups_rounded, size: 16, color: ColoresApp.muted),
                    const SizedBox(width: 4),
                    Text('Alcanzó a ${s.alumnosDe(a.tallerId).length} alumnos',
                        style: const TextStyle(color: ColoresApp.muted, fontSize: 12)),
                    const Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: ColoresApp.danger),
                      onPressed: () async {
                        if (await _preguntar() && mounted) _borrar(s, a);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Eliminar'),
                    ),
                  ]),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class PantallaNuevoAviso extends StatefulWidget {
  const PantallaNuevoAviso({super.key});
  @override
  State<PantallaNuevoAviso> createState() => _EstadoPantallaNuevoAviso();
}

class _EstadoPantallaNuevoAviso extends State<PantallaNuevoAviso> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _mensaje = TextEditingController();
  int? _tallerId;
  TipoAviso _tipo = TipoAviso.informativo;
  bool _notificar = true; // TODO: enviar notificación push desde backend

  @override
  void dispose() {
    _titulo.dispose();
    _mensaje.dispose();
    super.dispose();
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Future<void> _publish(int tallerId) async {
    if (!_form.currentState!.validate()) return;
    final ok = await confirmarAccion(
      context,
      titulo: '¿Publicar aviso?',
      mensaje: 'Los alumnos del grupo lo verán de inmediato.',
      textoConfirmar: 'Publicar',
      icono: Icons.campaign_rounded,
    );
    if (!ok || !mounted) return;
    final msg = ScaffoldMessenger.of(context);
    context.read<EstadoApp>().publicarAviso(
      tallerId: tallerId,
      tipo: _tipo,
      titulo: _titulo.text,
      mensaje: _mensaje.text,
    );
    context.pop();
    msg.showSnackBar(avisoSnack(content: Text('Aviso publicado')));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final grupos = s.misGrupos;
    final id = _tallerId ?? (grupos.isEmpty ? null : grupos.first.id);
    final inscritos = id == null ? 0 : s.alumnosDe(id).length;

    return EstructuraSubpantalla(
      title: 'Nuevo aviso',
      fallback: '/instructor/avisos',
      child: id == null
          ? const Center(child: Text('No tienes grupos asignados'))
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _label('Grupo'),
                  DropdownButtonFormField<int>(
                    initialValue: id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.groups),
                    ),
                    items: [
                      for (final g in grupos)
                        DropdownMenuItem(value: g.id, child: Text(g.nombre)),
                    ],
                    onChanged: (v) => setState(() => _tallerId = v),
                  ),
                  _label('Tipo de aviso'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final t in TipoAviso.values)
                        ChoiceChip(
                          label: Text(t.etiqueta),
                          selected: _tipo == t,
                          onSelected: (_) => setState(() => _tipo = t),
                        ),
                    ],
                  ),
                  _label('Título'),
                  TextFormField(
                    controller: _titulo,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo requerido'
                        : null,
                  ),
                  _label('Mensaje'),
                  TextFormField(
                    controller: _mensaje,
                    maxLength: 250,
                    maxLines: 5,
                    decoration: const InputDecoration(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo requerido'
                        : null,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Notificar a los $inscritos inscritos'),
                    value: _notificar,
                    onChanged: (v) => setState(() => _notificar = v),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _publish(id),
                    icon: const Icon(Icons.send),
                    label: const Text('Publicar aviso'),
                  ),
                ],
              ),
            ),
    );
  }
}
