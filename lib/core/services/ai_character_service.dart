import '../models/ai_character_model.dart';
import '../models/ai_conversation_context.dart';

// AI CHARACTER SERVICE
class AICharacterService {

  // CREATE CHARACTER

  AICharacterModel createCharacter({
    required String language,
    required String characterId,
  }) {
    return AICharacterModel.defaultCharacter(
      language: language,
      characterId: characterId,
    );
  }

  // GET GREETING


  String getGreeting(
      String language,
      ) {
    switch (language.toLowerCase().trim()) {
      case 'si':
      case 'sinhala':
        return 'ආයුබෝවන්! 😊 මම SensiBuddy. අද ඔයාට කොහොමද දැනෙන්නේ?';

      case 'ta':
      case 'tamil':
        return 'வணக்கம்! 😊 நான் SensiBuddy. இன்று நீங்கள் எப்படி உணர்கிறீர்கள்?';

      case 'en':
      case 'english':
      default:
        return 'Hello! 😊 I am SensiBuddy. How are you feeling today?';
    }
  }


  // BASIC FALLBACK RESPONSE

  String getBasicResponse({
    required String message,
    required String language,
  }) {
    final text = message.toLowerCase().trim();

    // SINHALA

    if (language == 'si' || language == 'sinhala') {
      if (text.contains('දුක')) {
        return 'මම ඔයා එක්ක ඉන්නවා. 💜';
      }

      if (text.contains('කේන්ති')) {
        return 'අපි හෙමින් හුස්ම ගනිමුද? 🌿';
      }

      if (text.contains('බය')) {
        return 'බය වෙන්න එපා, මම ඔයා එක්ක ඉන්නවා. 🤗';
      }

      if (text.contains('සතුට')) {
        return 'වාව්! ඔයා සතුටින් ඉන්නවාට මටත් සතුටුයි! 🎉';
      }

      return 'හරි 😊 මම ඔයා කියන දේ අහගෙන ඉන්නවා.';
    }


    // TAMIL

    if (language == 'ta' || language == 'tamil') {
      if (text.contains('சோக')) {
        return 'நான் உங்களுடன் இருக்கிறேன். 💜';
      }

      if (text.contains('கோப')) {
        return 'நாம் மெதுவாக மூச்சு விடலாமா? 🌿';
      }

      if (text.contains('பய')) {
        return 'பயப்பட வேண்டாம், நான் உங்களுடன் இருக்கிறேன். 🤗';
      }

      if (text.contains('மகிழ')) {
        return 'வாவ்! நீங்கள் மகிழ்ச்சியாக இருப்பது மகிழ்ச்சி! 🎉';
      }

      return 'சரி 😊 நான் உங்களை கவனமாக கேட்கிறேன்.';
    }


    // ENGLISH

    if (text.contains('sad')) {
      return 'I am here with you. 💜';
    }

    if (text.contains('angry') || text.contains('mad')) {
      return 'Let us take a slow breath together. 🌿';
    }

    if (text.contains('scared') || text.contains('afraid')) {
      return 'You are not alone, I am here with you. 🤗';
    }

    if (text.contains('happy')) {
      return 'That makes me happy too! 🎉';
    }

    return 'I am listening to you. 😊';
  }


  // TEMPORARY TEXT-BASED EMOTION DETECTION

  String detectEmotion({
    required String message,
    required String language,
  }) {
    final text = message.toLowerCase().trim();

    // SINHALA

    if (language == 'si' || language == 'sinhala') {
      if (text.contains('දුක')) return 'sad';

      if (text.contains('කේන්ති')) return 'angry';

      if (text.contains('බය')) return 'fear';

      if (text.contains('සතුට')) return 'happy';

      if (text.contains('පුදුම')) return 'surprise';
    }

    // TAMIL

    if (language == 'ta' || language == 'tamil') {
      if (text.contains('சோக')) return 'sad';

      if (text.contains('கோப')) return 'angry';

      if (text.contains('பய')) return 'fear';

      if (text.contains('மகிழ')) return 'happy';

      if (text.contains('ஆச்சரிய')) return 'surprise';
    }

    // ENGLISH

    if (text.contains('sad') || text.contains('unhappy')) {
      return 'sad';
    }

    if (text.contains('angry') || text.contains('mad')) {
      return 'angry';
    }

    if (text.contains('scared') ||
        text.contains('afraid') ||
        text.contains('fear')) {
      return 'fear';
    }

    if (text.contains('happy') ||
        text.contains('excited') ||
        text.contains('great')) {
      return 'happy';
    }

    if (text.contains('surprised') || text.contains('wow')) {
      return 'surprise';
    }

    return 'neutral';
  }

