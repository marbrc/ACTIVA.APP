// ===================================================================
// pantallas_admin_extra.dart
// pantallas del perfil del admin que decian "proximamente":
// periodo escolar, validacion de horas y avisos generales
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../../../modelos/enums.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';

// ───────────────────── periodo escolar ─────────────────────
class PantallaPeriodoEscolar extends StatefulWidget {
  const PantallaPeriodoEscolar({super.key});
  @override
  State<PantallaPeriodoEscolar> createState() => _EstadoPeriodoEscolar();
}

class _EstadoPeriodoEscolar extends State<PantallaPeriodoEscolar> {
  bool _inscripcionesAbiertas = true; // interruptor de inscripciones
  bool _bajasAbiertas = true;

  Widget _fila(IconData icono, String titulo, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(icono, color: ColoresApp.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(valor, style: const TextStyle(color: ColoresApp.muted)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return EstructuraSubpantalla(
      title: 'Periodo escolar',
      fallback: '/admin/perfil',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TarjetaApp(
            child: Column(
              children: [
                _fila(Icons.calendar_today, 'Periodo', periodoSimulado),
                const Divider(height: 1),
                _fila(Icons.timer, 'Meta de horas', '$metaHoras horas'),
                const Divider(height: 1),
                _fila(
                  Icons.groups,
                  'Actividades',
                  '${context.watch<EstadoApp>().talleres.length}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.how_to_reg,
                    color: ColoresApp.primary,
                  ),
                  title: const Text(
                    'Inscripciones abiertas',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  value: _inscripcionesAbiertas,
                  onChanged: (v) => setState(() => _inscripcionesAbiertas = v),
                ),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.exit_to_app,
                    color: ColoresApp.primary,
                  ),
                  title: const Text(
                    'Permitir bajas',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  value: _bajasAbiertas,
                  onChanged: (v) => setState(() => _bajasAbiertas = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BotonActiva(
            etiqueta: 'Guardar periodo',
            alPresionar: () => ScaffoldMessenger.of(context).showSnackBar(
              avisoSnack(content: const Text('Periodo actualizado')),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── validacion de horas ─────────────────────
class PantallaValidacionHoras extends StatefulWidget {
  const PantallaValidacionHoras({super.key});
  @override
  State<PantallaValidacionHoras> createState() => _EstadoValidacionHoras();
}

class _EstadoValidacionHoras extends State<PantallaValidacionHoras> {
  // lista de horas reportadas por instructores (de ejemplo)
  late final List<({String alumno, String actividad, int horas})> _pendientes =
      [
        (alumno: 'Ana Sofía Ramírez', actividad: 'Voleibol', horas: 6),
        (alumno: 'Diego A. Torres', actividad: 'Ajedrez', horas: 4),
        (alumno: 'Fernanda Ibarra', actividad: 'Danza folclórica', horas: 8),
        (alumno: 'Jorge L. Camacho', actividad: 'Teatro', horas: 5),
      ];

  void _resolver(int i, bool aprobar) {
    final p = _pendientes[i];
    setState(() => _pendientes.removeAt(i));
    ScaffoldMessenger.of(context).showSnackBar(
      avisoSnack(
        content: Text(
          aprobar
              ? 'Horas de ${p.alumno} aprobadas, cambios guardados'
              : 'Horas de ${p.alumno} rechazadas',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EstructuraSubpantalla(
      title: 'Validación de horas',
      fallback: '/admin/perfil',
      child: _pendientes.isEmpty
          ? const Center(
              child: Text(
                'No hay horas por validar',
                style: TextStyle(color: ColoresApp.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _pendientes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = _pendientes[i];
                return TarjetaApp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.alumno,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ColoresApp.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.actividad} · ${p.horas} horas reportadas',
                        style: const TextStyle(
                          color: ColoresApp.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                              ),
                              onPressed: () => _resolver(i, false),
                              child: const Text('Rechazar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                              ),
                              onPressed: () => _resolver(i, true),
                              child: const Text('Aprobar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ───────────────────── avisos generales ─────────────────────
class PantallaAvisosGenerales extends StatelessWidget {
  const PantallaAvisosGenerales({super.key});

  // hoja de abajo para escribir un aviso nuevo
  void _nuevo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider<EstadoApp>.value(
        value: context.read<EstadoApp>(),
        child: const _HojaNuevoAviso(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final avisos = s.avisos;
    return EstructuraSubpantalla(
      title: 'Avisos generales',
      fallback: '/admin/perfil',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BotonActiva(
            etiqueta: 'Nuevo aviso',
            icono: Icons.add_rounded,
            alPresionar: () => _nuevo(context),
          ),
          const SizedBox(height: 16),
          for (final a in avisos) ...[
            TarjetaApp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(a.tipo.etiqueta)),
                      const Spacer(),
                      Text(
                        tiempoRelativo(a.fecha),
                        style: const TextStyle(
                          color: ColoresApp.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    a.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ColoresApp.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(a.mensaje, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    s.tallerPorId(a.tallerId).nombre,
                    style: const TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _HojaNuevoAviso extends StatefulWidget {
  const _HojaNuevoAviso();
  @override
  State<_HojaNuevoAviso> createState() => _EstadoHojaNuevoAviso();
}

class _EstadoHojaNuevoAviso extends State<_HojaNuevoAviso> {
  final _titulo = TextEditingController();
  final _mensaje = TextEditingController();
  int? _tallerId; // actividad elegida

  @override
  void dispose() {
    _titulo.dispose();
    _mensaje.dispose();
    super.dispose();
  }

  void _publicar() {
    if (_tallerId == null ||
        _titulo.text.trim().isEmpty ||
        _mensaje.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: const Text('Completa todos los campos requeridos')),
      );
      return;
    }
    context.read<EstadoApp>().publicarAviso(
      tallerId: _tallerId!,
      tipo: TipoAviso.informativo,
      titulo: _titulo.text,
      mensaje: _mensaje.text,
    );
    final m = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    m.showSnackBar(avisoSnack(content: const Text('Aviso publicado')));
  }

  @override
  Widget build(BuildContext context) {
    final talleres = context.read<EstadoApp>().talleres;
    return Padding(
      // sube la hoja cuando sale el teclado
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo aviso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ColoresApp.navy,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _tallerId,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.groups),
                hintText: 'Actividad',
              ),
              items: [
                for (final t in talleres)
                  DropdownMenuItem(value: t.id, child: Text(t.nombre)),
              ],
              onChanged: (v) => setState(() => _tallerId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titulo,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.title),
                hintText: 'Título',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mensaje,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Mensaje'),
            ),
            const SizedBox(height: 18),
            BotonActiva(etiqueta: 'Publicar aviso', alPresionar: _publicar),
          ],
        ),
      ),
    );
  }
}
