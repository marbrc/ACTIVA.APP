import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'nucleo/tema/tema_app.dart';
import 'nucleo/rutas/rutas_app.dart';

class AplicacionActiva extends StatelessWidget {
  const AplicacionActiva({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'ACTIVA',
    debugShowCheckedModeBanner: false,
    theme: TemaApp.light,
    routerConfig: enrutadorApp,
    // Todo el sistema (calendario, reloj, menús) en español
    locale: const Locale('es', 'MX'),
    supportedLocales: const [Locale('es', 'MX'), Locale('es')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}
