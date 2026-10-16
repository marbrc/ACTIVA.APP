import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/estructura_autenticacion.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../datos/simulados/datos_simulados.dart';
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

  // Login falso: según el usuario decide a qué panel entra.
  // Después esto lo reemplaza la validación real contra el backend.
  String? _routeFor(String id) {
    id = id.trim().toLowerCase();
    if (id == alumnoSimulado.numeroControl || id == alumnoSimulado.correo) {
      return '/alumno';
    }
    if (id == 'instructor2@utng.edu.mx') return '/instructor';
    if (id == adminSimulado.correo) return '/admin';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final route = _routeFor(_userCtrl.text);
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: Text('Usuario o contraseña incorrectos')),
      );
      return;
    }
    context.go(route);
  }

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
            const Text('Número de control o correo institucional',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _userCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_rounded),
                hintText: '1225100380',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            const Text('Contraseña',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
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
            BotonActiva(
              etiqueta: 'Iniciar sesión',
              alPresionar: _submit,
            ),
            const SizedBox(height: 12),
            BotonActiva(
              etiqueta: 'Explorar sin cuenta',
              variante: VarianteBoton.contorno,
              alPresionar: () => context.go('/alumno'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.mist,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: ColoresApp.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Instructores y coordinación también entran aquí con su correo institucional.',
                      style: TextStyle(fontSize: 12),
                    ),
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