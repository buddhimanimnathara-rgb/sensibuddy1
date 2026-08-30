import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class SpeechApiService {
  // Android Emulator
  static const String _baseUrl =
      'http://10.0.2.2:8000';

  Future<String?> transcribeAudio({
    required String audioPath,
    required String language,
  }) async {
    try {
      final audioFile = File(audioPath);

      if (!await audioFile.exists()) {
        print(
          ' Audio file does not exist: $audioPath',
        );

        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$_baseUrl/transcribe',
        ),
      );

      request.fields['language'] = language;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioPath,
        ),
      );

      print(' Sending audio to SensiBuddy API...');
      print(' Language: $language');

      final streamedResponse =
      await request.send();

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      print(
        '📡 API Status: ${response.statusCode}',
      );

      print(
        '📡 API Response: ${response.body}',
      );

      if (response.statusCode != 200) {
        print(' Speech API failed');

        return null;
      }

      final data =
      jsonDecode(response.body);

      if (data['success'] != true) {
        print(
          ' API transcription failed: ${data['error']}',
        );

        return null;
      }

      final text =
      data['text'];

      return text?.toString().trim();
    } catch (e) {
      print(' Speech API error: $e');

      return null;
    }
  }
}

final speechApiService =
SpeechApiService();