// ===================================================================
// pantalla_cambiar_contrasena.dart
// Primer inicio de sesión de un instructor (o cuando el admin le
// restablece la contraseña): tiene que cambiar la contraseña temporal
// por una personal antes de entrar a su panel.
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/sesion.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/componentes/estructura_autenticacion.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/reglas_contrasena.dart';

class PantallaCambiarContrasena extends StatefulWidget {
  const PantallaCambiarContrasena({super.key});

  @override
  State<PantallaCambiarContrasena> createState() =>
      _EstadoPantallaCambiarContrasena();
}

class _EstadoPantallaCambiarContrasena extends State<PantallaCambiarContrasena> {
  final _form = GlobalKey<FormState>();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _obscure = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<EstadoSesion>().cuentaPendiente == null) {
        context.go('/inicio-sesion');
      }
    });
  }

  @override
  void dispose() {
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _cancelar() {
    context.read<EstadoSesion>().cancelarCambioPendiente();
    context.go('/inicio-sesion');
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final sesion = context.read<EstadoSesion>();
    final mensajes = ScaffoldMessenger.of(context);

    setState(() => _guardando = true);
    final cuenta = await sesion.cambiarContrasenaPendiente(_pass.text);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (cuenta == null) {
      mensajes.showSnackBar(
        avisoSnack(content: const Text('Error: no se pudo guardar la contraseña')),
      );
      return;
    }

    mensajes.showSnackBar(
      avisoSnack(content: const Text('Contraseña actualizada. ¡Bienvenido a ACTIVA!')),
    );
    context.go(EstadoSesion.rutaDe(cuenta.rol));
  }

  @override
  Widget build(BuildContext context) {
    final reglas = ReglasContrasena(_pass.text);
    return EstructuraAutenticacion(
      title: 'Crea tu contraseña',
      subtitle: 'Es tu primer acceso: cambia la contraseña temporal',
      onBack: _cancelar,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva contraseña',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pass,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if (!ReglasContrasena(v ?? '').valid) {
                  return 'No cumple los requisitos';
                }
                if (context.read<EstadoSesion>().esContrasenaActual(v!)) {
                  return 'Debe ser distinta a la temporal';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i < reglas.score
                            ? ColoresApp.primary
                            : ColoresApp.mist,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
            if (_pass.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  reglas.label,
                  style: const TextStyle(color: ColoresApp.primary, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Confirmar contraseña',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pass2,
              obscureText: _obscure,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) =>
                  v == _pass.text ? null : 'Las contraseñas no coinciden',
            ),
            const SizedBox(height: 16),
            _Requisito('Mínimo 8 caracteres', reglas.minLength),
            _Requisito('Una letra mayúscula y un número', reglas.upperAndDigit),
            _Requisito('Un carácter especial (@, #, \$, !)', reglas.special),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(_guardando ? 'Guardando...' : 'Guardar y entrar'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _cancelar,
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Requisito extends StatelessWidget {
  const _Requisito(this.text, this.ok);
  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 18,
          color: ok ? ColoresApp.primary : Colors.black26,
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}