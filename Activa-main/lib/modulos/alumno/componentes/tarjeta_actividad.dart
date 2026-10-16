import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../modelos/taller.dart';

const _navy = Color(0xFF0A3175);
const _verde = Color(0xFF0E9F6E);
const _rojo = Color(0xFFE5484D);

class TarjetaActividad extends StatefulWidget {
  const TarjetaActividad(this.taller, {super.key, this.onTap});

  final Taller taller;
  final VoidCallback? onTap;

  @override
  State<TarjetaActividad> createState() => _TarjetaActividadState();
}

class _TarjetaActividadState extends State<TarjetaActividad> {
  bool _presionada = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.taller;
    final color = t.categoria.color;
    final fondo = Color.alphaBlend(color.withValues(alpha: 0.13), Colors.white);
    final hayCupo = t.hayCupo;
    final estado = hayCupo ? _verde : _rojo;
    final radio = BorderRadius.circular(22);

    return AnimatedScale(
      scale: _presionada ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: radio,
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radio,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap ?? () => context.push('/activity/${t.id}'),
            onHighlightChanged: (v) => setState(() => _presionada = v),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Ilustracion(t, color),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: _navy, size: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: estado,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          hayCupo
                              ? 'Cupos disponibles: ${t.cuposDisponibles}'
                              : 'Cupo lleno',
                          style: TextStyle(
                            color: estado,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _Dato(Icons.schedule_rounded, t.horarioTexto, color, 2),
                  const SizedBox(height: 5),
                  _Dato(Icons.location_on_rounded, t.lugar, color, 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.icono, this.texto, this.color, this.lineas);
  final IconData icono;
  final String texto;
  final Color color;
  final int lineas;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icono, size: 13, color: color),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              texto,
              maxLines: lineas,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.25,
                color: Color(0xFF44546F),
              ),
            ),
          ),
        ],
      );
}

/// Dibujo de la actividad: si existe una imagen con el nombre de la actividad
/// en assets/images/actividades/ la usa; si no, muestra un ícono.
class _Ilustracion extends StatelessWidget {
  const _Ilustracion(this.taller, this.color);
  final Taller taller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final slug = _normaliza(taller.nombre)
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/images/actividades/$slug.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(_iconoPara(taller), color: color, size: 28),
          ),
        ),
      ),
    );
  }
}

String _normaliza(String s) {
  const con = 'áéíóúüñ';
  const sin = 'aeiouun';
  var r = s.toLowerCase();
  for (var i = 0; i < con.length; i++) {
    r = r.replaceAll(con[i], sin[i]);
  }
  return r;
}

IconData _iconoPara(Taller t) {
  final n = _normaliza(t.nombre);
  if (n.contains('voleibol')) return Icons.sports_volleyball_rounded;
  if (n.contains('futbol')) return Icons.sports_soccer_rounded;
  if (n.contains('basquet') || n.contains('baloncesto')) {
    return Icons.sports_basketball_rounded;
  }
  if (n.contains('ajedrez')) return Icons.castle_rounded;
  if (n.contains('danza') || n.contains('baile')) return Icons.festival_rounded;
  if (n.contains('teatro')) return Icons.theater_comedy_rounded;
  if (n.contains('tae') || n.contains('karate') || n.contains('box')) {
    return Icons.sports_martial_arts_rounded;
  }
  if (n.contains('banda') || n.contains('music')) {
    return Icons.queue_music_rounded;
  }
  if (n.contains('atletismo')) return Icons.directions_run_rounded;
  if (n.contains('zumba')) return Icons.sports_gymnastics_rounded;
  return Icons.star_rounded;
}