import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceCropService {

  Future<img.Image?> cropFace(
      String imagePath,
      Face face,
      ) async {

    final bytes =
    await File(imagePath).readAsBytes();

    final image =
    img.decodeImage(bytes);

    if (image == null) {
      return null;
    }

    final box =
        face.boundingBox;

    int x = box.left.toInt();
    int y = box.top.toInt();
    int width = box.width.toInt();
    int height = box.height.toInt();

    if (x < 0) x = 0;
    if (y < 0) y = 0;

    if (x + width > image.width) {
      width = image.width - x;
    }

    if (y + height > image.height) {
      height = image.height - y;
    }

    final cropped =
    img.copyCrop(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    return cropped;
  }
}

final faceCropService =
FaceCropService();
