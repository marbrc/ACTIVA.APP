import '../../../nucleo/componentes/avatar_activa.dart';
import '../../../modelos/enums.dart';
import '../../../datos/sesion.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../componentes/miniatura_taller.dart';
import '../../../nucleo/servicios/sonidos.dart';
import '../../../nucleo/componentes/avisos.dart';

import '../../../nucleo/componentes/dialogo_confirmar.dart';

void _soon(BuildContext c) =>
    ScaffoldMessenger.of(c)
        .showSnackBar(avisoSnack(content: Text('Próximamente')));

// Estructura común de las sub-pantallas (flecha atrás + título)
class _Sub extends StatelessWidget {
  const _Sub(this.title, this.child);
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: ColoresApp.background,
      scrolledUnderElevation: 0,
      leading: BackButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/alumno/perfil'),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: ColoresApp.navy,
        ),
      ),
    ),
    body: SafeArea(child: child),
  );
}

class _Linea extends StatelessWidget {
  const _Linea(this.label, this.value, {this.chip = false});
  final String label;
  final String value;
  final bool chip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ),
        Expanded(
          child: chip
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ColoresApp.teal.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: ColoresApp.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    ),
  );
}

// ───────────────────────── Perfil ─────────────────────────
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

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
    final a = context.watch<EstadoApp>().alumno;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: AvatarActiva(
              rol: Rol.alumno,
              iniciales: inicialesDe(a.nombre),
              radio: 46,
              borde: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            a.nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          Text(
            'Número de Control: ${a.numeroControl}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  _item(
                    Icons.school,
                    'Mis datos académicos',
                    () => context.push('/perfil/academico'),
                  ),
                  _item(
                    Icons.calendar_today,
                    'Mis actividades',
                    () => context.go('/alumno/actividades'),
                  ),
                  _item(
                    Icons.favorite,
                    'Mis favoritos',
                    () => context.push('/perfil/favoritos'),
                  ),
                  _item(
                    Icons.description,
                    'Mis comprobantes',
                    () => context.push('/perfil/comprobantes'),
                  ),
                  _item(
                    Icons.bar_chart,
                    'Mi progreso',
                    () => context.push('/perfil/progreso'),
                  ),
                  _item(
                    Icons.forum_rounded,
                    'Chats grupales',
                    () => context.push('/chats'),
                  ),
                  _item(
                    Icons.rate_review_rounded,
                    'Encuestas de mis clubes',
                    () => context.push('/encuestas'),
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
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
            ),
            onPressed: () => context.go('/admin'),
            child: const Text('Ver panel de coordinador (demo)'),
          ),
          TextButton(
            onPressed: () => cerrarSesionConfirmando(context),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Datos académicos ─────────────────────
class PantallaDatosAcademicos extends StatelessWidget {
  const PantallaDatosAcademicos({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final a = s.alumno;
    final h = s.horasRealizadas;
    return _Sub(
      'Mis datos académicos',
      ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TarjetaApp(
            child: Row(
              children: [
                AvatarActiva(
                  rol: Rol.alumno,
                  iniciales: inicialesDe(a.nombre),
                  radio: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.nombreCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Número de Control: ${a.numeroControl}',
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
          TarjetaApp(
            child: Column(
              children: [
                const _Linea(
                  'Universidad',
                  'Universidad Tecnológica del Norte de Guanajuato',
                ),
                _Linea('Carrera', a.carrera),
                _Linea('Grupo', a.grupo),
                const _Linea('Periodo', periodoSimulado),
                const _Linea('Estatus', 'Activo', chip: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TarjetaApp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Actividad paraescolar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '$h / $metaHoras horas',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (h / metaHoras).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: ColoresApp.background,
                    color: ColoresApp.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  h >= metaHoras
                      ? '¡Completaste tu actividad paraescolar!'
                      : 'Te faltan ${metaHoras - h} horas para completar tu actividad paraescolar.',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Comprobantes ─────────────────────
class _Doc {
  const _Doc(this.esHoras, this.titulo, this.detalle, {this.locked = false});
  final bool esHoras;
  final String titulo;
  final String detalle;
  final bool locked;
}

class PantallaComprobantes extends StatefulWidget {
  const PantallaComprobantes({super.key});
  @override
  State<PantallaComprobantes> createState() => _EstadoPantallaComprobantes();
}

class _EstadoPantallaComprobantes extends State<PantallaComprobantes> {
  int _tab = 0; // 0 inscripciones, 1 horas, 2 todos

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final h = s.horasRealizadas;
    final docs = <_Doc>[
      for (final i in s.misInscripciones)
        _Doc(
          false,
          'Comprobante de inscripción',
          '${i.taller.nombre} · Folio ${i.folio}\nEmitido el ${fechaLarga(i.fechaInscripcion)}',
        ),
      _Doc(
        true,
        'Constancia parcial de horas',
        '$h de $metaHoras horas acumuladas\nActualizada hoy',
      ),
      _Doc(
        true,
        'Constancia final de horas',
        'Se habilita al completar las $metaHoras horas',
        locked: h < metaHoras,
      ),
    ];
    final visibles = docs
        .where((d) => _tab == 2 || (_tab == 1) == d.esHoras)
        .toList();

    return _Sub(
      'Mis comprobantes',
      ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              for (final (i, t) in [
                'Inscripciones',
                'Horas',
                'Todos',
              ].indexed) ...[
                ChoiceChip(
                  label: Text(t),
                  selected: _tab == i,
                  onSelected: (_) => setState(() => _tab = i),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
          for (final d in visibles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TarjetaApp(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ColoresApp.background,
                      child: Icon(
                        Icons.description,
                        color: d.locked ? Colors.black26 : ColoresApp.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.titulo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            d.detalle,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        d.locked ? Icons.lock : Icons.download,
                        color: d.locked ? Colors.black26 : ColoresApp.primary,
                      ),
                      onPressed: d.locked ? null : () => _soon(context),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Presenta tus comprobantes con tu instructor o en la coordinación cuando te los pidan.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Progreso ─────────────────────
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

class PantallaProgreso extends StatelessWidget {
  const PantallaProgreso({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final h = s.horasRealizadas;
    final pct = (h / metaHoras).clamp(0.0, 1.0);
    return _Sub(
      'Mi progreso',
      ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TarjetaApp(
            child: Column(
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 14,
                          backgroundColor: ColoresApp.background,
                          color: ColoresApp.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$h',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: ColoresApp.navy,
                            ),
                          ),
                          Text(
                            'de $metaHoras horas',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(pct * 100).round()} % completado',
                  style: const TextStyle(
                    color: ColoresApp.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  h >= metaHoras
                      ? '¡Meta del cuatrimestre cumplida!'
                      : 'Te faltan ${metaHoras - h} horas para tu meta del cuatrimestre.',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Estadistica(
                Icons.star,
                '${s.misInscripciones.length}',
                'Actividades',
              ),
              const SizedBox(width: 10),
              const _Estadistica(
                Icons.access_time,
                '$horasMesSimulado h',
                'Este mes',
              ),
              const SizedBox(width: 10),
              const _Estadistica(
                Icons.check_circle,
                '$asistenciaSimulado %',
                'Asistencia',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TarjetaApp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Horas por actividad',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                for (final i in s.misInscripciones)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        MiniaturaTaller(i.taller, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i.taller.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (s.horasDe(i.folio) / metaHoras).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  minHeight: 6,
                                  backgroundColor: ColoresApp.background,
                                  color: ColoresApp.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${s.horasDe(i.folio)} h',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Editar perfil ─────────────────────
class PantallaEditarPerfil extends StatefulWidget {
  const PantallaEditarPerfil({super.key});
  @override
  State<PantallaEditarPerfil> createState() => _EstadoPantallaEditarPerfil();
}

class _EstadoPantallaEditarPerfil extends State<PantallaEditarPerfil> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(
    text: context.read<EstadoApp>().alumno.nombreCompleto,
  );
  late final _tel = TextEditingController(
    text: context.read<EstadoApp>().alumno.telefono ?? '',
  );

  @override
  void dispose() {
    _nombre.dispose();
    _tel.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<EstadoApp>().actualizarPerfil(_nombre.text, _tel.text);
    final m = ScaffoldMessenger.of(context);
    context.pop();
    m.showSnackBar(avisoSnack(content: Text('Perfil actualizado')));
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _locked(IconData icon, String value) => TextFormField(
    initialValue: value,
    enabled: false,
    decoration: InputDecoration(prefixIcon: Icon(icon)),
  );

  @override
  Widget build(BuildContext context) {
    final a = context.read<EstadoApp>().alumno;
    return _Sub(
      'Editar perfil',
      Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: ColoresApp.navy,
                child: Text(
                  inicialesDe(a.nombre),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => _soon(context),
                child: const Text('Cambiar foto'),
              ),
            ),
            _label('Nombre completo'),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
              validator: (v) =>
                  (v ?? '').trim().split(RegExp(r'\s+')).length >= 2
                  ? null
                  : 'Escribe nombre y apellido',
            ),
            _label('Correo institucional'),
            _locked(Icons.email, a.correo),
            _label('Teléfono'),
            TextFormField(
              controller: _tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.phone)),
              validator: (v) {
                final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                return d.length == 10 ? null : 'Escribe 10 dígitos';
              },
            ),
            _label('Número de control'),
            _locked(Icons.school, a.numeroControl),
            _label('Grupo'),
            _locked(Icons.groups, a.grupo),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Configuración ─────────────────────
class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});
  @override
  State<PantallaConfiguracion> createState() => _EstadoPantallaConfiguracion();
}

class _EstadoPantallaConfiguracion extends State<PantallaConfiguracion> {
  // TODO: persistir en backend (hoy no hay tabla de preferencias)
  bool _avisos = true, _horario = true, _recordatorios = true, _cupos = false;

  Widget _sw(String t, IconData i, bool v, ValueChanged<bool> f) =>
      SwitchListTile(
        secondary: Icon(i, color: ColoresApp.primary),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        value: v,
        onChanged: (x) => setState(() => f(x)),
      );

  Widget _nav(String t, IconData i, VoidCallback f, {String? trailing}) =>
      ListTile(
        leading: Icon(i, color: ColoresApp.primary),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(trailing, style: const TextStyle(color: Colors.black45)),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
        onTap: f,
      );

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
    child: Text(
      t,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: ColoresApp.navy,
        fontSize: 16,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return _Sub(
      'Configuración',
      ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _title('Notificaciones'),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _sw(
                  'Avisos de actividades',
                  Icons.notifications,
                  _avisos,
                  (v) => _avisos = v,
                ),
                _sw(
                  'Cambios de horario',
                  Icons.access_time,
                  _horario,
                  (v) => _horario = v,
                ),
                _sw(
                  'Recordatorios de clase',
                  Icons.calendar_today,
                  _recordatorios,
                  (v) => _recordatorios = v,
                ),
                _sw('Cupos disponibles', Icons.star, _cupos, (v) => _cupos = v),
                _sw(
                  'Sonidos de la app',
                  Icons.volume_up_rounded,
                  Sonidos.activados,
                  (v) => Sonidos.activados = v,
                ),
              ],
            ),
          ),
          _title('Cuenta'),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _nav(
                  'Cambiar contraseña',
                  Icons.lock,
                  () => context.push('/olvide-contrasena'),
                ),
                _nav(
                  'Idioma',
                  Icons.language,
                  () => context.push('/perfil/idioma'),
                  trailing: 'Español',
                ),
              ],
            ),
          ),
          _title('Privacidad y ayuda'),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _nav(
                  'Aviso de privacidad',
                  Icons.shield,
                  () => context.push('/perfil/privacidad'),
                ),
                _nav(
                  'Ayuda y soporte',
                  Icons.help_outline,
                  () => context.push('/perfil/ayuda'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => cerrarSesionConfirmando(context),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: ColoresApp.danger),
            ),
          ),
          const Center(
            child: Text(
              'ACTIVA · Versión 1.0',
              style: TextStyle(color: Colors.black38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
