import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../tema/tema_app.dart';

class EstructuraSubpantalla extends StatelessWidget {
  const EstructuraSubpantalla({
    super.key,
    required this.title,
    required this.child,
    this.fallback = '/bienvenida',
  });
  final String title;
  final Widget child;
  final String fallback; // a dónde ir si no hay pantalla previa

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: ColoresApp.navy,
            side: const BorderSide(color: ColoresApp.line),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(fallback),
        ),
      ),
      title: Text(title),
    ),
    body: SafeArea(child: child),
  );
}
