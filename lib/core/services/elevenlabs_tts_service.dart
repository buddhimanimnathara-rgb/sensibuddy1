import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ElevenLabsTtsService {
  ElevenLabsTtsService();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ELEVENLABS CONFIG FROM .ENV

  final String _voiceId =
      dotenv.env['ELEVENLABS_VOICE_ID'] ?? '';

  final String apiKey =
      dotenv.env['ELEVENLABS_API_KEY'] ?? '';

  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> speak(
      String text, {
        void Function()? onStart,
        void Function()? onComplete,
        void Function(Object error)? onError,
      }) async {
    if (text.trim().isEmpty) return;

    if (apiKey.isEmpty || _voiceId.isEmpty) {
      onError?.call(
        Exception(
          'ElevenLabs API key or Voice ID is not configured.',
        ),
      );
      return;
    }

    try {
      await stop();

      final url = Uri.parse(
        'https://api.elevenlabs.io/v1/text-to-speech/$_voiceId',
      );

      final response = await http.post(
        url,
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: '''
{
  "text": ${_escapeJson(text)},
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.5,
    "similarity_boost": 0.75,
    "style": 0.3,
    "use_speaker_boost": true
  }
}
''',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'ElevenLabs error '
              '${response.statusCode}: ${response.body}',
        );
      }

      final Uint8List audioBytes = response.bodyBytes;

      _isSpeaking = true;
      onStart?.call();

      await _audioPlayer.play(
        BytesSource(audioBytes),
      );

      _audioPlayer.onPlayerComplete.first.then((_) {
        _isSpeaking = false;
        onComplete?.call();
      });
    } catch (e) {
      _isSpeaking = false;
      onError?.call(e);
    }
  }

  // STOP

  Future<void> stop() async {
    _isSpeaking = false;
    await _audioPlayer.stop();
  }

  // DISPOSE

  Future<void> dispose() async {
    _isSpeaking = false;
    await _audioPlayer.dispose();
  }

  // JSON ESCAPE

  String _escapeJson(String value) {
    return '"${value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')}"';
  }
}