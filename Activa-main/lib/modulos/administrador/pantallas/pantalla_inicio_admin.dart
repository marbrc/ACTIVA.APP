import '../../../nucleo/componentes/avatar_activa.dart';
import '../../../modelos/enums.dart';
import '../../alumno/componentes/miniatura_taller.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/componentes/tarjeta_estadistica.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';

class PantallaInicioAdmin extends StatelessWidget {
  const PantallaInicioAdmin({super.key});

  Widget _action(IconData icon, String label, VoidCallback onTap) => Expanded(
    child: TarjetaApp(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: ColoresApp.primary),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final casi = s.talleres
        .where((t) => t.activo && t.hayCupo && t.cuposDisponibles <= 3)
        .toList();
    final activos = s.talleres.where((t) => t.activo).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel de coordinación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.navy,
                      ),
                    ),
                    Text(
                      'Ciclo $periodoSimulado',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const AvatarActiva(rol: Rol.admin, iniciales: 'CP', radio: 24),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TarjetaEstadistica(
                  Icons.groups,
                  '${s.todosAlumnos.length}',
                  'Estudiantes',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TarjetaEstadistica(
                  Icons.star,
                  '${s.talleres.length}',
                  'Actividades',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TarjetaEstadistica(
                  Icons.check_circle,
                  '${s.totalInscripciones}',
                  'Inscripciones',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TarjetaEstadistica(
                  Icons.event_seat,
                  '${s.totalCupos}',
                  'Cupos disp.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _action(
                Icons.add,
                'Nueva actividad',
                () => context.push('/admin/actividad/nuevo'),
              ),
              const SizedBox(width: 10),
              _action(
                Icons.person_add,
                'Instructores',
                () => context.push('/admin/instructores'),
              ),
              const SizedBox(width: 10),
              _action(
                Icons.bar_chart,
                'Reportes',
                () => context.go('/admin/reportes'),
              ),
            ],
          ),
          if (casi.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Por revisar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColoresApp.navy,
              ),
            ),
            const SizedBox(height: 10),
            TarjetaApp(
              onTap: () => context.go('/admin/actividades'),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ColoresApp.danger.withValues(alpha: 0.15),
                    child: const Icon(Icons.star, color: ColoresApp.danger),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actividades casi llenas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Con 3 cupos o menos',
                          style: TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${casi.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Actividades activas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 10),
          for (final t in activos)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TarjetaApp(
                onTap: () => context.push('/admin/actividad/${t.id}/editar'),
                child: Row(
                  children: [
                    MiniaturaTaller(t, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${t.inscritos} / ${t.cupoMaximo}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: t.inscritos / t.cupoMaximo,
                              minHeight: 7,
                              backgroundColor: ColoresApp.background,
                              color: t.hayCupo
                                  ? ColoresApp.teal
                                  : ColoresApp.danger,
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
