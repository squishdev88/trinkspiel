import 'package:audioplayers/audioplayers.dart';
import 'app_settings.dart';

class AudioManager {
  AudioManager._internal();

  static final AudioManager instance = AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _initialized = true;
  }

  Future<void> playBackground() async {
    await _ensureInitialized();

    final double volume = (appSettings.masterVolume * appSettings.backgroundVolume)
        .clamp(0.0, 1.0);

    // ❗ WICHTIG: KEIN const HIER!
    await _bgmPlayer.play(
      AssetSource('sounds/start.mp3'),
      volume: volume,
    );
  }

  Future<void> stopBackground() async {
    if (!_initialized) return;
    await _bgmPlayer.stop();
  }

  Future<void> applySettings(AppSettings settings) async {
    await _ensureInitialized();
    final double volume =
        (settings.masterVolume * settings.backgroundVolume).clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
  }
}
