// ===================================================================
// avatar_activa.dart
// avatar redondo: muestra la foto de perfil si ya la puso,
// y si no, las iniciales sobre un degradado azul
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../datos/sesion.dart';
import '../../modelos/enums.dart';
import '../tema/tema_app.dart';

class AvatarActiva extends StatelessWidget {
  const AvatarActiva({
    super.key,
    required this.rol,
    required this.iniciales,
    this.radio = 24,
    this.borde = false,
  });

  final Rol rol; // de que rol es la foto
  final String iniciales; // texto si no hay foto
  final double radio;
  final bool borde; // aro clarito alrededor

  @override
  Widget build(BuildContext context) {
    // watch para que se redibuje cuando cambie la foto
    final foto = context.watch<EstadoSesion>().fotoDe(rol);

    final circulo = Container(
      width: radio * 2,
      height: radio * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColoresApp.primary, ColoresApp.navy],
        ),
        image: foto == null
            ? null
            : DecorationImage(image: MemoryImage(foto), fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: foto != null
          ? null
          : Text(
              iniciales,
              style: TextStyle(
                fontFamily: FuentesApp.century,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radio * 0.62,
              ),
            ),
    );

    if (!borde) return circulo;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColoresApp.sky.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      child: circulo,
    );
  }
}
