import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/cupertino.dart';

import '../models/ai_chat_message.dart';
import '../models/ai_conversation_context.dart';
import '../services/ai_character_service.dart';

// AI MODEL SERVICE
class AIModelService {
  // AI CHARACTER SERVICE

  final AICharacterService _characterService =
  AICharacterService();

  // GEMINI MODEL
  late final GenerativeModel _model;

  // CONSTRUCTOR
  AIModelService() {
    _model =
        FirebaseAI.googleAI().generativeModel(
          //gemini-3.5-flash
          //gemini-3.1-flash-lite
          model: 'gemini-3.5-flash-lite',
        );
  }

  // GENERATE AI RESPONSE
  Future<String> generateResponse({
    required AIConversationContext context,
    required List<AIChatMessage> memory,
    required String userMessage,
  }) async {
    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        ' AI MODEL REQUEST STARTED',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        ' USER MESSAGE: $userMessage',
      );

      // BUILD SYSTEM PROMPT
      final systemPrompt =
      _characterService.buildSystemPrompt(
        context,
      );

      // BUILD FULL PROMPT
      final prompt = StringBuffer();

      prompt.writeln(
        systemPrompt,
      );

      // CONVERSATION HISTORY
      prompt.writeln(
        '\n--- CONVERSATION HISTORY ---',
      );

      // Limit memory so prompt does not become unnecessarily large.
      final recentMemory =
      memory.length > 20
          ? memory.sublist(
        memory.length - 20,
      )
          : memory;

      for (final message in recentMemory) {
        final role =
        message.role == 'user'
            ? 'USER'
            : 'AI';

        prompt.writeln(
          '$role: ${message.content}',
        );
      }

      // CURRENT USER MESSAGE
      prompt.writeln(
        '\n--- CURRENT MESSAGE ---',
      );

      prompt.writeln(
        'USER: $userMessage',
      );

      prompt.writeln(
        '\nAI:',
      );

      debugPrint(
        ' SENDING REQUEST TO GEMINI...',
      );

      // GENERATE RESPONSE
      final response =
      await _model.generateContent(
        [
          Content.text(
            prompt.toString(),
          ),
        ],
      );

      debugPrint(
        ' GEMINI RESPONSE RECEIVED',
      );

      // GET TEXT
      final text =
      response.text?.trim();

      // VALIDATE RESPONSE
      if (text == null ||
          text.isEmpty) {
        debugPrint(
          ' GEMINI RETURNED EMPTY RESPONSE',
        );

        throw Exception(
          'AI returned an empty response',
        );
      }

      debugPrint(
        ' AI RESPONSE: $text',
      );

      debugPrint(
        '========================================',
      );

      return text;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint(
        '========================================',
      );

      debugPrint(
        ' AI MODEL ERROR',
      );

      debugPrint(
        'ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      debugPrint(
        '========================================',
      );

      rethrow;
    }
  }
}