import '../../../nucleo/componentes/avatar_activa.dart';
import '../../../modelos/enums.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../../alumno/componentes/miniatura_taller.dart';

import '../../../nucleo/componentes/accesos_rapidos.dart';

class PantallaInicioInstructor extends StatelessWidget {
  const PantallaInicioInstructor({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final i = s.instructor;
    final grupos = s.misGrupos;
    final alumnos = grupos.fold<int>(0, (a, t) => a + t.inscritos);
    final t = grupos.isEmpty ? null : grupos.first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${i.nombre.split(' ').first}!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.navy,
                      ),
                    ),
                    Text(
                      'Instructor de ${i.especialidad}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AvatarActiva(
                rol: Rol.instructor,
                iniciales: iniciales(i.nombre, i.apellidoPaterno),
                radio: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (t == null)
            const TarjetaApp(child: Text('Aún no tienes grupos asignados'))
          else
            _TarjetaSesion(taller: t),
          const SizedBox(height: 14),
          Row(
            children: [
              _Estadistica(Icons.groups, '$alumnos', 'Alumnos'),
              const SizedBox(width: 10),
              const _Estadistica(
                Icons.check_circle,
                '$asistenciaInstructorSimulado %',
                'Asistencia',
              ),
              const SizedBox(width: 10),
              _Estadistica(Icons.apps, '${grupos.length}', 'Grupos'),
            ],
          ),
          const AccesoChats(), const SizedBox(height: 14),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mis grupos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.navy,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/instructor/grupos'),
                child: const Text('Ver todos ›'),
              ),
            ],
          ),
          for (final g in grupos)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TarjetaApp(
                onTap: () => context.push('/instructor/grupo/${g.id}'),
                child: Row(
                  children: [
                    MiniaturaTaller(g, size: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            g.horarioTexto,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${g.inscritos} / ${g.cupoMaximo}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaSesion extends StatelessWidget {
  const _TarjetaSesion({required this.taller});
  final dynamic taller; // Taller

  @override
  Widget build(BuildContext context) {
    final t = taller;
    final f = t.sesionReciente() as DateTime;
    final hoy = mismoDia(f, DateTime.now());
    final h = t.horarioDe(f);
    return TarjetaApp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                hoy ? 'Sesión de hoy' : 'Última sesión',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: ColoresApp.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hoy ? 'Hoy · ${h.horaInicio}' : fechaConDia(f),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MiniaturaTaller(t, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.nombre as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${h.horaInicio} – ${h.horaFin}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      t.lugar as String,
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(
                    '/instructor/pasar-lista/${t.id}?fecha=${fechaIso(f)}',
                  ),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Pasar lista'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => context.push('/instructor/grupo/${t.id}'),
                  icon: const Icon(Icons.groups, size: 18),
                  label: const Text('Ver alumnos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: TarjetaApp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ColoresApp.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
