import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../modelos/comunicacion.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../nucleo/componentes/dialogo_confirmar.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';

class PantallaSolicitudesInstructor extends StatefulWidget {
  const PantallaSolicitudesInstructor({super.key});
  @override
  State<PantallaSolicitudesInstructor> createState() => _EstadoSolicitudesInstructor();
}

class _EstadoSolicitudesInstructor extends State<PantallaSolicitudesInstructor> {
  int? _tallerId;
  TipoSolicitud? _tipo;
  final _mensaje = TextEditingController();

  @override
  void dispose() {
    _mensaje.dispose();
    super.dispose();
  }

  void _toast(String m, TipoToast t) => ScaffoldMessenger.of(context)
      .showSnackBar(avisoSnack(content: Text(m), tipo: t));

  Future<void> _enviar(EstadoApp s, int tallerId, TipoSolicitud tipo) async {
    final msg = _mensaje.text.trim();
    if (tipo == TipoSolicitud.otro && msg.length < 10) {
      _toast('Cuéntale al administrador qué pasó (mín. 10 letras)', TipoToast.error);
      return;
    }
    if (s.haySolicitudPendiente(tallerId, tipo)) {
      _toast('Ya tienes una solicitud pendiente igual para este club', TipoToast.advertencia);
      return;
    }
    final t = s.tallerPorId(tallerId);
    final ok = await confirmarAccion(
      context,
      titulo: '¿Enviar solicitud?',
      mensaje: 'Se avisará al administrador: "${tipo.etiqueta}" en ${t.nombre}.',
      textoConfirmar: 'Enviar',
      icono: Icons.send_rounded,
    );
    if (!ok || !mounted) return;
    s.enviarSolicitud(taller: t, tipo: tipo, mensaje: msg);
    _mensaje.clear();
    setState(() => _tipo = null);
    _toast('Solicitud enviada al administrador', TipoToast.exito);
  }

  Future<void> _cancelar(EstadoApp s, SolicitudAdmin sol) async {
    final ok = await confirmarAccion(
      context,
      titulo: '¿Cancelar solicitud?',
      mensaje: 'El administrador ya no la verá.',
      textoConfirmar: 'Cancelar solicitud',
      textoCancelar: 'Regresar',
      icono: Icons.cancel_outlined,
      peligro: true,
    );
    if (ok && mounted) s.cancelarSolicitud(sol.id);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final grupos = s.misGrupos;
    final id = _tallerId ?? (grupos.isEmpty ? null : grupos.first.id);
    final enviadas = [...s.solicitudesDelInstructor]..sort((a, b) {
        if (a.estado != b.estado) {
          return a.estado == EstadoSolicitud.pendiente ? -1 : 1;
        }
        return b.fecha.compareTo(a.fecha);
      });

    return EstructuraSubpantalla(
      title: 'Solicitudes al admin',
      fallback: '/instructor/perfil',
      child: id == null
          ? const Center(child: Text('No tienes grupos asignados'))
          : Builder(builder: (_) {
              final t = s.tallerPorId(id);
              final lleno = !t.hayCupo;
              final bajas = s.bajasDe(id);
              final sugerido = lleno
                  ? TipoSolicitud.clubLleno
                  : bajas > 0
                  ? TipoSolicitud.bajaAlumno
                  : null;
              final tipo = _tipo ?? sugerido ?? TipoSolicitud.otro;

              bool habilitado(TipoSolicitud x) => switch (x) {
                TipoSolicitud.clubLleno => lleno,
                TipoSolicitud.bajaAlumno => bajas > 0,
                _ => true,
              };

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Club',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    for (final g in grupos)
                      ChoiceChip(
                        label: Text(g.nombre),
                        selected: g.id == id,
                        onSelected: (_) => setState(() {
                          _tallerId = g.id;
                          _tipo = null;
                        }),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  // estado del club en tiempo real
                  TarjetaApp(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          child: Text('Lugares ocupados: ${t.inscritos} de ${t.cupoMaximo}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        if (lleno)
                          const Chip(label: Text('Lleno'), side: BorderSide.none),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: t.cupoMaximo == 0 ? 0 : t.inscritos / t.cupoMaximo,
                          minHeight: 8,
                          backgroundColor: ColoresApp.background,
                          color: lleno ? ColoresApp.danger : ColoresApp.primary,
                        ),
                      ),
                      if (bajas > 0) ...[
                        const SizedBox(height: 8),
                        Text('Bajas registradas en este club: $bajas',
                            style: const TextStyle(color: ColoresApp.muted, fontSize: 12)),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),
                  const Text('Motivo', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (sugerido != null)
                    Text('Sugerido: ${sugerido.etiqueta}',
                        style: const TextStyle(color: ColoresApp.teal, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    for (final x in TipoSolicitud.values)
                      ChoiceChip(
                        label: Text(x.etiqueta),
                        selected: x == tipo,
                        onSelected: habilitado(x) ? (_) => setState(() => _tipo = x) : null,
                      ),
                  ]),
                  if (!lleno || bajas == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '"El club ya se llenó" solo se activa con el cupo lleno y '
                        '"Un alumno se dio de baja" cuando hay bajas.',
                        style: TextStyle(color: ColoresApp.muted, fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _mensaje,
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: tipo == TipoSolicitud.otro
                          ? 'Cuéntale al administrador qué pasó'
                          : 'Mensaje (opcional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  BotonActiva(
                    etiqueta: 'Enviar solicitud',
                    icono: Icons.send_rounded,
                    alPresionar: () => _enviar(s, id, tipo),
                  ),
                  if (enviadas.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Mis solicitudes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
                    const SizedBox(height: 10),
                    for (final sol in enviadas) _tarjeta(s, sol),
                  ],
                ],
              );
            }),
    );
  }

  Widget _tarjeta(EstadoApp s, SolicitudAdmin sol) {
    final (txt, col) = switch (sol.estado) {
      EstadoSolicitud.pendiente => ('Pendiente', ColoresApp.warning),
      EstadoSolicitud.atendida => ('Atendida', ColoresApp.teal),
      EstadoSolicitud.rechazada => ('Rechazada', ColoresApp.danger),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaApp(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text('${sol.tipo.etiqueta} · ${s.tallerPorId(sol.tallerId).nombre}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Chip(
              label: Text(txt),
              backgroundColor: col.withValues(alpha: 0.15),
              side: BorderSide.none,
            ),
          ]),
          if (sol.mensaje.isNotEmpty)
            Text(sol.mensaje, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text(tiempoRelativo(sol.fecha),
              style: const TextStyle(color: Colors.black38, fontSize: 11)),
          if (sol.estado != EstadoSolicitud.pendiente) ...[
            const Divider(height: 20),
            Text(
              sol.cupoExtra > 0
                  ? 'Respuesta del admin: cupo ampliado en ${sol.cupoExtra} lugares.'
                  : 'Respuesta del admin:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            if (sol.respuesta.isNotEmpty)
              Text(sol.respuesta, style: const TextStyle(fontSize: 12)),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _cancelar(s, sol),
                child: const Text('Cancelar solicitud'),
              ),
            ),
        ]),
      ),
    );
  }
}