class AssessmentModel {
  final String childId;

  final List<bool> answers;

  final int socialScore;
  final int communicationScore;
  final int restrictedRoutineScore;
  final int repetitiveScore;
  final int sensoryScore;

  final int score;
  final String supportLevel;
  final String summary;



  AssessmentModel({
    required this.childId,
    required this.answers,
    required this.socialScore,
    required this.communicationScore,
    required this.restrictedRoutineScore,
    required this.repetitiveScore,
    required this.sensoryScore,
    required this.score,
    required this.supportLevel,
    required this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      "childId": childId,
      "answers": answers,

      "socialScore": socialScore,
      "communicationScore": communicationScore,
      "restrictedRoutineScore": restrictedRoutineScore,
      "repetitiveScore": repetitiveScore,
      "sensoryScore": sensoryScore,


      "score": score,
      "supportLevel": supportLevel,
      "summary": summary,

      "createdAt": DateTime.now().toIso8601String(),
    };
  }

  factory AssessmentModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return AssessmentModel(
      childId: data["childId"] ?? "",

      answers: List<bool>.from(
        data["answers"] ?? [],
      ),

      socialScore: data["socialScore"] ?? 0,
      communicationScore:
      data["communicationScore"] ?? 0,
      restrictedRoutineScore: data["restrictedRoutineScore"] ?? 0,
      repetitiveScore:
      data["repetitiveScore"] ?? 0,
      sensoryScore: data["sensoryScore"] ?? 0,
      score: data["score"] ?? 0,
      supportLevel:
      data["supportLevel"] ?? "Unknown",
      summary: data["summary"] ?? "",
    );
  }
}