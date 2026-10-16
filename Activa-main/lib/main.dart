import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'aplicacion.dart';
import 'datos/estado_app.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => EstadoApp(),
        child: const AplicacionActiva(),
      ),
    );