import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class UnifiedSpeechService {
  UnifiedSpeechService._();

  static final UnifiedSpeechService instance =
  UnifiedSpeechService._();

  final stt.SpeechToText _speech =
  stt.SpeechToText();

  bool _isInitialized = false;

  static const String _baseUrl =
      'http://192.168.8.168:8000';

  bool get isListening =>
      _speech.isListening;

  bool get isAvailable =>
      _isInitialized;

  String normalizeLanguage(
      String language,
      ) {
    final value =
    language.toLowerCase().trim();

    if (value == 'si' ||
        value == 'sinhala' ||
        value == 'සිංහල') {
      return 'si';
    }

    if (value == 'ta' ||
        value == 'tamil' ||
        value == 'தமிழ்') {
      return 'ta';
    }

    if (value == 'en' ||
        value == 'english') {
      return 'en';
    }

    return 'en';
  }

  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      _isInitialized =
      await _speech.initialize(
        onStatus: (status) {
          print(
            '🎤 Speech status: $status',
          );
        },
        onError: (error) {
          print(
            ' Speech error: '
                '${error.errorMsg}',
          );
        },
        debugLogging: true,
      );

      return _isInitialized;
    } catch (e) {
      print(
        ' Speech initialization error: $e',
      );

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
    final normalizedLanguage =
    normalizeLanguage(language);

    if (normalizedLanguage != 'en') {
      print(
        ' Native speech recognition '
            'is only for English.',
      );

      return false;
    }

    final available =
    await initialize();

    if (!available) {
      return false;
    }

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }

      await _speech.listen(
        localeId: 'en-US',
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
      print(
        ' Failed to start speech: $e',
      );

      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      print(
        ' Stop listening error: $e',
      );
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (e) {
      print(
        ' Cancel listening error: $e',
      );
    }
  }

  Future<String> transcribe({
    required String audioPath,
    required String language,
  }) async {
    final normalizedLanguage =
    normalizeLanguage(language);

    if (normalizedLanguage == 'en') {
      throw Exception(
        'English does not use the '
            'FastAPI transcription API.',
      );
    }

    final audioFile =
    File(audioPath);

    if (!await audioFile.exists()) {
      throw Exception(
        'Audio file not found: $audioPath',
      );
    }

    final request =
    http.MultipartRequest(
      'POST',
      Uri.parse(
        '$_baseUrl/transcribe',
      ),
    );

    request.fields['language'] =
        normalizedLanguage;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioPath,
      ),
    );

    try {
      print(
        ' Sending audio to API...',
      );

      final streamedResponse =
      await request.send().timeout(
        const Duration(
          seconds: 180,
        ),
      );

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      print(
        ' API Status: '
            '${response.statusCode}',
      );

      print(
        ' API Response: '
            '${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Speech API error: '
              '${response.statusCode}',
        );
      }

      final data =
      jsonDecode(response.body)
      as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(
          data['error']?.toString() ??
              'Speech transcription failed.',
        );
      }

      return data['text']
          ?.toString()
          .trim() ??
          '';
    } catch (e) {
      print(
        ' Speech API error: $e',
      );

      rethrow;
    }
  }

  Future<bool> isServerAvailable() async {
    try {
      final response =
      await http
          .get(
        Uri.parse(_baseUrl),
      )
          .timeout(
        const Duration(
          seconds: 10,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(
        ' Server unavailable: $e',
      );

      return false;
    }
  }
}

final unifiedSpeechService =
    UnifiedSpeechService.instance;