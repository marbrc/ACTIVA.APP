import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../../../nucleo/componentes/avisos.dart';

class PantallaReportes extends StatelessWidget {
  const PantallaReportes({super.key});

  void _export(BuildContext context, String formato) {
    // TODO: generar el archivo real (paquetes pdf / excel o desde el backend)
    context.read<EstadoApp>().registrarReporte('Inscripciones por actividad', formato);
    ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: Text('Reporte $formato generado (simulado)')));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final talleres = s.talleres;
    final maxV = talleres.fold<int>(1, (m, t) => t.inscritos > m ? t.inscritos : m);
    final alumnos = s.todosAlumnos;
    final con60 = alumnos.where((a) => s.horasAlumno(a) >= metaHoras).length;
    final pct = alumnos.isEmpty ? 0.0 : con60 / alumnos.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Reportes',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          const Text('Resumen del ciclo $periodoSimulado',
              style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 14),
          TarjetaApp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inscripciones por actividad',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                            Text('${t.inscritos}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              width: 26,
                              height: 110 * t.inscritos / maxV + 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [ColoresApp.primary, ColoresApp.teal],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(t.nombre.split(' ').first,
                                style: const TextStyle(fontSize: 10)),
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
                      Text('${(pct * 100).round()} %',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alumnos con 60 horas',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          '$con60 de ${alumnos.length} alumnos ya completaron su actividad paraescolar.',
                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => _export(context, 'PDF'),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Exportar PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => _export(context, 'Excel'),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Exportar Excel'),
                ),
              ),
            ],
          ),
          if (s.reportes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Reportes generados',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: ColoresApp.navy)),
            const SizedBox(height: 10),
            for (final r in s.reportes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TarjetaApp(
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: ColoresApp.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('${r.tipo} · ${r.formato}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Text(fechaLarga(r.fecha),
                          style: const TextStyle(color: Colors.black45, fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
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

  void _soon(BuildContext c) => ScaffoldMessenger.of(c)
      .showSnackBar(avisoSnack(content: Text('Próximamente')));

  @override
  Widget build(BuildContext context) {
    final a = context.watch<EstadoApp>().admin;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: ColoresApp.navy,
              child: Text('CP',
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Coordinación de Paraescolares',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [Chip(label: Text(a.cargo)), const Chip(label: Text('UTNG'))],
          ),
          const SizedBox(height: 16),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: ListTile.divideTiles(context: context, tiles: [
                _item(Icons.person, 'Instructores',
                    () => context.push('/admin/instructores')),
                _item(Icons.calendar_today, 'Periodo escolar', () => _soon(context)),
                _item(Icons.description, 'Validación de horas', () => _soon(context)),
                _item(Icons.notifications, 'Avisos generales', () => _soon(context)),
                _item(Icons.settings, 'Configuración', () => _soon(context)),
              ]).toList(),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/bienvenida'),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: ColoresApp.danger)),
          ),
        ],
      ),
    );
  }
}