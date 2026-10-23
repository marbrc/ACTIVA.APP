// ===================================================================
// pantalla_editar_perfil.dart
// editar perfil para los 3 roles (alumno, instructor y admin).
// arriba va la foto con un lapiz para cambiarla y abajo los datos
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../datos/estado_app.dart';
import '../../datos/sesion.dart';
import '../../modelos/enums.dart';
import '../../nucleo/componentes/avatar_activa.dart';
import '../../nucleo/componentes/avisos.dart';
import '../../nucleo/componentes/boton_activa.dart';
import '../../nucleo/componentes/estructura_subpantalla.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../nucleo/utilidades/formateadores.dart';

import '../../nucleo/componentes/dialogo_confirmar.dart';

class PantallaEditarPerfilGeneral extends StatefulWidget {
  const PantallaEditarPerfilGeneral({super.key});
  @override
  State<PantallaEditarPerfilGeneral> createState() =>
      _EstadoEditarPerfilGeneral();
}

class _EstadoEditarPerfilGeneral extends State<PantallaEditarPerfilGeneral> {
  final _form = GlobalKey<FormState>();
  late final Rol _rol = context.read<EstadoSesion>().rol ?? Rol.alumno;
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

  // guarda nombre y telefono (solo la alumna puede cambiarlos)
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
    context.read<EstadoApp>().actualizarPerfil(_nombre.text, _tel.text);
    final m = ScaffoldMessenger.of(context);
    context.pop();
    m.showSnackBar(avisoSnack(content: const Text('Perfil actualizado')));
  }

  Widget _etiqueta(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  // campo bloqueado (no se puede cambiar desde la app)
  Widget _bloqueado(IconData icono, String valor) => TextFormField(
    initialValue: valor,
    enabled: false,
    decoration: InputDecoration(prefixIcon: Icon(icono)),
  );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstadoApp>();
    final a = s.alumno, i = s.instructor, ad = s.admin;

    // datos segun el rol
    final ini = switch (_rol) {
      Rol.alumno => inicialesDe(a.nombre),
      Rol.instructor => iniciales(i.nombre, i.apellidoPaterno),
      Rol.admin => 'CP',
    };

    return EstructuraSubpantalla(
      title: 'Editar perfil',
      fallback: SesionRutas.panel(_rol),
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // foto con lapiz
            Center(
              child: GestureDetector(
                onTap: () => context.push('/perfil/foto'),
                child: Stack(
                  children: [
                    AvatarActiva(
                      rol: _rol,
                      iniciales: ini,
                      radio: 54,
                      borde: true,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: ColoresApp.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.push('/perfil/foto'),
                child: const Text('Cambiar foto'),
              ),
            ),

            // ---- alumna: puede editar nombre y telefono ----
            if (_rol == Rol.alumno) ...[
              _etiqueta('Nombre completo'),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    (v ?? '').trim().split(RegExp(r'\s+')).length >= 2
                    ? null
                    : 'Escribe nombre y apellido',
              ),
              _etiqueta('Correo institucional'),
              _bloqueado(Icons.email, a.correo),
              _etiqueta('Teléfono'),
              TextFormField(
                controller: _tel,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) {
                  final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return d.length == 10 ? null : 'Escribe 10 dígitos';
                },
              ),
              _etiqueta('Número de control'),
              _bloqueado(Icons.school, a.numeroControl),
              _etiqueta('Grupo'),
              _bloqueado(Icons.groups, a.grupo),
              const SizedBox(height: 28),
              BotonActiva(etiqueta: 'Guardar cambios', alPresionar: _guardar),
            ],

            // ---- instructor: datos solo de lectura ----
            if (_rol == Rol.instructor) ...[
              _etiqueta('Nombre completo'),
              _bloqueado(Icons.person, i.nombreCompleto),
              _etiqueta('Correo institucional'),
              _bloqueado(Icons.email, i.correo),
              _etiqueta('Especialidad'),
              _bloqueado(Icons.sports_volleyball, i.especialidad),
              const SizedBox(height: 16),
              const Text(
                'Tus datos los actualiza la coordinación de paraescolares.',
                style: TextStyle(color: ColoresApp.muted, fontSize: 12),
              ),
            ],

            // ---- admin: datos solo de lectura ----
            if (_rol == Rol.admin) ...[
              _etiqueta('Área'),
              _bloqueado(Icons.apartment, 'Coordinación de Paraescolares'),
              _etiqueta('Correo institucional'),
              _bloqueado(Icons.email, ad.correo),
              _etiqueta('Cargo'),
              _bloqueado(Icons.badge, ad.cargo),
            ],
          ],
        ),
      ),
    );
  }
}

// rutas de cada panel (para el boton de atras)
class SesionRutas {
  static String panel(Rol r) => EstadoSesion.rutaDe(r);
}
