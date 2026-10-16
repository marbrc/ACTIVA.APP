import 'package:flutter/material.dart';
import '../tema/tema_app.dart';

// Tarjeta blanca con sombra suave; se hunde un poquito al tocarla
class TarjetaApp extends StatefulWidget {
  const TarjetaApp({super.key, required this.child, this.onTap, this.padding});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  State<TarjetaApp> createState() => _EstadoTarjetaApp();
}

class _EstadoTarjetaApp extends State<TarjetaApp> {
  bool _abajo = false;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(22);
    return AnimatedScale(
      scale: _abajo ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radio,
          border: Border.all(color: ColoresApp.line),
          boxShadow: ColoresApp.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radio,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null
                ? null
                : (v) => setState(() => _abajo = v),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
