import 'package:audioplayers/audioplayers.dart';

class SoundEffects {
  SoundEffects._(); // nicht als Objekt benutzen

  static final AudioPlayer _clickPlayer = AudioPlayer();

  static Future<void> playClick() async {
    try {
      await _clickPlayer.play(
        AssetSource('sounds/click.mp3'),
        volume: 0.7,
      );
    } catch (_) {
      // wenn die Datei noch nicht da ist, einfach ignorieren
    }
  }
}
