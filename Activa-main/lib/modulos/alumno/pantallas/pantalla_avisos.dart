import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../modelos/enums.dart';
import '../../../modelos/inscripcion.dart';
import '../../../nucleo/componentes/accesos_rapidos.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/estilo_aviso.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/utilidades/textos.dart';

class PantallaAvisos extends StatefulWidget {
  const PantallaAvisos({super.key});
  @override
  State<PantallaAvisos> createState() => _EstadoAvisos();
}

class _EstadoAvisos extends State<PantallaAvisos> {
  TipoAviso? _tipo;
  bool _soloSinLeer = false;
  bool _archivados = false;

  void _msg(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(avisoSnack(content: Text(m), tipo: TipoToast.info));

  // hoja con el detalle y acciones del aviso
  void _detalle(Aviso a) {
    final s = context.read<EstadoApp>();
    s.marcarAviso(a.id);
    final (color, icono) = estiloAviso(a.tipo);
    final t = s.tallerPorId(a.tallerId);
    final inscrito = s.estaInscrito(t.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(icono, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  Text('${t.nombre} · ${a.tipo.etiqueta}',
                      style: const TextStyle(color: ColoresApp.primary, fontSize: 12)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Text(a.mensaje, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 6),
            Text(tiempoRelativo(a.fecha),
                style: const TextStyle(color: Colors.black45, fontSize: 12)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.pop(sheet);
                    context.push('/actividad/${t.id}');
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Ver actividad'),
                ),
              ),
              if (inscrito) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () {
                      Navigator.pop(sheet);
                      context.push('/chat/${t.id}');
                    },
                    icon: const Icon(Icons.forum_rounded, size: 18),
                    label: const Text('Abrir chat'),
                  ),
                ),
              ],
            ]),
            Center(
              child: TextButton(
                onPressed: () {
                  s.marcarAviso(a.id, leido: false);
                  Navigator.pop(sheet);
                },
                child: const Text('Marcar como no leído'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final base = _archivados ? s.avisosArchivados : s.avisosVisibles;
    final lista = base
        .where((a) =>
            (_tipo == null || a.tipo == _tipo) &&
            (!_soloSinLeer || !s.avisoLeido(a.id)))
        .toList()
      ..sort((x, y) => y.fecha.compareTo(x.fecha));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            Expanded(
              child: Text(context.tr('config.notif'),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
            ),
            TextButton.icon(
              onPressed: s.avisosSinLeer == 0
                  ? null
                  : () {
                      s.marcarTodosLeidos();
                      _msg('Todo marcado como leído');
                    },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Marcar todo'),
            ),
          ]),
          const SizedBox(height: 10),
          const AccesoChats(),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              FilterChip(
                label: Text('Sin leer (${s.avisosSinLeer})'),
                selected: _soloSinLeer,
                onSelected: (v) => setState(() => _soloSinLeer = v),
              ),
              const SizedBox(width: 8),
              for (final t in TipoAviso.values) ...[
                ChoiceChip(
                  label: Text(t.etiqueta),
                  selected: _tipo == t,
                  onSelected: (v) => setState(() => _tipo = v ? t : null),
                ),
                const SizedBox(width: 8),
              ],
              FilterChip(
                avatar: const Icon(Icons.archive_outlined, size: 16),
                label: Text('Archivados (${s.avisosArchivados.length})'),
                selected: _archivados,
                onSelected: (v) => setState(() => _archivados = v),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text('No hay avisos aquí', style: TextStyle(color: Colors.black54)),
              ),
            ),
          for (final a in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('aviso-${a.id}-$_archivados'),
                // → archiva / restaura   ← marca leído o no leído
                confirmDismiss: (dir) async {
                  if (dir == DismissDirection.endToStart) {
                    s.marcarAviso(a.id, leido: !s.avisoLeido(a.id));
                    return false;
                  }
                  return true;
                },
                onDismissed: (_) {
                  s.archivarAviso(a.id, archivar: !_archivados);
                  _msg(_archivados ? 'Aviso restaurado' : 'Aviso archivado');
                },
                background: _fondoSwipe(
                  ColoresApp.primary,
                  _archivados ? Icons.unarchive_rounded : Icons.archive_rounded,
                  _archivados ? 'Restaurar' : 'Archivar',
                  Alignment.centerLeft,
                ),
                secondaryBackground: _fondoSwipe(
                  ColoresApp.teal,
                  Icons.mark_email_read_rounded,
                  s.avisoLeido(a.id) ? 'No leído' : 'Leído',
                  Alignment.centerRight,
                ),
                child: _tarjeta(s, a),
              ),
            ),
          if (lista.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Desliza → para archivar · ← para marcar leído',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fondoSwipe(Color c, IconData i, String t, Alignment al) => Container(
    alignment: al,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(22)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(i, color: Colors.white),
      Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _tarjeta(EstadoApp s, Aviso a) {
    final (color, icono) = estiloAviso(a.tipo);
    final leido = s.avisoLeido(a.id);
    return TarjetaApp(
      onTap: () => _detalle(a),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(a.titulo,
                      style: TextStyle(
                          fontWeight: leido ? FontWeight.w500 : FontWeight.w800)),
                ),
                if (!leido)
                  const Icon(Icons.circle, size: 9, color: ColoresApp.primary),
                const SizedBox(width: 6),
                Text(tiempoRelativo(a.fecha),
                    style: const TextStyle(color: Colors.black45, fontSize: 11)),
              ]),
              const SizedBox(height: 2),
              Text(a.mensaje,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}