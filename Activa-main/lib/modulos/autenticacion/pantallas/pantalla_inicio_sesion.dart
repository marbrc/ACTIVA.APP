// ===================================================================
// pantalla_inicio_sesion.dart
// inicio de sesion con 3 roles. el usuario se escribe como usuario_rol
// (mar_alumna, mar_instructor, mar_admin) y entra a su propio panel.
// tambien sirve el numero de control o el correo institucional.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/sesion.dart';
import '../../../modelos/enums.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/estructura_autenticacion.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../nucleo/componentes/avisos.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});
  @override
  State<PantallaInicioSesion> createState() => _EstadoPantallaInicioSesion();
}

class _EstadoPantallaInicioSesion extends State<PantallaInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // revisa los datos y manda a cada rol a su panel
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final rol = context.read<EstadoSesion>().iniciarSesion(
      _userCtrl.text,
      _passCtrl.text,
    );
    if (rol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: const Text('Usuario o contraseña incorrectos')),
      );
      return;
    }
    context.go(EstadoSesion.rutaDe(rol));
  }

  // llena los campos con una cuenta de prueba
  void _usar(CuentaDemo c) {
    setState(() {
      _userCtrl.text = c.usuario;
      _passCtrl.text = c.contrasena;
    });
  }

  IconData _icono(Rol r) => switch (r) {
    Rol.alumno => Icons.school_rounded,
    Rol.instructor => Icons.sports_rounded,
    Rol.admin => Icons.admin_panel_settings_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return EstructuraAutenticacion(
      title: 'Inicia sesión',
      subtitle: 'Bienvenido de vuelta a ACTIVA',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuario, número de control o correo',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _userCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_rounded),
                hintText: 'mar_alumna',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Contraseña',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo requerido' : null,
            ),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                ),
                const Text('Recordarme'),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/olvide-contrasena'),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BotonActiva(etiqueta: 'Iniciar sesión', alPresionar: _submit),
            const SizedBox(height: 12),
            BotonActiva(
              etiqueta: 'Explorar sin cuenta',
              variante: VarianteBoton.contorno,
              alPresionar: () {
                context.read<EstadoSesion>().rol = Rol.alumno;
                context.go('/alumno');
              },
            ),
            const SizedBox(height: 18),

            // cuentas de prueba: al tocar una se llenan los campos
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColoresApp.mist,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: ColoresApp.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cuentas de prueba (contraseña: $contrasenaDemo)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in cuentasDemo)
                        ActionChip(
                          avatar: Icon(
                            _icono(c.rol),
                            size: 18,
                            color: ColoresApp.primary,
                          ),
                          label: Text(c.usuario),
                          onPressed: () => _usar(c),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.push('/registro'),
                child: const Text('¿No tienes cuenta? Crear cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
