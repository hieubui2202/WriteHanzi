import 'package:just_audio/just_audio.dart';

/// Thin wrapper around [AudioPlayer] that exposes a simple play/stop API
/// and keeps a single player instance for the practice flow lifecycle.
class AudioService {
  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  bool get isPlaying => _player.playing;

  Future<void> playUrl(String url) async {
    if (url.isEmpty) {
      return;
    }
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      // Silently ignore playback issues in practice mode. In production
      // this could be piped to a logger service.
    }
  }

  Future<void> stop() async {
    if (_player.playing) {
      await _player.stop();
    }
  }

  Future<void> dispose() => _player.dispose();
}
