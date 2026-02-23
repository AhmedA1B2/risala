import 'package:just_audio/just_audio.dart';

class ClickSoundService {
  static final ClickSoundService _instance = ClickSoundService._internal();
  factory ClickSoundService() => _instance;

  late final AudioPlayer _player;

  ClickSoundService._internal() {
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    await _player.setAsset('assets/audio/click.mp3');
  }

  Future<void> play() async {
    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