  // BUILD AI SYSTEM PROMPT

  String buildSystemPrompt(
      AIConversationContext context,
      ) {
    final buffer = StringBuffer();

    final child = context.child;
    final guardian = context.guardian;
    final assessment = context.assessment;
    final character = context.character;

    // COMMON RULES

    buffer.writeln(
      'You are ${character.name}, an AI companion in the SensiBuddy app.',
    );

    buffer.writeln(
      'Character type: ${character.characterId}.',
    );

    buffer.writeln(
      'Your personality is: ${character.personality}.',
    );


    buffer.writeln(
      "The child's currently detected emotion is: ${context.emotion}.",
    );

    buffer.writeln(
      'Your character should respond appropriately and supportively '
          'to this detected emotion.',
    );


    buffer.writeln(
      'Your current character expression is: ${character.emotion}.',
    );

    buffer.writeln(
      '''
LANGUAGE BEHAVIOR:

Respond naturally in the language that best matches the user's message.

If the user writes in Sinhala, you may reply in Sinhala.

If the user writes in English, reply in English.

If the user writes in Tamil, reply in Tamil.

If the user mixes languages, respond naturally using the most appropriate language.

Do not force the reply into the child's preferred language.

A Sinhala-speaking child may use English to learn and practice English.

Keep the language simple, natural and easy to understand.
''',
    );

    buffer.writeln(
      '''
RESPONSE STYLE:

Reply briefly and naturally.

Prefer one or two short sentences.

Keep responses concise whenever possible.

Do not give unnecessarily long explanations.

Ask only one question at a time.

Do not repeat names unless necessary.
''',
    );

    if (context.isChildMode) {
      buffer.writeln(
        '''
CURRENT USER:

You are talking with a child.

Child name: ${child.name}.
Child age range: ${child.ageRange}.
Child preferred language: ${child.language}.
''',
      );

      if (assessment != null) {
        buffer.writeln(
          'Assessment support level: ${assessment.supportLevel}.',
        );
      }

      buffer.writeln(
        '''
CHILD BEHAVIOR:

Use simple and child-friendly language.

Be warm, playful, gentle and encouraging.

Encourage communication and emotional expression.

If the child seems sad, scared or upset, respond calmly and supportively.

Do not diagnose medical or psychological conditions.

Do not claim to be a doctor, psychologist or therapist.

Do not mention assessment information unless it is directly relevant.
''',
      );

      return buffer.toString();
    }

    buffer.writeln(
      '''
CURRENT USER:

You are talking with a guardian.
''',
    );

    if (guardian != null) {
      buffer.writeln(
        'Guardian name: ${guardian.name}.',
      );

      buffer.writeln(
        'Relationship to child: ${guardian.relationship}.',
      );
    }

    buffer.writeln(
      'Child name: ${child.name}.',
    );

    buffer.writeln(
      'Child age range: ${child.ageRange}.',
    );

    if (assessment != null) {
      buffer.writeln(
        'Assessment support level: ${assessment.supportLevel}.',
      );

      buffer.writeln(
        'Assessment summary: ${assessment.summary}.',
      );
    }

    buffer.writeln(
      '''
GUARDIAN BEHAVIOR:

Speak clearly, naturally and supportively.

Give practical suggestions when appropriate.

Help with communication, social interaction and daily support.

Do not present assessment results as a medical diagnosis.

Do not claim to replace a doctor, psychologist or therapist.

Do not make unsupported conclusions.

Explain assessment information carefully and simply when relevant.
''',
    );

    return buffer.toString();
  }
}