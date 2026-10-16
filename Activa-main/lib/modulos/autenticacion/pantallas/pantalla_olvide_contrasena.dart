import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/reglas_contrasena.dart';
import '../../../nucleo/componentes/estructura_autenticacion.dart';

class PantallaOlvideContrasena extends StatefulWidget {
  const PantallaOlvideContrasena({super.key});
  @override
  State<PantallaOlvideContrasena> createState() => _EstadoPantallaOlvideContrasena();
}

class _EstadoPantallaOlvideContrasena extends State<PantallaOlvideContrasena> {
  final _form0 = GlobalKey<FormState>();
  final _form2 = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _code = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  int _step = 0;
  bool _obscure = true;
  String? _codeError;
  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_user, _code, _pass, _pass2]) {
      c.dispose();
    }
    super.dispose();
  }

  // 1225100380@utng.edu.mx -> 12****80@utng.edu.mx
  String get _maskedEmail {
    final u = _user.text.trim();
    final email = u.contains('@') ? u : '$u@utng.edu.mx';
    final parts = email.split('@');
    final name = parts[0];
    if (name.length <= 4) return email;
    return '${name.substring(0, 2)}****${name.substring(name.length - 2)}@${parts[1]}';
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
      }
      setState(() => _seconds--);
    });
  }

  String get _countdown =>
      '00:${_seconds.toString().padLeft(2, '0')}';

  void _sendCode() {
    if (!_form0.currentState!.validate()) return;
    // TODO: backend busca la cuenta y envía el código al correo
    _code.clear();
    _startTimer();
    setState(() => _step = 1);
  }

  void _verify() {
    if (_code.text.length != 6) {
      setState(() => _codeError = 'Escribe los 6 dígitos');
      return;
    }
    // TODO: backend valida el código (temporal, con expiración)
    setState(() {
      _codeError = null;
      _step = 2;
    });
  }

  void _save() {
    if (!_form2.currentState!.validate()) return;
    // TODO: backend actualiza password y cierra sesiones en otros dispositivos
    context.go('/contrasena-actualizada');
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.canPop() ? context.pop() : context.go('/inicio-sesion');
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['¿Olvidaste tu contraseña?', 'Verifica tu código', 'Nueva contraseña'];
    const subs = ['Paso 1 de 3 · Tu correo', 'Paso 2 de 3', 'Paso 3 de 3'];
    return EstructuraAutenticacion(
      title: titles[_step],
      subtitle: subs[_step],
      onBack: _back,
      child: switch (_step) {
        0 => _stepEmail(),
        1 => _stepCode(),
        _ => _stepPassword(),
      },
    );
  }

  Widget _badge(IconData icon) => Center(
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
              color: ColoresApp.background, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFC7D9FB),
            child: Icon(icon, color: ColoresApp.primary, size: 28),
          ),
        ),
      );

  Widget _stepEmail() => Form(
        key: _form0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badge(Icons.lock),
            const SizedBox(height: 16),
            const Text(
              'Escribe tu número de control o tu correo institucional y te enviaremos un código de verificación de 6 dígitos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text('Número de control o correo institucional',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _user,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.email)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _sendCode, child: const Text('Enviar código')),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/inicio-sesion'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Volver a iniciar sesión'),
              ),
            ),
          ],
        ),
      );

  Widget _stepCode() => Column(
        children: [
          _badge(Icons.email),
          const SizedBox(height: 16),
          Text(
            'Enviamos un código a $_maskedEmail. Escríbelo para continuar.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 14),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              errorText: _codeError,
            ),
            onChanged: (_) => setState(() => _codeError = null),
          ),
          const SizedBox(height: 8),
          _seconds > 0
              ? Text('¿No lo recibiste? Reenviar en $_countdown',
                  style: const TextStyle(color: Colors.black54, fontSize: 12))
              : TextButton(
                  onPressed: _startTimer, // TODO: reenviar código real
                  child: const Text('Reenviar código')),
          const SizedBox(height: 12),
          FilledButton(onPressed: _verify, child: const Text('Verificar código')),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              setState(() => _step = 0);
            },
            child: const Text('Cambiar correo'),
          ),
        ],
      );

  Widget _stepPassword() {
    final rules = ReglasContrasena(_pass.text);
    return Form(
      key: _form2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crea una contraseña nueva que no hayas usado antes.',
              style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 16),
          const Text('Nueva contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
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
            validator: (v) =>
                ReglasContrasena(v ?? '').valid ? null : 'No cumple los requisitos',
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
                      color: i < rules.score ? ColoresApp.teal : ColoresApp.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          if (_pass.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(rules.label,
                  style: const TextStyle(color: ColoresApp.teal, fontSize: 12)),
            ),
          const SizedBox(height: 16),
          const Text('Confirmar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pass2,
            obscureText: _obscure,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline)),
            validator: (v) => v == _pass.text ? null : 'Las contraseñas no coinciden',
          ),
          const SizedBox(height: 16),
          _Requisito('Mínimo 8 caracteres', rules.minLength),
          _Requisito('Una letra mayúscula y un número', rules.upperAndDigit),
          _Requisito('Un carácter especial (@, #, \$, !)', rules.special),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Guardar contraseña')),
        ],
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
            Icon(Icons.check_circle,
                size: 18, color: ok ? ColoresApp.teal : Colors.black26),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
}