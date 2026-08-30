import 'dart:math';

class FaceCompareService {

  double cosineSimilarity(
      List<double> a,
      List<double> b,
      ) {
    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dot /
        (sqrt(normA) * sqrt(normB));
  }

  bool isMatch(
      List<double> saved,
      List<double> current,
      ) {
    final similarity =
    cosineSimilarity(
      saved,
      current,
    );

    print(
      "Similarity: $similarity",
    );

    return similarity > 0.75;
  }
}

final faceCompareService =
FaceCompareService();