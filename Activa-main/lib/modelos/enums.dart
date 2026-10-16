enum Rol { admin, instructor, alumno }
enum EstadoInscripcion { activa, cancelada, finalizada }
enum TipoAviso { informativo, cambioHorario, cancelacion, recordatorio }
enum Dia { lunes, martes, miercoles, jueves, viernes }

extension DiaX on Dia {
  String get corto => const {
        Dia.lunes: 'Lun',
        Dia.martes: 'Mar',
        Dia.miercoles: 'Mié',
        Dia.jueves: 'Jue',
        Dia.viernes: 'Vie',
      }[this]!;
}
extension DiaW on Dia {
  int get weekday => index + 1; // lunes=1 ... viernes=5 (igual que DateTime)
}

extension TipoAvisoX on TipoAviso {
  String get etiqueta => switch (this) {
        TipoAviso.informativo => 'Informativo',
        TipoAviso.cambioHorario => 'Cambio de horario',
        TipoAviso.cancelacion => 'Cancelación',
        TipoAviso.recordatorio => 'Recordatorio',
      };
}