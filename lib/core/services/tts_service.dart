import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();


  // START HANDLER

  void setStartHandler(VoidCallback? handler) {
    _flutterTts.setStartHandler(
      handler ?? () {},
    );
  }


  // COMPLETION HANDLER

  void setCompletionHandler(VoidCallback? handler) {
    _flutterTts.setCompletionHandler(
      handler ?? () {},
    );
  }


  // CANCEL HANDLER


  void setCancelHandler(VoidCallback? handler) {
    _flutterTts.setCancelHandler(
      handler ?? () {},
    );
  }


  // ERROR HANDLER


  void setErrorHandler(
      void Function(dynamic message)? handler,
      ) {
    _flutterTts.setErrorHandler(
      handler ?? (_) {},
    );
  }


  // SPEAK

  Future<void> speak(
      String text, {
        String language = 'en',
      }) async {
    String locale;

    switch (language.toLowerCase().trim()) {
      case 'si':
      case 'sinhala':
        locale = 'si-LK';
        break;

      case 'ta':
      case 'tamil':
        locale = 'ta-IN';
        break;

      default:
        locale = 'en-US';
    }

    await _flutterTts.setLanguage(locale);

    // Child-friendly voice settings
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.05);
    await _flutterTts.setVolume(1.0);

    // Stop previous speech
    await _flutterTts.stop();

    // Start speaking
    await _flutterTts.speak(text);
  }


  // STOP

  Future<void> stop() async {
    await _flutterTts.stop();
  }


  // DISPOSE

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}