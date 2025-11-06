import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AdhanAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  AdhanAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();

    // إعداد مصدر الصوت
    _player.setAudioSource(
      AudioSource.asset(
        'assets/audio/adhan/Nasser_al_Qatami_Adhan.mp3',
        tag: const MediaItem(
          id: '1',
          title: 'أذان الصلاة',
          artist: 'مؤذن المسجد',
        ),
      ),
    );
  }

  // ... داخل الكلاس AdhanAudioHandler

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playerStateStream.map(_transformEvent).listen((event) {
      playbackState.add(event);
    });

    // تأكد من أن الـ MediaItem يتم نشره حتى يظهر الإشعار
    mediaItem.add(_player.audioSource?.sequence.first.tag as MediaItem);
  }

  // دالة تحويل حالة just_audio إلى حالة audio_service
  PlaybackState _transformEvent(PlayerState playerState) {
    final playing = playerState.playing;
    final processingState =
        _transformProcessingState(playerState.processingState);

    return playbackState.value.copyWith(
      controls: [
        MediaControl.stop,
      ],
      systemActions: const {}, // لا توجد إجراءات إضافية
      androidCompactActionIndices: const [0],
      processingState: processingState,
      playing: playing,
    );
  }

  // تحويل حالة المعالجة
  AudioProcessingState _transformProcessingState(
      ProcessingState processingState) {
    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async => _player.play();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.dispose();
  }
}
