import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          print(' Speech status: $status');
        },
        onError: (error) {
          print(' Speech error: ${error.errorMsg}');
        },
        debugLogging: true,
      );

      return _isInitialized;
    } catch (e) {
      print(' Speech initialization error: $e');

      _isInitialized = false;

      return false;
    }
  }

  Future<bool> startListening({
    required String language,
    required void Function(
        String text,
        bool isFinal,
        ) onResult,
  }) async {
    final available = await initialize();

    if (!available) {
      return false;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    String localeId = 'en-US';

    final normalized =
    language.toLowerCase().trim();

    if (normalized == 'en' ||
        normalized == 'english') {
      localeId = 'en-US';
    }

    try {
      await _speech.listen(
        localeId: localeId,
        listenFor: const Duration(
          seconds: 30,
        ),
        pauseFor: const Duration(
          seconds: 5,
        ),
        partialResults: true,
        cancelOnError: true,
        onResult: (result) {
          onResult(
            result.recognizedWords.trim(),
            result.finalResult,
          );
        },
      );

      return true;
    } catch (e) {
      print(' Failed to start speech: $e');

      return false;
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
}

final speechService = SpeechService();