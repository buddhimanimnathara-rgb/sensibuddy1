import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {

  final FaceDetector detector =
  FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
      performanceMode:
      FaceDetectorMode.accurate,
    ),
  );

  Future<bool> detectFace(
      String imagePath,
      ) async {

    final image =
    InputImage.fromFilePath(
      imagePath,
    );

    final faces =
    await detector.processImage(
      image,
    );

    return faces.isNotEmpty;
  }

  Future<Face?> getFace(
      String imagePath,
      ) async {

    final image =
    InputImage.fromFilePath(
      imagePath,
    );

    final faces =
    await detector.processImage(
      image,
    );

    if (faces.isEmpty) {
      return null;
    }

    return faces.first;
  }

  void dispose() {
    detector.close();
  }
}

final faceDetectionService =
FaceDetectionService();
