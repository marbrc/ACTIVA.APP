import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../datos/estado_app.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/servicios/documentos.dart';
import '../../../nucleo/tema/tema_app.dart';

class PantallaInscripcionExitosa extends StatelessWidget {
  const PantallaInscripcionExitosa({super.key, required this.folio});
  final String folio;

  @override
  Widget build(BuildContext context) {
    final ins = context.read<EstadoApp>().inscripcionPorFolio(folio);
    if (ins == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/alumno'),
            child: const Text('Comprobante no encontrado. Volver'),
          ),
        ),
      );
    }
    final t = ins.taller;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ColoresApp.navy,
              side: const BorderSide(color: ColoresApp.line),
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
            onPressed: () => context.go('/alumno/actividades'),
          ),
        ),
        title: const Text('Comprobante'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: ColoresApp.teal.withValues(alpha: 0.25),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: ColoresApp.teal,
                  child: Icon(Icons.check, color: Colors.white, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Inscripción exitosa!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ColoresApp.navy,
              ),
            ),
            Text(
              'Ya formas parte de ${t.nombre}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TarjetaApp(
              child: Column(
                children: [
                  _Fila('Nombre', ins.alumno.nombreCompleto),
                  _Fila('Número de control', ins.alumno.numeroControl),
                  _Fila('Actividad', t.nombre),
                  _Fila('Horario', t.horarioTexto.replaceAll(' | ', ' · ')),
                  _Fila('Lugar', t.lugar),
                  _Fila('Instructor', t.instructor.nombreCompleto),
                  const Divider(height: 28),
                  Row(
                    children: [
                      QrImageView(
                        data: ins.folio,
                        size: 96,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Folio de inscripción',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              ins.folio,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Presenta este código con tu instructor.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: ColoresApp.teal),
                  SizedBox(width: 10),
                  Text(
                    'Cada paso cuenta. ¡Sigue sumando experiencias!',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/alumno/actividades'),
              child: const Text('Ver mis actividades'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
              ),
              onPressed: () => descargarPdfConfirmando(
                context,
                nombreDoc: 'Comprobante ${ins.folio}',
                generar: () => Documentos.comprobanteInscripcion(ins),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Descargar comprobante'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}