import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../nucleo/componentes/dialogo_confirmar.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';

// ───────── Lista de encuestas (una por club inscrito) ─────────
class PantallaEncuestasAlumno extends StatelessWidget {
  const PantallaEncuestasAlumno({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final clubes = s.misInscripciones
        .map((i) => s.tallerPorId(i.taller.id))
        .toList();

    return EstructuraSubpantalla(
      title: 'Encuestas',
      fallback: '/alumno/perfil',
      child: clubes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Cuando te inscribas a un club podrás calificarlo aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Tu opinión ayuda a mejorar los clubes y a reconocer '
                  'a los mejores instructores.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 14),
                for (final t in clubes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Builder(
                      builder: (_) {
                        final lista = s.encuestaContestada(t.id);
                        return TarjetaApp(
                          onTap: () {
                            if (lista) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                avisoSnack(
                                  content: const Text(
                                    'Ya contestaste la encuesta de este club',
                                  ),
                                  tipo: TipoToast.info,
                                ),
                              );
                            } else {
                              context.push('/encuesta/${t.id}');
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Instructor: ${t.instructor.nombreCompleto}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(lista ? 'Contestada' : 'Pendiente'),
                                backgroundColor:
                                    (lista
                                            ? ColoresApp.teal
                                            : ColoresApp.warning)
                                        .withValues(alpha: 0.15),
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

// ───────── Formulario de la encuesta ─────────
class PantallaEncuesta extends StatefulWidget {
  const PantallaEncuesta({super.key, required this.tallerId});
  final int tallerId;

  @override
  State<PantallaEncuesta> createState() => _EstadoEncuesta();
}

class _EstadoEncuesta extends State<PantallaEncuesta> {
  int _club = 0;
  int _instructor = 0;
  final _comentario = TextEditingController();

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final ok = await confirmarAccion(
      context,
      titulo: '¿Enviar encuesta?',
      mensaje: 'No podrás modificar tus respuestas después de enviarlas.',
      textoConfirmar: 'Enviar',
      icono: Icons.rate_review_rounded,
    );
    if (!ok || !mounted) return;
    context.read<EstadoApp>().enviarEncuesta(
      tallerId: widget.tallerId,
      club: _club,
      instructorCalif: _instructor,
      comentario: _comentario.text,
    );
    final m = ScaffoldMessenger.of(context);
    context.pop();
    m.showSnackBar(
      avisoSnack(
        content: const Text('Encuesta enviada, ¡gracias por tu opinión!'),
        tipo: TipoToast.exito,
      ),
    );
  }

  Widget _pregunta(String texto, int valor, ValueChanged<int> alCambiar) =>
      TarjetaApp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texto, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    iconSize: 38,
                    onPressed: () => alCambiar(i),
                    icon: Icon(
                      i <= valor
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: ColoresApp.warning,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.read<EstadoApp>().tallerPorId(widget.tallerId);
    return EstructuraSubpantalla(
      title: 'Encuesta · ${t.nombre}',
      fallback: '/encuestas',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _pregunta(
            '¿Cómo calificas el club de ${t.nombre}?',
            _club,
            (v) => setState(() => _club = v),
          ),
          const SizedBox(height: 12),
          _pregunta(
            '¿Cómo calificas a ${t.instructor.nombreCompleto}?',
            _instructor,
            (v) => setState(() => _instructor = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comentario,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Comentarios o sugerencias (opcional)',
            ),
          ),
          const SizedBox(height: 20),
          BotonActiva(
            etiqueta: 'Enviar encuesta',
            icono: Icons.send_rounded,
            alPresionar: (_club > 0 && _instructor > 0) ? _enviar : null,
          ),
          if (_club == 0 || _instructor == 0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Califica el club y al instructor para poder enviar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}