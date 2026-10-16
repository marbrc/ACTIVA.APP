import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../datos/estado_app.dart';
import '../../../modelos/taller.dart';
import '../componentes/tarjeta_taller.dart';
import '../componentes/miniatura_taller.dart';
import '../../../nucleo/componentes/avisos.dart';

class PantallaDetalleActividad extends StatelessWidget {
  const PantallaDetalleActividad({super.key, required this.tallerId});
  final int tallerId;

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(avisoSnack(content: Text(msg)));

  Future<void> _confirm(BuildContext context, Taller t) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: ColoresApp.background,
              child: Icon(Icons.calendar_today, color: ColoresApp.primary),
            ),
            const SizedBox(height: 16),
            const Text('¿Confirmar inscripción?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Estás por inscribirte a ${t.nombre}, ${t.horarioTexto.replaceAll(' | ', ' de ')} en ${t.lugar}.',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.pop(sheetCtx, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetCtx, true),
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // después de un await hay que revisar que la pantalla siga viva
    if (ok != true || !context.mounted) return;

    final ins = context.read<EstadoApp>().inscribir(t);
    if (ins == null) {
      _snack(context, 'No fue posible inscribirte');
      return;
    }
    context.pushReplacement('/inscripcion/${ins.folio}');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EstadoApp>();
    final t = state.tallerPorId(tallerId);
    final inscrito = state.estaInscrito(t.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: BannerTaller(t, height: 250),
          ),
          Positioned.fill(
            top: 215,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(t.nombre,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: ColoresApp.navy)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColoresApp.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(t.categoria.etiqueta,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FilaInfo(Icons.person, 'Instructor', t.instructor.nombreCompleto),
                  _FilaInfo(Icons.access_time, 'Horario', t.horarioTexto),
                  _FilaInfo(Icons.location_on, 'Lugar', t.lugar),
                  _FilaInfo(Icons.groups, 'Cupo',
                      '${t.inscritos} de ${t.cupoMaximo} lugares ocupados'),
                  Padding(
                    padding: const EdgeInsets.only(left: 56, bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: t.inscritos / t.cupoMaximo,
                        minHeight: 8,
                        backgroundColor: ColoresApp.background,
                        color: t.hayCupo ? ColoresApp.primary : ColoresApp.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Descripción',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(t.descripcion,
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  const Text('¿Qué aprenderás?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final a in t.aprendizajes)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: ColoresApp.background, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.star, color: ColoresApp.primary),
                                const SizedBox(height: 6),
                                Text(a,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed:
                        (inscrito || !t.hayCupo) ? null : () => _confirm(context, t),
                    child: Text(inscrito
                        ? 'Ya estás inscrito'
                        : t.hayCupo
                            ? 'Inscribirme'
                            : 'Sin cupo disponible'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _BotonAccion(Icons.calendar_today, 'Agregar al calendario',
                          () => _snack(context, 'Próximamente')),
                      const SizedBox(width: 8),
                      _BotonAccion(Icons.location_on, 'Ver ubicación',
                          () => _snack(context, 'Próximamente')),
                      const SizedBox(width: 8),
                      _BotonAccion(Icons.share, 'Compartir', () async {
                        await Clipboard.setData(ClipboardData(
                            text: '${t.nombre} · ${t.horarioTexto} · ${t.lugar}'));
                        if (context.mounted) {
                          _snack(context, 'Datos copiados para compartir');
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Botones flotantes arriba
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () =>
                          context.canPop() ? context.pop() : context.go('/alumno'),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: ColoresApp.navy),
                      ),
                    ),
                    const Spacer(),
                    BotonFavorito(t.id, radius: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColoresApp.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ColoresApp.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: Colors.black45, fontSize: 11)),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _BotonAccion extends StatelessWidget {
  const _BotonAccion(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ColoresApp.background, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, color: ColoresApp.primary),
                const SizedBox(height: 4),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
}