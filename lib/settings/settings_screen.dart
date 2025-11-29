import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_settings.dart';
import 'audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _masterVolume;
  late double _backgroundVolume;
  late bool _soundEffectsEnabled;
  late bool _vibrationEnabled;

  @override
  void initState() {
    super.initState();
    _masterVolume = appSettings.masterVolume;
    _backgroundVolume = appSettings.backgroundVolume;
    _soundEffectsEnabled = appSettings.soundEffectsEnabled;
    _vibrationEnabled = appSettings.vibrationEnabled;
  }

  Future<void> _applyAndClose() async {
    appSettings = AppSettings(
      masterVolume: _masterVolume,
      backgroundVolume: _backgroundVolume,
      soundEffectsEnabled: _soundEffectsEnabled,
      vibrationEnabled: _vibrationEnabled,
    );

    await AudioManager.instance.applySettings(appSettings);

    Navigator.of(context).pop();
  }

  Future<void> _applyVolumeLive() async {
    final tempSettings = AppSettings(
      masterVolume: _masterVolume,
      backgroundVolume: _backgroundVolume,
      soundEffectsEnabled: _soundEffectsEnabled,
      vibrationEnabled: _vibrationEnabled,
    );
    await AudioManager.instance.applySettings(tempSettings);
  }

  void _maybeVibrate() {
    if (_vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _applyAndClose,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Audio', style: textTheme.titleLarge),
          const SizedBox(height: 12),

          Text('Gesamtlautstärke', style: textTheme.titleMedium),
          Row(
            children: [
              const Icon(Icons.volume_mute),
              Expanded(
                child: Slider(
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  value: _masterVolume,
                  label: (_masterVolume * 100).round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _masterVolume = value;
                    });
                  },
                  onChangeEnd: (_) => _applyVolumeLive(),
                ),
              ),
              const Icon(Icons.volume_up),
            ],
          ),

          const SizedBox(height: 16),

          Text('Hintergrundmusik-Lautstärke', style: textTheme.titleMedium),
          Row(
            children: [
              const Icon(Icons.music_note),
              Expanded(
                child: Slider(
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  value: _backgroundVolume,
                  label: (_backgroundVolume * 100).round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _backgroundVolume = value;
                    });
                  },
                  onChangeEnd: (_) => _applyVolumeLive(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text('Feedback', style: textTheme.titleLarge),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Soundeffekte'),
            subtitle: const Text('Kurze Sounds bei Aktionen im Spiel.'),
            value: _soundEffectsEnabled,
            secondary: const Icon(Icons.surround_sound),
            onChanged: (value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Haptisches Feedback bei Ereignissen.'),
            value: _vibrationEnabled,
            secondary: const Icon(Icons.vibration),
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              _maybeVibrate();
            },
          ),
        ],
      ),
    );
  }
}
