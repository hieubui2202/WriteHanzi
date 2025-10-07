import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService();

  final _player = AudioPlayer();

  Future<void> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      // ignore audio errors for offline demo
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
