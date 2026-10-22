import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../datos/estado_app.dart';
import '../../../modelos/enums.dart';

class PantallaAvisos extends StatelessWidget {
  const PantallaAvisos({super.key});

  (Color, IconData) _style(TipoAviso t) => switch (t) {
    TipoAviso.cambioHorario => (ColoresApp.warning, Icons.access_time),
    TipoAviso.informativo => (ColoresApp.primary, Icons.person),
    TipoAviso.recordatorio => (ColoresApp.teal, Icons.star),
    TipoAviso.cancelacion => (ColoresApp.danger, Icons.cancel),
  };

  @override
  Widget build(BuildContext context) {
    final avisos = context.watch<EstadoApp>().avisos;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 14),
          if (avisos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('No tienes avisos')),
            ),
          for (final a in avisos)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TarjetaApp(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: _style(a.tipo).$1
                          .withValues(alpha: 0.18),
                      child: Icon(_style(a.tipo).$2, color: _style(a.tipo).$1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (esNuevo(a.fecha))
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: ColoresApp.primary,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                tiempoRelativo(a.fecha),
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.mensaje,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
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
    );
  }
}
