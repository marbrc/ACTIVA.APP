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

import '../../../nucleo/servicios/documentos.dart';

class PantallaMisActividades extends StatelessWidget {
  const PantallaMisActividades({super.key});

  /// Solo pregunta; no borra nada todavía.
  Future<bool> _confirmarBaja(BuildContext context, Inscripcion i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          '¿Darte de baja?',
          style: TextStyle(fontWeight: FontWeight.w800, color: ColoresApp.navy),
        ),
        content: Text(
          'Dejarás de pertenecer a ${i.taller.nombre} y se liberará tu lugar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, 46),
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Darme de baja'),
          ),

          
        ],
      ),
    );
    return ok == true;
  }

  void _cancelar(BuildContext context, Inscripcion i) {
    context.read<EstadoApp>().cancelar(i.folio);
    ScaffoldMessenger.of(context).showSnackBar(
      avisoSnack(content: Text('Te diste de baja de ${i.taller.nombre}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final lista = s.misInscripciones;
    final h = s.horasRealizadas;

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Mis actividades',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lista.isEmpty
                ? 'Aquí aparecerán tus talleres y clubes'
                : 'Tienes ${lista.length} ${lista.length == 1 ? 'actividad' : 'actividades'} activas',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          _tarjetaHoras(h),
          const SizedBox(height: 20),
          if (lista.isEmpty) _vacio(context),
          for (var n = 0; n < lista.length; n++)
            _Aparece(
              retraso: n,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _tarjetaActividad(context, lista[n]),
              ),
            ),
          if (lista.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Tip: desliza una tarjeta hacia la izquierda para darte de baja',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Tarjeta de horas con degradado ----------
  Widget _tarjetaHoras(int h) {
    final progreso = (h / metaHoras).clamp(0.0, 1.0);
    final faltan = metaHoras - h;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColoresApp.navy, ColoresApp.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.navy.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Horas acumuladas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progreso),
                duration: const Duration(milliseconds: 1300),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(v * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$h / $metaHoras h',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 1300),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            faltan <= 0
                ? '¡Meta cumplida! 🎉'
                : 'Te faltan $faltan horas, ¡tú puedes!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tarjeta de cada actividad (con deslizar para baja) ----------
  Widget _tarjetaActividad(BuildContext context, Inscripcion i) {
    return Dismissible(
      key: ValueKey(i.folio),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmarBaja(context, i),
      onDismissed: (_) => _cancelar(context, i),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE5484D),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.exit_to_app_rounded, color: Colors.white),
            SizedBox(height: 2),
            Text('Baja',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: TarjetaApp(
        onTap: () => context.push('/inscripcion/${i.folio}'),
        child: Row(
          children: [
            MiniaturaTaller(i.taller, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i.taller.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: ColoresApp.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: Colors.black45),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          i.taller.horarioTexto.replaceAll(' | ', ' · '),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColoresApp.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Folio ${i.folio}',
                      style: const TextStyle(
                        color: ColoresApp.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
                        PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              onSelected: (v) async {
                if (v == 'ver') {
                  context.push('/inscripcion/${i.folio}');
                } else if (v == 'pdf') {
                  descargarPdfConfirmando(
                    context,
                    nombreDoc: 'Comprobante ${i.folio}',
                    generar: () => Documentos.comprobanteInscripcion(i),
                  );
                } else if (await _confirmarBaja(context, i) && context.mounted) {
                  _cancelar(context, i);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'ver',
                  child: Row(children: [
                    Icon(Icons.receipt_long_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Ver comprobante'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'pdf',
                  child: Row(children: [
                    Icon(Icons.picture_as_pdf_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Descargar comprobante'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'baja',
                  child: Row(children: [
                    Icon(Icons.exit_to_app_rounded, size: 20, color: Color(0xFFE5484D)),
                    SizedBox(width: 10),
                    Text('Darme de baja'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Estado vacío ----------
  Widget _vacio(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: ColoresApp.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_volleyball_rounded,
                size: 54, color: ColoresApp.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no estás inscrito en ninguna actividad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 52),
              shape: const StadiumBorder(),
            ),
            onPressed: () => context.go('/alumno/explorar'),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Explorar actividades'),
          ),
        ],
      ),
    );
  }
}

/// Entra con fade + deslizamiento, una tras otra según su posición.
class _Aparece extends StatelessWidget {
  const _Aparece({required this.child, required this.retraso});
  final Widget child;
  final int retraso;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + retraso * 120),
      curve: Curves.easeOutCubic,
      builder: (_, v, hijo) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: hijo),
      ),
      child: child,
    );
  }
}