import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../modelos/comunicacion.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/dialogo_confirmar.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';

class PantallaSolicitudesAdmin extends StatelessWidget {
  const PantallaSolicitudesAdmin({super.key});

  Future<void> _atender(BuildContext context, SolicitudAdmin sol) async {
    final ok = await confirmarAccion(
      context,
      titulo: '¿Marcar como atendida?',
      mensaje: 'La solicitud de ${sol.instructorNombre} pasará a atendida.',
      textoConfirmar: 'Marcar atendida',
      icono: Icons.task_alt_rounded,
    );
    if (!ok || !context.mounted) return;
    context.read<EstadoApp>().atenderSolicitud(sol.id);
    ScaffoldMessenger.of(context).showSnackBar(
      avisoSnack(
        content: const Text('Solicitud marcada como atendida'),
        tipo: TipoToast.exito,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    // las pendientes primero
    final lista = [...s.solicitudes]
      ..sort((a, b) {
        if (a.estado != b.estado) {
          return a.estado == EstadoSolicitud.pendiente ? -1 : 1;
        }
        return b.fecha.compareTo(a.fecha);
      });

    return EstructuraSubpantalla(
      title: 'Solicitudes',
      fallback: '/admin/reportes',
      child: lista.isEmpty
          ? const Center(
              child: Text(
                'No hay solicitudes por ahora',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final sol in lista)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Builder(
                      builder: (_) {
                        final t = s.tallerPorId(sol.tallerId);
                        final pendiente =
                            sol.estado == EstadoSolicitud.pendiente;
                        return TarjetaApp(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sol.tipo.etiqueta,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      pendiente ? 'Pendiente' : 'Atendida',
                                    ),
                                    backgroundColor:
                                        (pendiente
                                                ? ColoresApp.warning
                                                : ColoresApp.teal)
                                            .withValues(alpha: 0.15),
                                    side: BorderSide.none,
                                  ),
                                ],
                              ),
                              Text(
                                '${t.nombre} · ${sol.instructorNombre}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                'Lugares: ${t.inscritos}/${t.cupoMaximo} · ${tiempoRelativo(sol.fecha)}',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                              if (sol.mensaje.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(sol.mensaje),
                              ],
                              if (pendiente) ...[
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: () => _atender(context, sol),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Marcar como atendida'),
                                ),
                              ],
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