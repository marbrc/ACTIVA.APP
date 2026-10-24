// ===================================================================
// pantallas_instructores_admin.dart
// Panel del administrador para manejar instructores:
//   - lista (activos / desactivados)
//   - crear instructor con cuenta de acceso (contraseña temporal)
//   - editar datos, activar / desactivar, asignar taller
//   - restablecer contraseña
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/almacen_cuentas.dart';
import '../../../datos/estado_app.dart';
import '../../../modelos/taller.dart';
import '../../../modelos/usuario.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/dialogo_confirmar.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/utilidades/reglas_contrasena.dart';
import '../../../nucleo/utilidades/validadores.dart';

// ventanita que muestra la contraseña temporal para dársela al instructor
Future<void> _mostrarContrasenaTemporal(
  BuildContext context, {
  required String nombre,
  required String correo,
  required String contrasena,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'Contraseña temporal',
        style: TextStyle(fontWeight: FontWeight.w800, color: ColoresApp.navy),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entrégasela a $nombre. Entra con:'),
          const SizedBox(height: 10),
          Text('Correo: $correo', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.mist,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              contrasena,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'La app le pedirá cambiarla en su primer inicio de sesión. '
            'Después de cerrar esta ventana ya no se podrá volver a ver.',
            style: TextStyle(fontSize: 12, color: ColoresApp.muted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: contrasena)),
          child: const Text('Copiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Listo'),
        ),
      ],
    ),
  );
}

// ===================================================================
// LISTA
// ===================================================================
class PantallaInstructoresAdmin extends StatelessWidget {
  const PantallaInstructoresAdmin({super.key});

