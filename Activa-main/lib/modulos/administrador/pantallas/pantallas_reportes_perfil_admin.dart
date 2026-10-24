import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../modelos/enums.dart';
import '../../../nucleo/componentes/avatar_activa.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/dialogo_confirmar.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/servicios/documentos.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import 'pantallas_seguimiento_admin.dart';

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _EstadoReportes();
}

class _EstadoReportes extends State<PantallaReportes> {
  int _vista = 0; // 0 resumen, 1 alumnos, 2 instructores, 3 encuestas

  // genera el archivo real (PDF, Word o Excel) y lo descarga
  Future<void> _export(BuildContext context, String formato) async {
    final s = context.read<EstadoApp>();
    final m = ScaffoldMessenger.of(context);
    try {
      await Documentos.exportarReporte(formato, s);
      s.registrarReporte('Inscripciones por actividad', formato);
      m.showSnackBar(
        avisoSnack(
          content: Text('Reporte $formato generado'),
          tipo: TipoToast.exito,
        ),
      );
    } catch (_) {
      m.showSnackBar(
        avisoSnack(
          content: const Text('No se pudo generar el reporte'),
          tipo: TipoToast.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final talleres = s.talleres;
    final maxV = talleres.fold<int>(
      1,
      (m, t) => t.inscritos > m ? t.inscritos : m,
    );
    final alumnos = s.todosAlumnos;
    final con60 = alumnos.where((a) => s.horasAlumno(a) >= metaHoras).length;
    final pct = alumnos.isEmpty ? 0.0 : con60 / alumnos.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Reportes',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          const Text(
            'Resumen del ciclo $periodoSimulado',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (i, nombre) in const [
                  'Resumen',
                  'Alumnos',
                  'Instructores',
                  'Encuestas',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(nombre),
                      selected: _vista == i,
                      onSelected: (_) => setState(() => _vista = i),
                    ),
                  ),
              ],
            ),
          ),
          if (s.solicitudesPendientes > 0) ...[
            const SizedBox(height: 12),
            TarjetaApp(
              onTap: () => context.push('/admin/solicitudes'),
              child: Row(
                children: [
                  const Icon(
                    Icons.mark_email_unread_rounded,
                    color: ColoresApp.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${s.solicitudesPendientes} solicitud(es) de instructores pendientes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (_vista == 0) ...[
            TarjetaApp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inscripciones por actividad',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 170,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final t in talleres)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${t.inscritos}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 26,
                                height: 110 * t.inscritos / maxV + 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: const LinearGradient(
                                    colors: [
                                      ColoresApp.primary,
                                      ColoresApp.teal,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.nombre.split(' ').first,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TarjetaApp(
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: pct,
                            strokeWidth: 8,
                            backgroundColor: ColoresApp.background,
                            color: ColoresApp.teal,
                          ),
                        ),
                        Text(
                          '${(pct * 100).round()} %',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alumnos con 60 horas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$con60 de ${alumnos.length} alumnos ya completaron su actividad paraescolar.',
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
            const SizedBox(height: 12),
            // botones de exportar: PDF, Word y Excel
            Row(
              children: [
                for (final (f, ic) in const [
                  ('PDF', Icons.picture_as_pdf_rounded),
                  ('Word', Icons.description_rounded),
                  ('Excel', Icons.table_chart_rounded),
                ]) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => _export(context, f),
                      icon: Icon(ic, size: 18),
                      label: Text(f),
                    ),
                  ),
                  if (f != 'Excel') const SizedBox(width: 8),
                ],
              ],
            ),
            if (s.reportes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Reportes generados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.navy,
                ),
              ),
              const SizedBox(height: 10),
              for (final r in s.reportes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TarjetaApp(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description,
                          color: ColoresApp.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${r.tipo} · ${r.formato}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          fechaLarga(r.fecha),
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ], // <- cierra el if (_vista == 0)
          if (_vista == 1) const VistaAlumnosAdmin(),
          if (_vista == 2) const VistaInstructoresAdmin(),
          if (_vista == 3) const VistaEncuestasAdmin(),
        ],
      ),
    );
  }
}

class PantallaPerfilAdmin extends StatelessWidget {
  const PantallaPerfilAdmin({super.key});

  Widget _item(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: CircleAvatar(
      backgroundColor: ColoresApp.background,
      child: Icon(icon, color: ColoresApp.primary, size: 20),
    ),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    trailing: const Icon(Icons.chevron_right, color: Colors.black38),
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    final a = context.watch<EstadoApp>().admin;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Center(
            child: AvatarActiva(
              rol: Rol.admin,
              iniciales: 'CP',
              radio: 46,
              borde: true,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Coordinación de Paraescolares',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              Chip(label: Text(a.cargo)),
              const Chip(label: Text('UTNG')),
            ],
          ),
          const SizedBox(height: 16),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  _item(
                    Icons.mark_email_unread_rounded,
                    'Solicitudes de instructores',
                    () => context.push('/admin/solicitudes'),
                  ),
                  _item(
                    Icons.forum_rounded,
                    'Chats grupales',
                    () => context.push('/chats'),
                  ),
                  _item(
                    Icons.person,
                    'Instructores',
                    () => context.push('/admin/instructores'),
                  ),
                  _item(
                    Icons.calendar_today,
                    'Periodo escolar',
                    () => context.push('/admin/periodo'),
                  ),
                  _item(
                    Icons.description,
                    'Validación de horas',
                    () => context.push('/admin/validacion-horas'),
                  ),
                  _item(
                    Icons.notifications,
                    'Avisos generales',
                    () => context.push('/admin/avisos'),
                  ),
                  _item(
                    Icons.edit,
                    'Editar perfil',
                    () => context.push('/perfil/editar'),
                  ),
                  _item(
                    Icons.settings,
                    'Configuración',
                    () => context.push('/perfil/configuracion'),
                  ),
                ],
              ).toList(),
            ),
          ),
          TextButton(
            onPressed: () => cerrarSesionConfirmando(context),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: ColoresApp.danger),
            ),
          ),
        ],
      ),
    );
  }
}