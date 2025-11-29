class AppSettings {
  final double masterVolume;
  final double backgroundVolume;
  final bool soundEffectsEnabled;
  final bool vibrationEnabled;

  const AppSettings({
    required this.masterVolume,
    required this.backgroundVolume,
    required this.soundEffectsEnabled,
    required this.vibrationEnabled,
  });

  factory AppSettings.initial() {
    return const AppSettings(
      masterVolume: 0.8,
      backgroundVolume: 0.6,
      soundEffectsEnabled: true,
      vibrationEnabled: true,
    );
  }

  AppSettings copyWith({
    double? masterVolume,
    double? backgroundVolume,
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      backgroundVolume: backgroundVolume ?? this.backgroundVolume,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

AppSettings appSettings = AppSettings.initial();
