import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitySessionModel {
  final String childId;

  final String activityName;
  final String activityType;

  final String emotion;

  // Game performance
  final int score;
  final int totalRounds;

  final int correctAnswers;
  final int wrongAnswers;
  final int attempts;

  // Calculated performance
  final double accuracy;

  // Time spent
  final int durationSeconds;

  // Completion status
  final bool completed;

  final DateTime completedAt;

  ActivitySessionModel({
    required this.childId,
    required this.activityName,
    required this.activityType,
    required this.emotion,
    required this.score,
    required this.totalRounds,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.attempts,
    required this.accuracy,
    required this.durationSeconds,
    required this.completed,
    required this.completedAt,
  });

  // TO FIRESTORE

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,

      'activityName': activityName,
      'activityType': activityType,

      'emotion': emotion,

      'score': score,
      'totalRounds': totalRounds,

      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'attempts': attempts,

      'accuracy': accuracy,

      'durationSeconds': durationSeconds,

      'completed': completed,

      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  // FROM FIRESTORE

  factory ActivitySessionModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ActivitySessionModel(
      childId: map['childId'] ?? '',

      activityName: map['activityName'] ?? '',
      activityType: map['activityType'] ?? '',

      emotion: map['emotion'] ?? '',

      score: map['score'] ?? 0,
      totalRounds: map['totalRounds'] ?? 0,

      correctAnswers: map['correctAnswers'] ?? 0,
      wrongAnswers: map['wrongAnswers'] ?? 0,
      attempts: map['attempts'] ?? 0,

      accuracy: (map['accuracy'] ?? 0).toDouble(),

      durationSeconds: map['durationSeconds'] ?? 0,

      completed: map['completed'] ?? false,

      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }


  // COPY WITH

  ActivitySessionModel copyWith({
    String? childId,
    String? activityName,
    String? activityType,
    String? emotion,
    int? score,
    int? totalRounds,
    int? correctAnswers,
    int? wrongAnswers,
    int? attempts,
    double? accuracy,
    int? durationSeconds,
    bool? completed,
    DateTime? completedAt,
  }) {
    return ActivitySessionModel(
      childId: childId ?? this.childId,
      activityName: activityName ?? this.activityName,
      activityType: activityType ?? this.activityType,
      emotion: emotion ?? this.emotion,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      attempts: attempts ?? this.attempts,
      accuracy: accuracy ?? this.accuracy,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}