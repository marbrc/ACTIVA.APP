import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'datos/sesion.dart';
import 'nucleo/tema/tema_app.dart';
import 'nucleo/rutas/rutas_app.dart';

class AplicacionActiva extends StatelessWidget {
  const AplicacionActiva({super.key});

  @override
  Widget build(BuildContext context) {
    final idioma = context.watch<EstadoSesion>().idioma;
    return MaterialApp.router(
      title: 'ACTIVA',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.light,
      routerConfig: enrutadorApp,
      // calendario, reloj y menús del sistema cambian con el idioma elegido
      locale: Locale(idioma),
      supportedLocales: const [Locale('es'), Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}