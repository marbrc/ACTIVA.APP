import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'aplicacion.dart';
import 'datos/almacen_cuentas.dart';
import 'datos/estado_app.dart';
import 'datos/sesion.dart';

// arranca la app con los 2 estados: datos (EstadoApp) y sesion (quien entro + fotos)
// antes de abrir la app se lee el archivo JSON con las cuentas guardadas
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final almacen = await AlmacenCuentas.cargar();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstadoApp(almacen)),
        ChangeNotifierProvider<EstadoSesion>(
          create: (_) => EstadoSesion(almacen),
        ),
      ],
      child: const AplicacionActiva(),
    ),
  );
}