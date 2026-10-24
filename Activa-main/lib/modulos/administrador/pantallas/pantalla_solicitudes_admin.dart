import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../modelos/comunicacion.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';

class PantallaSolicitudesAdmin extends StatefulWidget {
  const PantallaSolicitudesAdmin({super.key});
  @override
  State<PantallaSolicitudesAdmin> createState() => _EstadoSolicitudesAdmin();
}

class _EstadoSolicitudesAdmin extends State<PantallaSolicitudesAdmin> {
  EstadoSolicitud? _filtro = EstadoSolicitud.pendiente; // null = todas

  Future<void> _responder(EstadoApp s, SolicitudAdmin sol, bool aprobar) async {
    final t = s.tallerPorId(sol.tallerId);
    final ampliar = aprobar &&
        (sol.tipo == TipoSolicitud.clubLleno || sol.tipo == TipoSolicitud.ampliarCupo);
    final texto = TextEditingController();
    var extra = 5;
    var error = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dctx, setD) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(aprobar ? 'Atender solicitud' : 'Rechazar solicitud',
              style: const TextStyle(fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.nombre} · ${sol.instructorNombre}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
              if (ampliar) ...[
                const SizedBox(height: 14),
                const Text('Ampliar cupo', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [
                  IconButton(
                    onPressed: extra > 1 ? () => setD(() => extra--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('+$extra',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  IconButton(
                    onPressed: extra < 30 ? () => setD(() => extra++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  Expanded(
                    child: Text('Nuevo cupo: ${t.cupoMaximo + extra}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(color: ColoresApp.muted, fontSize: 12)),
                  ),
                ]),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: texto,
                maxLines: 2,
                maxLength: 150,
                decoration: InputDecoration(
                  hintText: aprobar
                      ? 'Respuesta para el instructor (opcional)'
                      : 'Motivo del rechazo',
                  errorText: error ? 'Escribe el motivo (mín. 5 letras)' : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Regresar')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: aprobar ? ColoresApp.primary : ColoresApp.danger,
              ),
              onPressed: () {
                if (!aprobar && texto.text.trim().length < 5) {
                  setD(() => error = true);
                  return;
                }
                Navigator.pop(dctx, true);
              },
              child: Text(aprobar ? 'Confirmar' : 'Rechazar'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    s.responderSolicitud(
      sol.id,
      aprobar: aprobar,
      respuesta: texto.text,
      cupoExtra: ampliar ? extra : 0,
    );
    ScaffoldMessenger.of(context).showSnackBar(avisoSnack(
      content: Text(aprobar
          ? (ampliar ? 'Solicitud atendida, cupo ampliado' : 'Solicitud atendida')
          : 'Solicitud rechazada'),
      tipo: TipoToast.exito,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    int n(EstadoSolicitud e) => s.solicitudes.where((x) => x.estado == e).length;
    final lista = s.solicitudes
        .where((x) => _filtro == null || x.estado == _filtro)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return EstructuraSubpantalla(
      title: 'Solicitudes',
      fallback: '/admin/reportes',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final (e, txt) in [
                (EstadoSolicitud.pendiente, 'Pendientes'),
                (EstadoSolicitud.atendida, 'Atendidas'),
                (EstadoSolicitud.rechazada, 'Rechazadas'),
              ]) ...[
                ChoiceChip(
                  label: Text('$txt (${n(e)})'),
                  selected: _filtro == e,
                  onSelected: (_) => setState(() => _filtro = e),
                ),
                const SizedBox(width: 8),
              ],
              ChoiceChip(
                label: Text('Todas (${s.solicitudes.length})'),
                selected: _filtro == null,
                onSelected: (_) => setState(() => _filtro = null),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text('No hay solicitudes aquí', style: TextStyle(color: Colors.black54)),
              ),
            ),
          for (final sol in lista) _tarjeta(s, sol),
        ],
      ),
    );
  }

  Widget _tarjeta(EstadoApp s, SolicitudAdmin sol) {
    final t = s.tallerPorId(sol.tallerId);
    final pendiente = sol.estado == EstadoSolicitud.pendiente;
    final (txt, col) = switch (sol.estado) {
      EstadoSolicitud.pendiente => ('Pendiente', ColoresApp.warning),
      EstadoSolicitud.atendida => ('Atendida', ColoresApp.teal),
      EstadoSolicitud.rechazada => ('Rechazada', ColoresApp.danger),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TarjetaApp(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(sol.tipo.etiqueta,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            Chip(
              label: Text(txt),
              backgroundColor: col.withValues(alpha: 0.15),
              side: BorderSide.none,
            ),
          ]),
          Text('${t.nombre} · ${sol.instructorNombre}',
              style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: t.cupoMaximo == 0 ? 0 : t.inscritos / t.cupoMaximo,
              minHeight: 6,
              backgroundColor: ColoresApp.background,
              color: t.hayCupo ? ColoresApp.primary : ColoresApp.danger,
            ),
          ),
          const SizedBox(height: 4),
          Text('Lugares: ${t.inscritos}/${t.cupoMaximo} · ${tiempoRelativo(sol.fecha)}',
              style: const TextStyle(color: Colors.black45, fontSize: 12)),
          if (sol.mensaje.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(sol.mensaje),
          ],
          if (!pendiente && (sol.respuesta.isNotEmpty || sol.cupoExtra > 0)) ...[
            const Divider(height: 20),
            Text(
              [
                if (sol.cupoExtra > 0) 'Cupo ampliado en ${sol.cupoExtra}.',
                if (sol.respuesta.isNotEmpty) sol.respuesta,
              ].join(' '),
              style: const TextStyle(fontSize: 12, color: ColoresApp.muted),
            ),
          ],
          if (pendiente) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.danger,
                    minimumSize: const Size.fromHeight(46),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => _responder(s, sol, false),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                  onPressed: () => _responder(s, sol, true),
                  child: Text(sol.tipo == TipoSolicitud.clubLleno ||
                          sol.tipo == TipoSolicitud.ampliarCupo
                      ? 'Ampliar cupo'
                      : 'Atender'),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}