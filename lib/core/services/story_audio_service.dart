import 'package:just_audio/just_audio.dart';

class StoryAudioService {
  final AudioPlayer _player = AudioPlayer();


  // GET AUDIO ASSET PATH

  String getAudioPath({
    required String emotion,
    required String language,
  }) {
    return 'assets/audio/stories/${emotion}_001_${language}.mp3';
  }


  // PLAY STORY AUDIO

  Future<void> playStory({
    required String emotion,
    required String language,
  }) async {
    final path = getAudioPath(
      emotion: emotion,
      language: language,
    );

    await _player.setAsset(path);
    await _player.play();
  }


  // PAUSE AUDIO


  Future<void> pauseStory() async {
    await _player.pause();
  }


  // RESUME AUDIO

  Future<void> resumeStory() async {
    await _player.play();
  }

  // STOP AUDIO

  Future<void> stopStory() async {
    await _player.stop();
  }


  // CHECK PLAYING

  bool get isPlaying => _player.playing;


  // DISPOSE

  Future<void> dispose() async {
    await _player.dispose();
  }
}