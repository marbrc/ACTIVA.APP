import 'package:audioplayers/audioplayers.dart';

// Solo suenan 2 cosas: éxito (acción completada) y error
enum Sonido { exito, error }

class Sonidos {
  static bool activados = true;

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
    } catch (_) {}
  }
}