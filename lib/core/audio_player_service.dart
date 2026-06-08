import 'package:audioplayers/audioplayers.dart';

/// Service de lecture audio simple, partagé dans toute l'app.
///
/// Les chemins fournis par le contenu sont du type `audio/letters/ba.mp3`
/// (relatifs au dossier `assets/`). Tant que les fichiers ne sont pas
/// générés (voir `tools/generate_audio.py`), la lecture échoue silencieusement
/// et `play` renvoie `false`, ce qui permet à l'UI d'afficher un repli.
class AudioPlayerService {
  AudioPlayerService();

  final AudioPlayer _player = AudioPlayer();

  /// Joue un asset audio. Renvoie `true` si la lecture a démarré.
  Future<bool> play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
      return true;
    } catch (_) {
      // Fichier manquant ou non encore généré : pas d'erreur bloquante.
      return false;
    }
  }

  void dispose() => _player.dispose();
}
