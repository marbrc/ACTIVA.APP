import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../../datos/sesion.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/reglas_contrasena.dart';
import '../../../nucleo/utilidades/validadores.dart';
import '../../../nucleo/componentes/estructura_autenticacion.dart';
import '../../../nucleo/componentes/avisos.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});
  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _form1 = GlobalKey<FormState>();
  final _form2 = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _paterno = TextEditingController();
  final _materno = TextEditingController();
  final _control = TextEditingController();
  final _grupo = TextEditingController();
  final _correo = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  static const _carreras = [
    'Ingeniería en Desarrollo de Software',
    'TSU en Desarrollo de Software Multiplataforma',
  ];

  int _step = 0;
  String? _carrera;
  bool _obscure = true;
  bool _terms = false;

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _paterno,
      _materno,
      _control,
      _grupo,
      _correo,
      _pass,
      _pass2,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_form1.currentState!.validate()) setState(() => _step = 1);
  }

  Future<void> _create() async {
    
    if (!_form2.currentState!.validate()) return;
    if (!_terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: const Text('Acepta los términos para continuar')),
      );
      return;
    }
    // se leen los datos antes de esperar, por si se cierra la pantalla
    final mensajes = ScaffoldMessenger.of(context);
    final sesion = context.read<EstadoSesion>();

    // se junta nombre + paterno + materno en el formato que ya usa tu registro
    final nombreCompleto = [
      capitalizar(_nombre.text),
      capitalizar(_paterno.text),
      capitalizar(_materno.text),
    ].where((p) => p.isNotEmpty).join(' ');

        final error = await sesion.registrarAlumno(
      nombreCompleto: nombreCompleto,
      soloNombre: capitalizar(_nombre.text),
      apellidoPaterno: capitalizar(_paterno.text),
      apellidoMaterno: capitalizar(_materno.text),
      numeroControl: _control.text,
      grupo: _grupo.text,
      correo: _correo.text,
      carrera: _carrera ?? '',
      contrasena: _pass.text,
    );
    if (!mounted) return;
    if (error != null) {
      mensajes.showSnackBar(avisoSnack(content: Text(error)));
      return;
    }
    mensajes.showSnackBar(
      avisoSnack(content: const Text('Cuenta creada. Ya puedes iniciar sesión')),
    );
    context.go('/inicio-sesion');
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null;

  Widget _etiqueta(String t) =>
      Text(t, style: const TextStyle(fontWeight: FontWeight.bold));

  @override
  Widget build(BuildContext context) {
    return EstructuraAutenticacion(
      title: 'Crea tu cuenta',
      subtitle: _step == 0
          ? 'Paso 1 de 2 · Tus datos'
          : 'Paso 2 de 2 · Tu contraseña',
      onBack: () => _step == 1
          ? setState(() => _step = 0)
          : (context.canPop() ? context.pop() : context.go('/bienvenida')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 2; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? ColoresApp.primary
                          : ColoresApp.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _step == 0 ? _stepOne() : _stepTwo(),
        ],
      ),
    );
  }

  Widget _stepOne() => Form(
    key: _form1,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Nombre(s) ----------
        _etiqueta('Nombre(s)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nombre,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          inputFormatters: formatoNombre(),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
          validator: (v) => validarNombre(v, campo: 'El nombre'),
        ),
        const SizedBox(height: 16),

        // ---------- Apellido paterno y materno ----------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Apellido paterno'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _paterno,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    inputFormatters: formatoNombre(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => validarNombre(v, campo: 'El apellido'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Apellido materno (opcional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _materno,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    inputFormatters: formatoNombre(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => validarNombre(
                      v,
                      campo: 'El apellido',
                      obligatorio: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ---------- Número de control y grupo ----------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Número de control'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _control,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.school),
                      counterText: '',
                    ),
                    validator: (v) => RegExp(r'^\d{10}$').hasMatch(v ?? '')
                        ? null
                        : '10 dígitos',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Grupo'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _grupo,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9\-]'),
                      ),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.groups),
                    ),
                    validator: _required,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ---------- Correo ----------
        _etiqueta('Correo institucional'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _correo,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: 'tucontrol@utng.edu.mx',
          ),
          validator: validarCorreoInstitucional,
        ),
        const SizedBox(height: 16),

        // ---------- Carrera ----------
        _etiqueta('Carrera'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _carrera,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.school_outlined),
          ),
          items: [
            for (final c in _carreras)
              DropdownMenuItem(
                value: c,
                child: Text(c, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() => _carrera = v),
          validator: (v) => v == null ? 'Selecciona tu carrera' : null,
        ),
        const SizedBox(height: 28),
        FilledButton(onPressed: _next, child: const Text('Continuar')),
        Center(
          child: TextButton(
            onPressed: () => context.go('/inicio-sesion'),
            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
          ),
        ),
      ],
    ),
  );

  Widget _stepTwo() {
    final rules = ReglasContrasena(_pass.text);
    return Form(
      key: _form2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _etiqueta('Contraseña'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pass,
            obscureText: _obscure,
            onChanged: (_) => setState(() {}), // refresca la barra y requisitos
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => ReglasContrasena(v ?? '').valid
                ? null
                : 'No cumple los requisitos',
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
                      color: i < rules.score
                          ? ColoresApp.teal
                          : ColoresApp.background,
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
                rules.label,
                style: const TextStyle(color: ColoresApp.teal, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          _etiqueta('Confirmar contraseña'),
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
          _Requisito('Mínimo 8 caracteres', rules.minLength),
          _Requisito('Una letra mayúscula y un número', rules.upperAndDigit),
          _Requisito('Un carácter especial (@, #, \$, !)', rules.special),
               Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _terms,
              onChanged: (v) => setState(() => _terms = v ?? false),
              title: const Text(
                'Acepto los términos de uso y el aviso de privacidad de ACTIVA.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _create, child: const Text('Crear cuenta')),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text('¿Necesitas cambiar algo? Regresar'),
            ),
          ),
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
        Icon(
          Icons.check_circle,
          size: 18,
          color: ok ? ColoresApp.teal : Colors.black26,
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}