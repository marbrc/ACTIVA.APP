import 'package:flutter/material.dart';
import '../tema/tema_app.dart';
import 'tarjeta_app.dart';

class TarjetaEstadistica extends StatelessWidget {
  const TarjetaEstadistica(this.icon, this.value, this.label, {super.key});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => TarjetaApp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ColoresApp.primary),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      );
}