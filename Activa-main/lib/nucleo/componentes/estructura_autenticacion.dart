// ===================================================================
// Estructura de las pantallas de acceso: encabezado con olas, logo
// y hoja blanca con el formulario
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'aparicion_suave.dart';
import 'fondo_olas.dart';
import 'logo_app.dart';

class EstructuraAutenticacion extends StatelessWidget {
  const EstructuraAutenticacion({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoOlas(
        animar: false,
        nivelOlas: 0.2,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BotonAtrasCristal(
                          onTap:
                              onBack ??
                              () => context.canPop()
                                  ? context.pop()
                                  : context.go('/bienvenida'),
                        ),
                        const LogoApp(size: 48, hero: true),
                      ],
                    ),
                    const SizedBox(height: 26),
                    AparicionSuave(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AparicionSuave(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAtrasCristal extends StatelessWidget {
  const _BotonAtrasCristal({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.14),
    shape: CircleBorder(
      side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
    ),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: const SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    ),
  );
}
