import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionHistoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveEmotion({
    required String childId,
    required String emotion,
    required double confidence,
    required String language,
  }) async {
    try {
      await _firestore
          .collection('emotion_history')
          .add({
        'childId': childId,
        'emotion': emotion.toLowerCase().trim(),
        'confidence': confidence,
        'language': language,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print(
        'Emotion saved: '
            '$emotion (${(confidence * 100).toStringAsFixed(1)}%)',
      );
    } catch (e) {
      print(
        'Failed to save emotion: $e',
      );

      rethrow;
    }
  }

  /// Gets the latest emotion records for a child.
  Future<List<Map<String, dynamic>>> getEmotionHistory({
    required String childId,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('emotion_history')
          .where(
        'childId',
        isEqualTo: childId,
      )
          .orderBy(
        'timestamp',
        descending: true,
      )
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print(
        'Failed to get emotion history: $e',
      );

      rethrow;
    }
  }
}