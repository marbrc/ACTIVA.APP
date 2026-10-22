import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/tema/tema_app.dart';

class PantallaContrasenaActualizada extends StatelessWidget {
  const PantallaContrasenaActualizada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColoresApp.teal.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColoresApp.teal.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 38,
                    backgroundColor: ColoresApp.teal,
                    child: Icon(Icons.check, color: Colors.white, size: 44),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Contraseña actualizada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ya puedes iniciar sesión con tu nueva contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColoresApp.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: ColoresApp.teal),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Por seguridad, cerramos tus sesiones abiertas en otros dispositivos.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/inicio-sesion'),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
