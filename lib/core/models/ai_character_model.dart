class AICharacterModel {


  final String characterId;

  // Character display name
  final String name;

  // si / ta / en
  final String language;

  // happy / sad / angry / fear / neutral / surprise
  final String emotion;

  // Character personality
  final String personality;

  // Is character currently speaking?
  final bool isSpeaking;

  const AICharacterModel({
    required this.characterId,
    required this.name,
    required this.language,
    required this.emotion,
    required this.personality,
    required this.isSpeaking,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  AICharacterModel copyWith({
    String? characterId,
    String? name,
    String? language,
    String? emotion,
    String? personality,
    bool? isSpeaking,
  }) {
    return AICharacterModel(
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      language: language ?? this.language,
      emotion: emotion ?? this.emotion,
      personality: personality ?? this.personality,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }


  factory AICharacterModel.defaultCharacter({
    required String language,
    String characterId = 'bunny',
  }) {
    return AICharacterModel(
      characterId: characterId,
      name: _getCharacterName(characterId),
      language: language,
      emotion: 'happy',
      personality: _getCharacterPersonality(characterId),
      isSpeaking: false,
    );
  }


  static String _getCharacterName(String characterId) {
    switch (characterId.toLowerCase()) {
      case 'bunny':
        return 'BunnyBuddy';

      case 'girl':
        return 'Sensi';

      case 'robot':
        return 'RoboBuddy';

      case 'teddy':
        return 'TeddyBuddy';

      default:
        return 'SensiBuddy';
    }
  }

  // CHARACTER PERSONALITY

  static String _getCharacterPersonality(String characterId) {
    switch (characterId.toLowerCase()) {
      case 'bunny':
        return '''
friendly, cute, playful, gentle, caring,
child-friendly, cheerful and encouraging
''';

      case 'girl':
        return '''
friendly, warm, playful, patient,
encouraging, caring and child-friendly
''';

      case 'robot':
        return '''
friendly, smart, helpful, playful,
calm, patient and child-friendly
''';

      case 'teddy':
        return '''
gentle, caring, comforting, patient,
friendly, warm and child-friendly
''';

      default:
        return '''
friendly, gentle, patient, playful,
caring and child-friendly
''';
    }
  }


  // AVAILABLE CHARACTERS

  static const List<String> availableCharacters = [
    'bunny',
    'girl',
    'robot',
    'teddy',
  ];
}