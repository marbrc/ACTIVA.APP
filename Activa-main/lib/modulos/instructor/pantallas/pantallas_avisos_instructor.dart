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

class PantallaAvisosInstructor extends StatelessWidget {
  const PantallaAvisosInstructor({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final avisos = s.avisosPublicados;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Mis avisos',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.push('/instructor/nuevo-aviso'),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo aviso'),
          ),
          const SizedBox(height: 14),
          if (avisos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(child: Text('Aún no has publicado avisos')),
            ),
          for (final a in avisos)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TarjetaApp(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: estiloAviso(a.tipo).$1
                          .withValues(alpha: 0.18),
                      child: Icon(
                        estiloAviso(a.tipo).$2,
                        color: estiloAviso(a.tipo).$1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                tiempoRelativo(a.fecha),
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${s.tallerPorId(a.tallerId).nombre} · ${a.tipo.etiqueta}',
                            style: const TextStyle(
                              color: ColoresApp.primary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.mensaje,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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

  void _publish(int tallerId) {
    if (!_form.currentState!.validate()) return;
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
