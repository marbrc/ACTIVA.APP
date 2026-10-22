// ===================================================================
// pantalla_historial_asistencia.dart
// lista de todas las listas de asistencia que el instructor ya guardo
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';

class PantallaHistorialAsistencia extends StatelessWidget {
  const PantallaHistorialAsistencia({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final ids = s.misGrupos.map((t) => t.id).toSet();

    // cada llave es "tallerId|fecha", se separa y se ordena por fecha
    final filas =
        <({String taller, DateTime fecha, int presentes, int total})>[];
    s.asistencias.forEach((llave, marcas) {
      final partes = llave.split('|');
      final id = int.parse(partes[0]);
      if (!ids.contains(id)) return; // solo sus grupos
      filas.add((
        taller: s.tallerPorId(id).nombre,
        fecha: DateTime.parse(partes[1]),
        presentes: marcas.values.where((v) => v).length,
        total: marcas.length,
      ));
    });
    filas.sort((a, b) => b.fecha.compareTo(a.fecha));

    return EstructuraSubpantalla(
      title: 'Historial de asistencia',
      fallback: '/instructor/perfil',
      child: filas.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Todavía no has guardado ninguna lista. Cuando pases lista, aparecerá aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColoresApp.muted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: filas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final f = filas[i];
                return TarjetaApp(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: ColoresApp.mist,
                        child: Icon(Icons.check_circle, color: ColoresApp.teal),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.taller,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: ColoresApp.navy,
                              ),
                            ),
                            Text(
                              fechaConDia(f.fecha),
                              style: const TextStyle(
                                color: ColoresApp.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${f.presentes} / ${f.total}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ColoresApp.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
