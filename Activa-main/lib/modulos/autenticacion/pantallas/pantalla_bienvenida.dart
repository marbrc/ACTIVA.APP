// ===================================================================
// Pantalla de BIENVENIDA: logo flotando, olas animadas, beneficios
// y botones con transición
// (Más adelante aquí se puede cambiar el fondo por un video)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/aparicion_suave.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../nucleo/componentes/fondo_olas.dart';
import '../../../nucleo/componentes/logo_app.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  static const _ms = Duration(milliseconds: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoOlas(
        child: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      const AparicionSuave(child: _LogoFlotante()),
                      const SizedBox(height: 28),
                      AparicionSuave(
                        delay: _ms * 150,
                        child: const Text(
                          'ACTIVA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AparicionSuave(
                        delay: _ms * 250,
                        child: Text(
                          'Activación de Clubes y Talleres Institucionales\npara la Vida Académica',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColoresApp.sky.withValues(alpha: 0.95),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      AparicionSuave(
                        delay: _ms * 350,
                        child: const Text(
                          'Tu universidad también\nse vive fuera del aula',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      AparicionSuave(
                        delay: _ms * 450,
                        child: const Row(
                          children: [
                            Expanded(
                              child: _Beneficio(
                                Icons.timer_outlined,
                                'Suma horas',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _Beneficio(
                                Icons.groups_rounded,
                                'Haz amigos',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _Beneficio(
                                Icons.auto_awesome_rounded,
                                'Vive experiencias',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _Beneficio(
                                Icons.trending_up_rounded,
                                'Crece',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      AparicionSuave(
                        delay: _ms * 550,
                        child: Column(
                          children: [
                            BotonActiva(
                              etiqueta: 'Iniciar sesión',

                              variante: VarianteBoton.claro,
                              alPresionar: () => context.push('/inicio-sesion'),
                            ),
                            const SizedBox(height: 12),
                            BotonActiva(
                              etiqueta: 'Crear cuenta',
                              variante: VarianteBoton.cristal,
                              alPresionar: () => context.push('/registro'),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: ColoresApp.sky,
                              ),
                              onPressed: () => context.go('/alumno'),
                              child: const Text('Explorar sin cuenta'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Logo con brillo que flota suavemente
class _LogoFlotante extends StatefulWidget {
  const _LogoFlotante();

  @override
  State<_LogoFlotante> createState() => _EstadoLogoFlotante();
}

class _EstadoLogoFlotante extends State<_LogoFlotante>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: const LogoApp(size: 128, glow: true, hero: true),
    builder: (_, child) => Transform.translate(
      offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
      child: child,
    ),
  );
}

class _Beneficio extends StatelessWidget {
  const _Beneficio(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
    ),
    child: Column(
      children: [
        Icon(icon, color: ColoresApp.sky, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}
