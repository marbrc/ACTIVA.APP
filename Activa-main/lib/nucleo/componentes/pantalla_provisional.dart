import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PantallaProvisional extends StatelessWidget {
  const PantallaProvisional(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
        onPressed: () => context.go('/bienvenida'),
        child: const Text('Cerrar sesión'),
      ),
    ),
  );
}
