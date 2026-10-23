import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';

// Estrellitas de un promedio (ej. 4.3 -> 4 llenas, 1 vacía)
class EstrellasPromedio extends StatelessWidget {
  const EstrellasPromedio(this.valor, {super.key, this.tamano = 16});
  final double? valor;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final v = valor ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            v >= i - 0.25
                ? Icons.star_rounded
                : (v >= i - 0.75
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded),
            size: tamano,
            color: ColoresApp.warning,
          ),
      ],
    );
  }
}

Widget _titulo(String t) => Padding(
  padding: const EdgeInsets.only(top: 18, bottom: 10),
  child: Text(
    t,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: ColoresApp.navy,
    ),
  ),
);

Widget _mini(String numero, String etiqueta, Color color) => Expanded(
  child: TarjetaApp(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    child: Column(
      children: [
        Text(
          numero,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    ),
  ),
);

// ───────── Alumnos ─────────
class VistaAlumnosAdmin extends StatelessWidget {
  const VistaAlumnosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final alumnos = [...s.todosAlumnos]
      ..sort((a, b) => s.horasAlumno(a).compareTo(s.horasAlumno(b)));
    final completos = alumnos.where((a) => s.horasAlumno(a) >= metaHoras);
    final bajos = alumnos.where((a) => s.horasAlumno(a) < metaHoras * 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            _mini('${alumnos.length}', 'Alumnos', ColoresApp.primary),
            const SizedBox(width: 8),
            _mini('${completos.length}', 'Completaron', ColoresApp.teal),
            const SizedBox(width: 8),
            _mini('${bajos.length}', 'Bajo avance', ColoresApp.warning),
          ],
        ),
        _titulo('Avance por alumno (menor a mayor)'),
        for (final a in alumnos)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(
              builder: (_) {
                final h = s.horasAlumno(a);
                final p = (h / metaHoras).clamp(0.0, 1.0);
                final (estado, color) = h >= metaHoras
                    ? ('Completó', ColoresApp.teal)
                    : h >= metaHoras * 0.3
                    ? ('En progreso', ColoresApp.primary)
                    : ('Bajo avance', ColoresApp.warning);
                return TarjetaApp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.nombreCompleto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            estado,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Control: ${a.numeroControl} · $h / $metaHoras h',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: p,
                          minHeight: 8,
                          backgroundColor: ColoresApp.background,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ───────── Instructores ─────────
class VistaInstructoresAdmin extends StatelessWidget {
  const VistaInstructoresAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Seguimiento de instructores'),
        for (final i in s.instructores)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(
              builder: (_) {
                final prom = s.promedioInstructor(i.id);
                final grupos = s.talleres
                    .where((t) => t.instructor.id == i.id)
                    .map((t) => t.nombre)
                    .join(', ');
                return TarjetaApp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i.nombreCompleto,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        grupos.isEmpty ? i.especialidad : grupos,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${s.alumnosDeInstructor(i.id)} alumnos',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${s.listasRegistradasDe(i.id)} listas tomadas',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          EstrellasPromedio(prom),
                          const SizedBox(width: 6),
                          Text(
                            prom == null
                                ? 'Sin calificaciones'
                                : '${prom.toStringAsFixed(1)} (${s.respuestasDeInstructor(i.id)})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ───────── Encuestas ─────────
class VistaEncuestasAdmin extends StatelessWidget {
  const VistaEncuestasAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final general = s.promedioGeneralClubes;
    final comentarios = s.encuestas
        .where((e) => e.comentario.isNotEmpty)
        .take(6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TarjetaApp(
          child: Row(
            children: [
              Text(
                general == null ? '--' : general.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.navy,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EstrellasPromedio(general, tamano: 20),
                    Text(
                      '${s.encuestas.length} encuestas contestadas',
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
        _titulo('Calificación de los clubes'),
        for (final t in s.talleres)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TarjetaApp(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  EstrellasPromedio(s.promedioClub(t.id)),
                  const SizedBox(width: 6),
                  Text(
                    s.promedioClub(t.id) == null
                        ? '--'
                        : '${s.promedioClub(t.id)!.toStringAsFixed(1)} (${s.respuestasDeClub(t.id)})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        _titulo('Calificación de los instructores'),
        for (final i in s.instructores)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TarjetaApp(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      i.nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  EstrellasPromedio(s.promedioInstructor(i.id)),
                  const SizedBox(width: 6),
                  Text(
                    s.promedioInstructor(i.id) == null
                        ? '--'
                        : '${s.promedioInstructor(i.id)!.toStringAsFixed(1)} (${s.respuestasDeInstructor(i.id)})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        if (comentarios.isNotEmpty) ...[
          _titulo('Comentarios recientes'),
          for (final e in comentarios)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TarjetaApp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.tallerPorId(e.tallerId).nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: ColoresApp.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(e.comentario),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}