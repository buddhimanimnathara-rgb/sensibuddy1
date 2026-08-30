// AI CHAT MESSAGE MODEL

class AIChatMessage {

  final String role;


  // MESSAGE CONTENT
  final String content;

  // CREATED TIME
  final DateTime createdAt;


  // CONSTRUCTOR
  AIChatMessage({
    required this.role,
    required this.content,
    DateTime? createdAt,
  }) : createdAt =
      createdAt ?? DateTime.now();


  // HELPERS
  bool get isUser =>
      role == 'user';

  bool get isAssistant =>
      role == 'assistant';
}