import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'aplicacion.dart';
import 'datos/estado_app.dart';
import 'datos/sesion.dart';

// arranca la app con los 2 estados: datos (EstadoApp) y sesion (quien entro + fotos)
void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => EstadoApp()),
      ChangeNotifierProvider(create: (_) => EstadoSesion()),
    ],
    child: const AplicacionActiva(),
  ),
);
