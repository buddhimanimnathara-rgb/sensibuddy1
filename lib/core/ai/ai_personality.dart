class AIPersonality {

  final String childName;
  final String supportLevel;
  final String language;

  AIPersonality({
    required this.childName,
    required this.supportLevel,
    required this.language,
  });

  String generateGreeting() {

    if (language == "si") {
      return "හෙලෝ $childName 👋 මම ඔබගේ මිතුරා 😊";
    }

    if (language == "ta") {
      return "வணக்கம் $childName 👋 நான் உங்கள் நண்பன் 😊";
    }

    return "Hello $childName 👋 I am your friendly AI 😊";
  }

  String emotionalTone(String emotion) {

    if (supportLevel == "High Support") {
      return "soft";
    } else if (supportLevel == "Medium Support") {
      return "friendly";
    } else {
      return "advanced";
    }
  }
}