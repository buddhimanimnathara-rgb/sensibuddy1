import 'dart:math';
import 'firestore_service.dart';

// RECOGNIZED PERSON MODEL

class RecognizedPerson {
  final String id;
  final String type;
  final double similarity;
  final Map<String, dynamic> faceData;

  RecognizedPerson({
    required this.id,
    required this.type,
    required this.similarity,
    required this.faceData,
  });

  bool get isChild => type == 'child';

  bool get isGuardian => type == 'guardian';
}


// PERSON RECOGNITION SERVICE


class PersonRecognitionService {
  PersonRecognitionService._();

  static final PersonRecognitionService instance =
  PersonRecognitionService._();

  final FirestoreService _firestoreService =
  FirestoreService();


  // MATCH THRESHOLD


  static const double matchThreshold = 0.75;


  // COSINE SIMILARITY


  double cosineSimilarity(
      List<double> a,
      List<double> b,
      ) {
    if (a.length != b.length || a.isEmpty) {
      return 0.0;
    }

    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }

    return dot / (sqrt(normA) * sqrt(normB));
  }


  // CONVERT FIRESTORE DATA TO DOUBLE LIST


  List<double> _toDoubleList(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value.map((item) {
      if (item is num) {
        return item.toDouble();
      }

      return double.tryParse(
        item.toString(),
      ) ??
          0.0;
    }).toList();
  }

  // COMPARE ONE FACE WITH 3 SAVED EMBEDDINGS


  double _getHighestSimilarity(
      List<double> currentEmbedding,
      Map<String, dynamic> personFace,
      ) {
    double highestSimilarity = 0.0;

    for (int i = 1; i <= 3; i++) {
      final savedEmbedding =
      _toDoubleList(
        personFace['embedding$i'],
      );

      if (savedEmbedding.isEmpty) {
        continue;
      }

      final similarity = cosineSimilarity(
        currentEmbedding,
        savedEmbedding,
      );

      print(
        'Embedding $i similarity: $similarity',
      );

      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
      }
    }

    return highestSimilarity;
  }


  // IDENTIFY PERSON


  Future<RecognizedPerson?> identifyPerson(
      List<double> currentEmbedding,
      ) async {
    RecognizedPerson? bestMatch;

    double highestSimilarity = 0.0;

    try {

      // GET ALL CHILD FACES


      final childFaces =
      await _firestoreService.getAllChildFaces();

      for (final childFace in childFaces) {
        final similarity = _getHighestSimilarity(
          currentEmbedding,
          childFace,
        );

        print(
          ' Child '
              '${childFace['childId']}: '
              '$similarity',
        );

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;

          bestMatch = RecognizedPerson(
            id: childFace['childId']?.toString() ??
                childFace['id'].toString(),
            type: 'child',
            similarity: similarity,
            faceData: childFace,
          );
        }
      }


      // GET ALL GUARDIAN FACES


      final guardianFaces =
      await _firestoreService.getAllGuardianFaces();

      for (final guardianFace in guardianFaces) {
        final similarity = _getHighestSimilarity(
          currentEmbedding,
          guardianFace,
        );

        print(
          ' Guardian '
              '${guardianFace['guardianId']}: '
              '$similarity',
        );

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;

          bestMatch = RecognizedPerson(
            id:
            guardianFace['guardianId']
                ?.toString() ??
                guardianFace['id'].toString(),
            type: 'guardian',
            similarity: similarity,
            faceData: guardianFace,
          );
        }
      }


      // FINAL RESULT


      print(
        ' Highest similarity: '
            '$highestSimilarity',
      );

      if (bestMatch == null ||
          highestSimilarity < matchThreshold) {
        print(' No person recognized');

        return null;
      }

      print(
        ' Person recognized: '
            '${bestMatch.type}',
      );

      return bestMatch;
    } catch (e) {
      print(
        ' Person recognition error: $e',
      );

      return null;
    }
  }
}


// GLOBAL INSTANCE

final personRecognitionService =
    PersonRecognitionService.instance;