// ===================================================================
// Tarjeta de actividad mas etiqueta de cupo y botón de corazón
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../datos/estado_app.dart';
import '../../../modelos/taller.dart';
import 'miniatura_taller.dart';

// texto con puntito de color: "5 lugares disponibles" o "Cupo lleno"
class EtiquetaCupo extends StatelessWidget {
  const EtiquetaCupo(this.taller, {super.key});
  final Taller taller;

  @override
  Widget build(BuildContext context) {
    // todavía hay lugares?
    final ok = taller.hayCupo;
    // Cuántos lugares quedan
    final n = taller.cuposDisponibles;
    // Verde si hay lugares, rojo si está lleno
    final color = ok ? ColoresApp.teal : ColoresApp.danger;
    return Row(
      children: [
        // Puntito de color
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        // Flexible evita que el texto se salga de la tarjeta
        Flexible(
          child: Text(
            ok
                ? '$n ${n == 1 ? 'lugar disponible' : 'lugares disponibles'}'
                : 'Cupo lleno',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// Botón de corazón para marcar favoritos
class BotonFavorito extends StatelessWidget {
  const BotonFavorito(this.tallerId, {super.key, this.radius = 16});
  // Id de la actividad que se marca
  final int tallerId;
  // Tamaño del círculo blanco
  final double radius;

  @override
  Widget build(BuildContext context) {
    // select solo redibuja si cambia el favorito de ESTA actividad
    final fav = context.select<EstadoApp, bool>((s) => s.esFavorito(tallerId));
    return InkWell(
      customBorder: const CircleBorder(),
      // Al tocar, cambia entre favorito y no favorito
      onTap: () => context.read<EstadoApp>().toggleFavorito(tallerId),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          // Sombrita para que resalte sobre el banner
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // AnimatedSwitcher hace el efecto de cambio al marcar el corazón
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          // Escala el ícono al aparecer
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            // La key le dice a Flutter que son íconos distintos
            key: ValueKey(fav),
            size: radius + 2,
            color: fav ? ColoresApp.danger : ColoresApp.navy,
          ),
        ),
      ),
    );
  }
}

// Tarjeta completa de una actividad
class TarjetaTaller extends StatelessWidget {
  const TarjetaTaller(this.taller, {super.key});
  final Taller taller;

  @override
  Widget build(BuildContext context) {
    // Esquinas redondeadas de la tarjeta
    final radius = BorderRadius.circular(22);
    return Container(
      // Caja con borde fino y sombra suave
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: ColoresApp.line),
        boxShadow: ColoresApp.softShadow,
      ),
      // Material necesario para que se vea el efecto al tocar
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        // Recorta el banner con las esquinas redondeadas
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Al tocar abre el detalle de la actividad
          onTap: () => context.push('/actividad/${taller.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de arriba con el corazón en la esquina
              BannerTaller(
                taller,
                height: 110,
                child: Positioned(
                    top: 8, right: 8, child: BotonFavorito(taller.id)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la actividad, 1 renglón máximo
                    Text(
                      taller.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: ColoresApp.ink),
                    ),
                    const SizedBox(height: 6),
                    // Etiqueta de categoría con el color de esa categoría
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: taller.categoria.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        taller.categoria.etiqueta,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: taller.categoria.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Nombre del instructor
                    Text(
                      taller.instructor.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: ColoresApp.muted, fontSize: 11),
                    ),
                    // Días y horario
                    Text(
                      taller.horarioTexto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: ColoresApp.muted, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    // Lugares disponibles
                    EtiquetaCupo(taller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}