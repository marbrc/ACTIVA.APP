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
  State<PantallaSolicitudesInstructor> createState() =>
      _EstadoSolicitudesInstructor();
}

class _EstadoSolicitudesInstructor
    extends State<PantallaSolicitudesInstructor> {
  int? _tallerId;
  TipoSolicitud _tipo = TipoSolicitud.clubLleno;
  final _mensaje = TextEditingController();

  @override
  void dispose() {
    _mensaje.dispose();
    super.dispose();
  }

  Future<void> _enviar(EstadoApp s, int tallerId) async {
    if (_tipo == TipoSolicitud.otro && _mensaje.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(
          content: const Text('Escribe un mensaje para el administrador'),
          tipo: TipoToast.error,
        ),
      );
      return;
    }
    final t = s.tallerPorId(tallerId);
    final ok = await confirmarAccion(
      context,
      titulo: '¿Enviar solicitud?',
      mensaje:
          'Se avisará al administrador: "${_tipo.etiqueta}" en ${t.nombre}.',
      textoConfirmar: 'Enviar',
      icono: Icons.send_rounded,
    );
    if (!ok || !mounted) return;
    s.enviarSolicitud(taller: t, tipo: _tipo, mensaje: _mensaje.text);
    _mensaje.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      avisoSnack(
        content: const Text('Solicitud enviada al administrador'),
        tipo: TipoToast.exito,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final grupos = s.misGrupos;
    final id = _tallerId ?? (grupos.isEmpty ? null : grupos.first.id);
    final enviadas = s.solicitudesDelInstructor;

    return EstructuraSubpantalla(
      title: 'Solicitudes al admin',
      fallback: '/instructor/perfil',
      child: id == null
          ? const Center(child: Text('No tienes grupos asignados'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Avísale al administrador cuando tu club se llene o '
                  'cuando alguien se dé de baja.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Club',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final g in grupos)
                      ChoiceChip(
                        label: Text(g.nombre),
                        selected: g.id == id,
                        onSelected: (_) => setState(() => _tallerId = g.id),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Lugares ocupados: ${s.tallerPorId(id).inscritos} de ${s.tallerPorId(id).cupoMaximo}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Motivo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tipo in TipoSolicitud.values)
                      ChoiceChip(
                        label: Text(tipo.etiqueta),
                        selected: tipo == _tipo,
                        onSelected: (_) => setState(() => _tipo = tipo),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _mensaje,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _tipo == TipoSolicitud.otro
                        ? 'Cuéntale al administrador qué pasó'
                        : 'Mensaje (opcional)',
                  ),
                ),
                const SizedBox(height: 16),
                BotonActiva(
                  etiqueta: 'Enviar solicitud',
                  icono: Icons.send_rounded,
                  alPresionar: () => _enviar(s, id),
                ),
                if (enviadas.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Mis solicitudes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ColoresApp.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final sol in enviadas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TarjetaApp(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${sol.tipo.etiqueta} · ${s.tallerPorId(sol.tallerId).nombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (sol.mensaje.isNotEmpty)
                                    Text(
                                      sol.mensaje,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  Text(
                                    tiempoRelativo(sol.fecha),
                                    style: const TextStyle(
                                      color: Colors.black38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                sol.estado == EstadoSolicitud.pendiente
                                    ? 'Pendiente'
                                    : 'Atendida',
                              ),
                              backgroundColor:
                                  (sol.estado == EstadoSolicitud.pendiente
                                          ? ColoresApp.warning
                                          : ColoresApp.teal)
                                      .withValues(alpha: 0.15),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}