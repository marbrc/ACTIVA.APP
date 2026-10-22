const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String fechaLarga(DateTime d) =>
    '${d.day} de ${_meses[d.month - 1]} de ${d.year}';

String tiempoRelativo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes.clamp(1, 59)} min';
  if (diff.inHours < 24) {
    return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
  }
  if (diff.inDays == 1) return 'Ayer';
  return 'Hace ${diff.inDays} días';
}

bool esNuevo(DateTime d) => DateTime.now().difference(d).inHours < 24;

String inicialesDe(String nombre) {
  final n = nombre.trim();
  return n.substring(0, n.length < 3 ? n.length : 3).toUpperCase();
}

const _dias = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

String diaNombre(DateTime d) => _dias[d.weekday - 1];

String fechaIso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String fechaConDia(DateTime d) {
  final n = diaNombre(d);
  return '${n[0].toUpperCase()}${n.substring(1)} ${d.day} de ${_meses[d.month - 1]}';
}

String iniciales(String nombre, String apellido) {
  final a = nombre.trim().isEmpty ? '' : nombre.trim()[0];
  final b = apellido.trim().isEmpty ? '' : apellido.trim()[0];
  return '$a$b'.toUpperCase();
}
