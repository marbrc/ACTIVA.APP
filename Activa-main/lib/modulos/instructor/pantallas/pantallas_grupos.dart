import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../../alumno/componentes/miniatura_taller.dart';

class PantallaGrupos extends StatelessWidget {
  const PantallaGrupos({super.key});

  @override
  Widget build(BuildContext context) {
    final grupos = context.watch<EstadoApp>().misGrupos;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Mis grupos',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          Text('${grupos.length} ${grupos.length == 1 ? 'grupo activo' : 'grupos activos'} este cuatrimestre',
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 14),
          for (final t in grupos)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TarjetaApp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MiniaturaTaller(t, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(t.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 18)),
                        ),
                        Text('${t.inscritos} / ${t.cupoMaximo}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Text(t.horarioTexto, style: const TextStyle(fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Text(t.lugar, style: const TextStyle(fontSize: 12)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: t.inscritos / t.cupoMaximo,
                        minHeight: 8,
                        backgroundColor: ColoresApp.background,
                        color: t.hayCupo ? ColoresApp.primary : ColoresApp.danger,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () => context.push('/instructor/grupo/${t.id}'),
                            icon: const Icon(Icons.groups, size: 18),
                            label: const Text('Ver alumnos'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48)),
                            onPressed: () => context.push(
                                '/instructor/pasar-lista/${t.id}?fecha=${fechaIso(t.sesionReciente())}'),
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Pasar lista'),
                          ),
                        ),
                      ],
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

class PantallaAlumnosGrupo extends StatefulWidget {
  const PantallaAlumnosGrupo({super.key, required this.tallerId});
  final int tallerId;
  @override
  State<PantallaAlumnosGrupo> createState() => _EstadoPantallaAlumnosGrupo();
}

class _EstadoPantallaAlumnosGrupo extends State<PantallaAlumnosGrupo> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final t = s.tallerPorId(widget.tallerId);
    final q = _search.text.trim().toLowerCase();
    final lista = s
        .alumnosDe(t.id)
        .where((a) =>
            a.nombreCompleto.toLowerCase().contains(q) ||
            a.numeroControl.contains(q))
        .toList();

    return EstructuraSubpantalla(
      title: t.nombre,
      fallback: '/instructor/grupos',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar alumno o número de control',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('${t.inscritos} inscritos')),
              Chip(label: Text('${t.cuposDisponibles} lugares disponibles')),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text('Alumno', style: TextStyle(color: Colors.black45, fontSize: 12)),
              Spacer(),
              Text('Asistencias', style: TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          if (lista.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(child: Text('No hay alumnos')),
            ),
          for (final a in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TarjetaApp(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ColoresApp.background,
                      child: Text(iniciales(a.nombre, a.apellidoPaterno),
                          style: const TextStyle(
                              color: ColoresApp.navy, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.nombreCompleto,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(a.numeroControl,
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      asistenciaPreviaSimulado[a.numeroControl] == null
                          ? '—'
                          : '${asistenciaPreviaSimulado[a.numeroControl]![0]} / ${asistenciaPreviaSimulado[a.numeroControl]![1]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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