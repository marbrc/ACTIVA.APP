import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../../../modelos/inscripcion.dart';
import '../componentes/miniatura_taller.dart';
import '../../../nucleo/componentes/avisos.dart';

class PantallaMisActividades extends StatelessWidget {
  const PantallaMisActividades({super.key});

   Future<void> _baja(BuildContext context, Inscripcion i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('¿Darte de baja?'),
        content: Text(
            'Dejarás de pertenecer a ${i.taller.nombre} y se liberará tu lugar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Darme de baja'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<EstadoApp>().cancelar(i.folio);
      ScaffoldMessenger.of(context).showSnackBar(
          avisoSnack(content: Text('Te diste de baja de ${i.taller.nombre}')));
    }
  }


  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final lista = s.misInscripciones;
    final h = s.horasRealizadas;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Mis actividades',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          const SizedBox(height: 14),
          TarjetaApp(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Text('Horas acumuladas',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Text('$h / $metaHoras',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (h / metaHoras).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: ColoresApp.background,
                    color: ColoresApp.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  const Text('Aún no estás inscrito en ninguna actividad'),
                  TextButton(
                    onPressed: () => context.go('/alumno/explorar'),
                    child: const Text('Explorar actividades'),
                  ),
                ],
              ),
            ),
          for (final i in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TarjetaApp(
                onTap: () => context.push('/inscripcion/${i.folio}'),
                child: Row(
                  children: [
                    MiniaturaTaller(i.taller, size: 60),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.taller.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(i.taller.horarioTexto.replaceAll(' | ', ' · '),
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12)),
                          Text('Folio ${i.folio}',
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 11)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) => v == 'ver'
                          ? context.push('/inscripcion/${i.folio}')
                          : _baja(context, i),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'ver', child: Text('Ver comprobante')),
                        PopupMenuItem(value: 'baja', child: Text('Darme de baja')),
                      ],
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