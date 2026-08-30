class AIInteractionAnalysisModel {
  final String childId;

  final String emotion;

  final String message;

  final DateTime createdAt;

  AIInteractionAnalysisModel({
    required this.childId,
    required this.emotion,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'emotion': emotion,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AIInteractionAnalysisModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return AIInteractionAnalysisModel(
      childId: data['childId'] ?? '',
      emotion: data['emotion'] ?? 'neutral',
      message: data['message'] ?? '',
      createdAt: DateTime.tryParse(
        data['createdAt'] ?? '',
      ) ??
          DateTime.now(),
    );
  }
}