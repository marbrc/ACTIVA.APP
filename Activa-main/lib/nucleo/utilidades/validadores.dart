import 'package:flutter/services.dart';

final _letras = RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?:[ '\-][A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$");

/// Solo deja escribir letras, espacios, ' y -
List<TextInputFormatter> formatoNombre({int max = 40}) => [
  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ '\-]")),
  LengthLimitingTextInputFormatter(max),
];

String? validarNombre(
  String? v, {
  String campo = 'El nombre',
  bool obligatorio = true,
  int min = 2,
  int max = 40,
}) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return obligatorio ? 'Campo requerido' : null;
  if (t.length < min) return '$campo es muy corto';
  if (t.length > max) return '$campo es muy largo (máx. $max)';
  if (RegExp(r'\d').hasMatch(t)) return '$campo no puede llevar números';
  if (!_letras.hasMatch(t)) {
    return 'Usa solo letras (sin símbolos ni espacios dobles)';
  }
  if (RegExp(r'(.)\1{2,}', caseSensitive: false).hasMatch(t)) {
    return 'Revisa cómo escribiste $campo';
  }
  return null;
}

String? validarNombreCompleto(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Campo requerido';
  if (t.split(RegExp(r'\s+')).length < 2) return 'Escribe nombre y apellido';
  return validarNombre(t, campo: 'El nombre', max: 60);
}

String? validarCorreoInstitucional(String? v) {
  final t = (v ?? '').trim().toLowerCase();
  if (t.isEmpty) return 'Campo requerido';
  if (!RegExp(r'^[a-z0-9._]{3,}@utng\.edu\.mx$').hasMatch(t)) {
    return 'Usa un correo @utng.edu.mx válido';
  }
  return null;
}

String? validarUsuario(String? v) {
  final t = (v ?? '').trim().toLowerCase();
  if (t.isEmpty) return 'Campo requerido';
  if (t.length < 4 || t.length > 20) return 'Entre 4 y 20 caracteres';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(t)) {
    return 'Empieza con letra; solo minúsculas, números y _';
  }
  return null;
}

String capitalizar(String s) => s
    .trim()
    .split(RegExp(r'\s+'))
    .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1).toLowerCase())
    .join(' ');