  Future<void> _cambiarEstado(BuildContext context, Instructor i) async {
    final s = context.read<EstadoApp>();
    final msg = ScaffoldMessenger.of(context);
    final activar = !i.activo;
    final ok = await confirmarAccion(
      context,
      titulo: activar ? '¿Activar instructor?' : '¿Desactivar instructor?',
      mensaje: activar
          ? '${i.nombreCompleto} podrá iniciar sesión otra vez.'
          : '${i.nombreCompleto} ya no podrá iniciar sesión. Sus talleres se quedan como están.',
      textoConfirmar: activar ? 'Activar' : 'Desactivar',
      icono: activar ? Icons.check_circle_outline : Icons.block_rounded,
      peligro: !activar,
    );
    if (!ok) return;
    final error = await s.cambiarActivoInstructor(i.id, activar);
    msg.showSnackBar(
      avisoSnack(
        content: Text(
          error ??
              (activar
                  ? 'Cambios guardados. Instructor activado'
                  : 'Cambios guardados. Instructor desactivado'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final lista = s.instructores;
    final activos = lista.where((i) => i.activo).length;
    return EstructuraSubpantalla(
      title: 'Instructores',
      fallback: '/admin/perfil',
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '$activos activos · ${lista.length - activos} desactivados',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                for (final i in lista)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TarjetaApp(
                      onTap: () =>
                          context.push('/admin/instructores/${i.id}/editar'),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: i.activo ? 1 : 0.45,
                            child: CircleAvatar(
                              backgroundColor: ColoresApp.background,
                              child: Text(
                                iniciales(i.nombre, i.apellidoPaterno),
                                style: const TextStyle(
                                  color: ColoresApp.navy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i.nombreCompleto,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: i.activo ? null : Colors.black45,
                                  ),
                                ),
                                Text(
                                  '${i.especialidad} · ${s.alumnosDeInstructor(i.id)} alumnos',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                                Builder(
                                  builder: (_) {
                                    final ts = s.talleresDeInstructor(i.id);
                                    return Text(
                                      ts.isEmpty
                                          ? 'Sin taller asignado'
                                          : ts.map((t) => t.nombre).join(', '),
                                      style: const TextStyle(
                                        color: ColoresApp.muted,
                                        fontSize: 11,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    if (!i.activo)
                                      const _Etiqueta(
                                        'Desactivado',
                                        ColoresApp.danger,
                                      ),
                                    if (!s.tieneCuentaInstructor(i.id))
                                      const _Etiqueta(
                                        'Ejemplo · sin cuenta',
                                        ColoresApp.muted,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'editar') {
                                context.push(
                                  '/admin/instructores/${i.id}/editar',
                                );
                              } else {
                                _cambiarEstado(context, i);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'estado',
                                child: Text(i.activo ? 'Desactivar' : 'Activar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/admin/instructores/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Agregar instructor'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, this.color);
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ===================================================================
// FORMULARIO (crear / editar)
// ===================================================================
class PantallaFormularioInstructor extends StatefulWidget {
  const PantallaFormularioInstructor({super.key, this.instructorId});

  /// null = crear; con id = editar
  final int? instructorId;

  @override
  State<PantallaFormularioInstructor> createState() =>
      _EstadoPantallaFormularioInstructor();
}

class _EstadoPantallaFormularioInstructor
    extends State<PantallaFormularioInstructor> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _pat = TextEditingController();
  final _mat = TextEditingController();
  final _correo = TextEditingController();
  final _esp = TextEditingController();
  final _pass = TextEditingController(text: AlmacenCuentas.generarTemporal());

  Instructor? _edit;
  bool _activo = true;
  int? _tallerId;
  bool _guardando = false;

  bool get _editando => widget.instructorId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.instructorId;
    if (id != null) {
      final i = context.read<EstadoApp>().instructorPorId(id);
      _edit = i;
      if (i != null) {
        _nombre.text = i.nombre;
        _pat.text = i.apellidoPaterno;
        _mat.text = i.apellidoMaterno;
        _correo.text = i.correo;
        _esp.text = i.especialidad;
        _activo = i.activo;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _pat, _mat, _correo, _esp, _pass]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  void _snack(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(avisoSnack(content: Text(t)));

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final s = context.read<EstadoApp>();
    final msg = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final n = capitalizar(_nombre.text);
    final p = capitalizar(_pat.text);
    final m = capitalizar(_mat.text);
    final esp = capitalizar(_esp.text);
    final correo = _correo.text.trim().toLowerCase();

    final ok = await confirmarAccion(
      context,
      titulo: _editando ? '¿Guardar cambios?' : '¿Agregar instructor?',
      mensaje: _editando
          ? 'Se actualizarán los datos de $n $p.'
          : 'Se dará de alta a $n $p con una contraseña temporal.',
      textoConfirmar: _editando ? 'Guardar' : 'Agregar',
      icono: _editando ? Icons.save_rounded : Icons.person_add_alt_1_rounded,
    );
    if (!ok || !mounted) return;
    setState(() => _guardando = true);

    // ---------------- CREAR ----------------
    if (!_editando) {
      final r = await s.crearInstructor(
        nombre: n,
        paterno: p,
        materno: m,
        correo: correo,
        especialidad: esp,
        contrasenaTemporal: _pass.text,
      );
      if (!mounted) return;
      if (r.error != null) {
        setState(() => _guardando = false);
        _snack(r.error!);
        return;
      }
      String? errorTaller;
      if (_tallerId != null) {
        errorTaller = await s.asignarTaller(r.instructor!.id, _tallerId!);
      }
      if (!mounted) return;
      await _mostrarContrasenaTemporal(
        context,
        nombre: '$n $p',
        correo: correo,
        contrasena: _pass.text,
      );
      if (!mounted) return;
      router.pop();
      msg.showSnackBar(
        avisoSnack(
          content: Text(
            errorTaller == null
                ? 'Instructor agregado'
                : 'Instructor agregado. $errorTaller',
          ),
        ),
      );
      return;
    }

    // ---------------- EDITAR ----------------
    final id = widget.instructorId!;
    String? error = await s.editarInstructor(
      id,
      nombre: n,
      paterno: p,
      materno: m,
      correo: correo,
      especialidad: esp,
    );
    error ??= await s.cambiarActivoInstructor(id, _activo);
    if (error == null && _tallerId != null) {
      error = await s.asignarTaller(id, _tallerId!);
    }
    if (!mounted) return;
    setState(() => _guardando = false);
    if (error != null) {
      _snack(error);
      return;
    }
    router.pop();
    msg.showSnackBar(avisoSnack(content: const Text('Cambios guardados')));
  }

  Future<void> _restablecer() async {
    final s = context.read<EstadoApp>();
    final i = _edit!;
    final ok = await confirmarAccion(
      context,
      titulo: '¿Restablecer contraseña?',
      mensaje:
          'Se creará una contraseña temporal nueva. La actual dejará de servir y ${i.nombre} tendrá que cambiarla al entrar.',
      textoConfirmar: 'Restablecer',
      icono: Icons.lock_reset_rounded,
      peligro: true,
    );
    if (!ok || !mounted) return;
    final temporal = AlmacenCuentas.generarTemporal();
    final error = await s.restablecerContrasenaInstructor(i.id, temporal);
    if (!mounted) return;
    if (error != null) {
      _snack(error);
      return;
    }
    await _mostrarContrasenaTemporal(
      context,
      nombre: i.nombreCompleto,
      correo: i.correo,
      contrasena: temporal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final edit = _edit;

    // si abrieron una ruta con un id que ya no existe
    if (_editando && edit == null) {
      return const EstructuraSubpantalla(
        title: 'Editar instructor',
        fallback: '/admin/instructores',
        child: Center(child: Text('No se encontró al instructor')),
      );
    }

    final tieneCuenta = edit != null && s.tieneCuentaInstructor(edit.id);
    final List<Taller> asignados = edit == null
        ? <Taller>[]
        : s.talleresDeInstructor(edit.id);
    final disponibles = s.talleres
        .where((t) => t.activo && t.instructor.id != edit?.id)
        .toList();

    return EstructuraSubpantalla(
      title: _editando ? 'Editar instructor' : 'Agregar instructor',
      fallback: '/admin/instructores',
      child: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_editando && !tieneCuenta)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColoresApp.mist,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Este instructor es de ejemplo: no tiene cuenta para iniciar '
                  'sesión y sus cambios no se conservan al cerrar la app.',
                  style: TextStyle(fontSize: 12, color: ColoresApp.muted),
                ),
              ),
            _label('Nombre(s)'),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              inputFormatters: formatoNombre(),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
              validator: (v) => validarNombre(v, campo: 'El nombre'),
            ),
            _label('Apellido paterno'),
            TextFormField(
              controller: _pat,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              inputFormatters: formatoNombre(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => validarNombre(v, campo: 'El apellido'),
            ),
            _label('Apellido materno (opcional)'),
            TextFormField(
              controller: _mat,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              inputFormatters: formatoNombre(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  validarNombre(v, campo: 'El apellido', obligatorio: false),
            ),
            _label('Correo institucional'),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                helperText: 'Con este correo inicia sesión',
              ),
              validator: (v) {
                final e = validarCorreoInstitucional(v);
                if (e != null) return e;
                final c = v!.trim().toLowerCase();
                final repetido = s.instructores.any(
                  (i) => i.id != edit?.id && i.correo == c,
                );
                return repetido ? 'Ese correo ya está registrado' : null;
              },
            ),
            _label('Especialidad'),
            TextFormField(
              controller: _esp,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: formatoNombre(),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.sports)),
              validator: (v) =>
                  validarNombre(v, campo: 'La especialidad', min: 3),
            ),

            // ---- contraseña temporal (solo al crear) ----
            if (!_editando) ...[
              _label('Contraseña temporal'),
              TextFormField(
                controller: _pass,
                autocorrect: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.key_rounded),
                  helperText:
                      'Se la das al instructor; la cambia en su primer inicio de sesión',
                  helperMaxLines: 2,
                  suffixIcon: IconButton(
                    tooltip: 'Generar otra',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => setState(
                      () => _pass.text = AlmacenCuentas.generarTemporal(),
                    ),
                  ),
                ),
                validator: (v) => ReglasContrasena(v ?? '').valid
                    ? null
                    : 'Mínimo 8 caracteres, una mayúscula y un número',
              ),
            ],

            // ---- estado (solo al editar) ----
            if (_editando) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
                title: const Text(
                  'Instructor activo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Si lo desactivas ya no podrá iniciar sesión',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              _label('Talleres asignados'),
              if (asignados.isEmpty)
                const Text(
                  'Todavía no tiene taller',
                  style: TextStyle(color: ColoresApp.muted, fontSize: 12),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in asignados) Chip(label: Text(t.nombre)),
                  ],
                ),
            ],

            // ---- asignar taller ----
            _label(_editando ? 'Asignar otro taller' : 'Asignar taller (opcional)'),
            DropdownButtonFormField<int?>(
              initialValue: _tallerId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.event_available),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Ninguno por ahora'),
                ),
                for (final t in disponibles)
                  DropdownMenuItem<int?>(
                    value: t.id,
                    child: Text(
                      '${t.nombre} · hoy: ${t.instructor.nombreCompleto}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _tallerId = v),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Un taller tiene un solo instructor: si ya tenía otro, pasa a este. '
                'Se revisa que no choque con sus horarios.',
                style: TextStyle(color: ColoresApp.muted, fontSize: 11),
              ),
            ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(
                _editando ? 'Guardar cambios' : 'Guardar instructor',
              ),
            ),
            if (_editando && tieneCuenta) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _restablecer,
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text('Restablecer contraseña'),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}