// ===================================================================
// Botón de ACTIVA: se encoge al presionar, tiene sombra que cambia,
// ondita y estado de carga. Úsalo en lugar de FilledButton.
// ===================================================================

import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

enum VarianteBoton { principal, claro, cristal, contorno }

class BotonActiva extends StatefulWidget {
  const BotonActiva({
    super.key,
    required this.etiqueta,
    required this.alPresionar,
    this.icono,
    this.variante = VarianteBoton.principal,
    this.cargando = false,
  });

  final String etiqueta;
  final VoidCallback? alPresionar;
  final IconData? icono;
  final VarianteBoton variante;
  final bool cargando;

  @override
  State<BotonActiva> createState() => _EstadoBotonActiva();
}

class _EstadoBotonActiva extends State<BotonActiva> {
  bool _presionado = false;

  bool get _habilitado => widget.alPresionar != null && !widget.cargando;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(32);
    final abajo = _presionado && _habilitado;

    final Color fg;
    final BoxDecoration deco;

    switch (widget.variante) {
      case VarianteBoton.principal:
        fg = Colors.white;
        deco = BoxDecoration(
          borderRadius: radio,
          gradient: const LinearGradient(
            colors: [ColoresApp.primary, ColoresApp.wave],
          ),
          boxShadow: abajo
              ? []
              : [
                  BoxShadow(
                    color: ColoresApp.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        );
      case VarianteBoton.claro:
        fg = ColoresApp.navy;
        deco = BoxDecoration(
          borderRadius: radio,
          color: Colors.white,
          boxShadow: abajo
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        );
      case VarianteBoton.cristal:
        fg = Colors.white;
        deco = BoxDecoration(
          borderRadius: radio,
          color: Colors.white.withValues(alpha: abajo ? 0.18 : 0.10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
        );
      case VarianteBoton.contorno:
        fg = ColoresApp.primary;
        deco = BoxDecoration(
          borderRadius: radio,
          color: abajo ? ColoresApp.mist : Colors.transparent,
          border: Border.all(
            color: ColoresApp.primary.withValues(alpha: 0.5),
            width: 1.4,
          ),
        );
    }

    final contenido = widget.cargando
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.etiqueta,
                style: TextStyle(
                  fontFamily: FuentesApp.century,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              if (widget.icono != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icono, size: 20, color: fg),
              ],
            ],
          );

    return AnimatedScale(
      scale: abajo ? 0.96 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: widget.alPresionar == null ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          decoration: deco,
          child: Material(
            color: Colors.transparent,
            borderRadius: radio,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _habilitado ? widget.alPresionar : null,
              onHighlightChanged: (v) => setState(() => _presionado = v),
              child: Center(child: contenido),
            ),
          ),
        ),
      ),
    );
  }
}
