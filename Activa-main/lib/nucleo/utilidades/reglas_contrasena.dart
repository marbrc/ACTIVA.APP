class ReglasContrasena {
  ReglasContrasena(this.value);
  final String value;

  bool get minLength => value.length >= 8;
  bool get upperAndDigit =>
      RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'\d').hasMatch(value);
  bool get special => RegExp(r'[@#$!%*?&._-]').hasMatch(value);

  // 0 a 4 barritas
  int get score => [
    minLength,
    upperAndDigit,
    special,
    value.length >= 12,
  ].where((ok) => ok).length;

  String get label => const [
    'Muy débil',
    'Débil',
    'Aceptable',
    'Contraseña segura',
    'Contraseña muy segura',
  ][score];

  // El carácter especial es recomendado, no obligatorio (como en tu mockup)
  bool get valid => minLength && upperAndDigit;
}
