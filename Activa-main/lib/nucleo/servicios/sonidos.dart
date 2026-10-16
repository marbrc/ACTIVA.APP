// ===================================================================
// Sonidos de la app: toques, navegación, éxito, error y avisos.
// Los archivos están en assets/sounds/ y se reproducen con audioplayers.
// ===================================================================

import 'package:audioplayers/audioplayers.dart';

// Los sonidos disponibles (el nombre coincide con el archivo .wav)
enum Sonido { toque, navegar, exito, error, aviso }

class Sonidos {
  // Interruptor general (se puede apagar desde Configuración)
  static bool activados = true;

  // Un reproductor por sonido para que no se corten entre sí
  static final Map<Sonido, AudioPlayer> _reproductores = {};

  static Future<void> reproducir(Sonido sonido) async {
    if (!activados) return;
    try {
      final p = _reproductores.putIfAbsent(sonido, () {
        final nuevo = AudioPlayer();
        nuevo.setReleaseMode(ReleaseMode.stop);
        return nuevo;
      });
      await p.stop();
      await p.play(AssetSource('sounds/${sonido.name}.wav'), volume: 0.6);
    } catch (_) {
      // Si el sonido falla (por ejemplo en pruebas), la app sigue normal
    }
  }
}
