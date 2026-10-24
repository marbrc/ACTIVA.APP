import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../datos/estado_app.dart';
import '../../datos/sesion.dart';
import '../../modelos/enums.dart';
import '../../nucleo/componentes/avatar_activa.dart';
import '../../nucleo/componentes/avisos.dart';
import '../../nucleo/componentes/boton_activa.dart';
import '../../nucleo/componentes/estructura_subpantalla.dart';
import '../../nucleo/componentes/dialogo_confirmar.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../nucleo/utilidades/formateadores.dart';
import '../../nucleo/utilidades/validadores.dart';

class PantallaEditarPerfilGeneral extends StatefulWidget {
  const PantallaEditarPerfilGeneral({super.key});
  @override
  State<PantallaEditarPerfilGeneral> createState() => _EstadoEditarPerfilGeneral();
}

class _EstadoEditarPerfilGeneral extends State<PantallaEditarPerfilGeneral> {
  final _form = GlobalKey<FormState>();
  late final Rol _rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
  late final _nombre =
      TextEditingController(text: context.read<EstadoApp>().alumno.nombreCompleto);
  late final _tel = TextEditingController(
    text: (context.read<EstadoApp>().alumno.telefono ?? '').replaceAll(RegExp(r'\D'), ''),
  );
  late final _usuario =
      TextEditingController(text: context.read<EstadoSesion>().usuarioDe(_rol));

  @override
  void dispose() {
    _nombre.dispose();
    _tel.dispose();
    _usuario.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final ok = await confirmarAccion(
      context,
      titulo: '¿Guardar cambios?',
      mensaje: 'Se actualizarán tus datos de perfil.',
      textoConfirmar: 'Guardar',
      icono: Icons.save_rounded,
    );
    if (!ok || !mounted) return;
    if (_rol == Rol.alumno) {
      context.read<EstadoApp>().actualizarPerfil(_nombre.text, _tel.text);
    }
    context.read<EstadoSesion>().cambiarUsuario(_rol, _usuario.text);
    final m = ScaffoldMessenger.of(context);
    context.pop();
    m.showSnackBar(avisoSnack(content: const Text('Perfil actualizado')));
  }

  // hoja: tomar foto (abre la cámara directo) / galería / quitar
  Future<void> _menuFoto() async {
    final ses = context.read<EstadoSesion>();
    final tiene = ses.fotoDe(_rol) != null;
    final r = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded, color: ColoresApp.primary),
            title: const Text('Tomar una foto'),
            onTap: () => Navigator.pop(c, 'camara'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: ColoresApp.primary),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(c, 'galeria'),
          ),
          if (tiene)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: ColoresApp.danger),
              title: const Text('Quitar foto actual'),
              onTap: () => Navigator.pop(c, 'quitar'),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (r == null || !mounted) return;
    if (r == 'quitar') {
      final ok = await confirmarAccion(
        context,
        titulo: '¿Quitar tu foto?',
        mensaje: 'Se mostrarán tus iniciales en lugar de la foto.',
        textoConfirmar: 'Quitar',
        icono: Icons.delete_outline_rounded,
        peligro: true,
      );
      if (ok && mounted) ses.quitarFoto(_rol);
    } else {
      context.push('/perfil/foto?fuente=$r'); // abre cámara o galería directo
    }
  }

  Widget _etiqueta(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  Widget _bloqueado(IconData icono, String valor) => TextFormField(
    initialValue: valor,
    enabled: false,
    decoration: InputDecoration(prefixIcon: Icon(icono)),
  );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final a = s.alumno, i = s.instructor, ad = s.admin;
    final ini = switch (_rol) {
      Rol.alumno => inicialesDe(a.nombre),
      Rol.instructor => iniciales(i.nombre, i.apellidoPaterno),
      Rol.admin => 'CP',
    };

    return EstructuraSubpantalla(
      title: 'Editar perfil',
      fallback: EstadoSesion.rutaDe(_rol),
      child: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _menuFoto,
                child: Stack(children: [
                  AvatarActiva(rol: _rol, iniciales: ini, radio: 54, borde: true),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: ColoresApp.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.photo_camera_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ),
            ),
            Center(
              child: TextButton(onPressed: _menuFoto, child: const Text('Cambiar foto')),
            ),

            if (_rol == Rol.alumno) ...[
              _etiqueta('Nombre completo'),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                inputFormatters: formatoNombre(max: 60),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
                validator: validarNombreCompleto,
              ),
            ],

            _etiqueta('Nombre de usuario'),
            TextFormField(
              controller: _usuario,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.alternate_email_rounded),
                helperText: 'Letras minúsculas, números y _. También sirve para iniciar sesión.',
                helperMaxLines: 2,
              ),
              validator: (v) {
                final e = validarUsuario(v);
                if (e != null) return e;
                if (!context.read<EstadoSesion>().usuarioDisponible(v!, _rol)) {
                  return 'Ese usuario ya está en uso';
                }
                return null;
              },
            ),

            if (_rol == Rol.alumno) ...[
              _etiqueta('Correo institucional'),
              _bloqueado(Icons.email, a.correo),
              _etiqueta('Teléfono'),
              TextFormField(
                controller: _tel,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(prefixIcon: Icon(Icons.phone)),
                validator: (v) => (v ?? '').length == 10 ? null : 'Escribe 10 dígitos',
              ),
              _etiqueta('Número de control'),
              _bloqueado(Icons.school, a.numeroControl),
              _etiqueta('Grupo'),
              _bloqueado(Icons.groups, a.grupo),
            ],

            if (_rol == Rol.instructor) ...[
              _etiqueta('Nombre completo'),
              _bloqueado(Icons.person, i.nombreCompleto),
              _etiqueta('Correo institucional'),
              _bloqueado(Icons.email, i.correo),
              _etiqueta('Especialidad'),
              _bloqueado(Icons.sports_volleyball, i.especialidad),
              const SizedBox(height: 12),
              const Text('Tus datos personales los actualiza la coordinación de paraescolares.',
                  style: TextStyle(color: ColoresApp.muted, fontSize: 12)),
            ],

            if (_rol == Rol.admin) ...[
              _etiqueta('Área'),
              _bloqueado(Icons.apartment, 'Coordinación de Paraescolares'),
              _etiqueta('Correo institucional'),
              _bloqueado(Icons.email, ad.correo),
              _etiqueta('Cargo'),
              _bloqueado(Icons.badge, ad.cargo),
            ],

            const SizedBox(height: 28),
            BotonActiva(etiqueta: 'Guardar cambios', alPresionar: _guardar),
          ],
        ),
      ),
    );
  }
}