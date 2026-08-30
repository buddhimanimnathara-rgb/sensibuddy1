import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'face_recognition.dart';
import 'face_detection_service.dart';
import 'face_crop_service.dart';

class FaceEmbeddingService {

  // Guardian Face Registration
  // Child Face Registration
  Future<List<double>> generateEmbedding(
      String imagePath,
      ) async {
    final face = await faceDetectionService.getFace(
      imagePath,
    );

    if (face == null) {
      throw Exception(
        'No face detected',
      );
    }

    final croppedFace = await faceCropService.cropFace(
      imagePath,
      face,
    );

    if (croppedFace == null) {
      throw Exception(
        'Face crop failed',
      );
    }

    return _generateEmbeddingFromImage(
      croppedFace,
    );
  }

  // LIVE CAMERA → EMBEDDING

  Future<List<double>> generateEmbeddingFromCameraImage(
      CameraImage image,
      Face face,
      InputImageRotation rotation,
      ) async {
    try {
      print(
        '📷 Camera format: ${image.format.group}',
      );

      print(
        '🔄 Camera rotation: $rotation',
      );

      // CAMERA IMAGE → RGB

      final convertedImage =
      _convertCameraImageToRgb(
        image,
      );

      if (convertedImage == null) {
        throw Exception(
          'Unsupported camera image format',
        );
      }

      // ROTATE IMAGE
      // Use the same orientation as ML Kit face detection.

      final orientedImage =
      _rotateImageForMlKit(
        convertedImage,
        rotation,
      );

      // GET FACE BOUNDING BOX

      final box = face.boundingBox;

      int left = box.left.floor();
      int top = box.top.floor();
      int right = box.right.ceil();
      int bottom = box.bottom.ceil();

      // KEEP FACE BOX INSIDE IMAGE

      left = left.clamp(
        0,
        orientedImage.width - 1,
      );

      top = top.clamp(
        0,
        orientedImage.height - 1,
      );

      right = right.clamp(
        left + 1,
        orientedImage.width,
      );

      bottom = bottom.clamp(
        top + 1,
        orientedImage.height,
      );

      final faceWidth =
          right - left;

      final faceHeight =
          bottom - top;

      if (faceWidth <= 0 ||
          faceHeight <= 0) {
        throw Exception(
          'Invalid face crop dimensions',
        );
      }

      print(
        ' Face box: '
            'left=$left, '
            'top=$top, '
            'width=$faceWidth, '
            'height=$faceHeight',
      );

      print(
        ' Oriented image: '
            '${orientedImage.width}x'
            '${orientedImage.height}',
      );

      // ADD SMALL FACE PADDING
      // Prevents an overly tight face crop.

      final paddingX =
      (faceWidth * 0.15).round();

      final paddingY =
      (faceHeight * 0.15).round();

      final cropLeft =
      (left - paddingX).clamp(
        0,
        orientedImage.width - 1,
      );

      final cropTop =
      (top - paddingY).clamp(
        0,
        orientedImage.height - 1,
      );

      final cropRight =
      (right + paddingX).clamp(
        cropLeft + 1,
        orientedImage.width,
      );

      final cropBottom =
      (bottom + paddingY).clamp(
        cropTop + 1,
        orientedImage.height,
      );

      final cropWidth =
          cropRight - cropLeft;

      final cropHeight =
          cropBottom - cropTop;

      if (cropWidth <= 0 ||
          cropHeight <= 0) {
        throw Exception(
          'Invalid padded face crop dimensions',
        );
      }

      // CROP FACE

      final croppedFace = img.copyCrop(
        orientedImage,
        x: cropLeft,
        y: cropTop,
        width: cropWidth,
        height: cropHeight,
      );

      // CROPPED FACE → 192D EMBEDDING

      final embedding =
      _generateEmbeddingFromImage(
        croppedFace,
      );

      print(
        ' LIVE EMBEDDING GENERATED: '
            '${embedding.length}',
      );

      return embedding;
    } catch (e, stackTrace) {
      print(
        ' LIVE EMBEDDING ERROR: $e',
      );

      print(
        stackTrace,
      );

      rethrow;
    }
  }

  // ROTATE IMAGE FOR ML KIT COORDINATES

  img.Image _rotateImageForMlKit(
      img.Image image,
      InputImageRotation rotation,
      ) {
    switch (rotation) {
      case InputImageRotation.rotation0deg:
        return image;

      case InputImageRotation.rotation90deg:
        return img.copyRotate(
          image,
          angle: 90,
        );

      case InputImageRotation.rotation180deg:
        return img.copyRotate(
          image,
          angle: 180,
        );

      case InputImageRotation.rotation270deg:
        return img.copyRotate(
          image,
          angle: 270,
        );
    }
  }

  // CAMERA IMAGE → RGB IMAGE

  img.Image? _convertCameraImageToRgb(
      CameraImage image,
      ) {
    // YUV420

    if (image.format.group ==
        ImageFormatGroup.yuv420) {
      return _convertYuv420ToRgb(
        image,
      );
    }

    // NV21

    if (image.format.group ==
        ImageFormatGroup.nv21) {
      return _convertNv21ToRgb(
        image,
      );
    }

    // BGRA8888

    if (image.format.group ==
        ImageFormatGroup.bgra8888) {
      return _convertBgra8888ToRgb(
        image,
      );
    }

    print(
      ' Unsupported image format: '
          '${image.format.group}',
    );

    return null;
  }

  // YUV420 → RGB

  img.Image _convertYuv420ToRgb(
      CameraImage image,
      ) {
    final width = image.width;
    final height = image.height;

    final convertedImage = img.Image(
      width: width,
      height: height,
    );

    if (image.planes.length < 3) {
      throw Exception(
        'Invalid YUV420 image',
      );
    }

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride =
        yPlane.bytesPerRow;

    final uvRowStride =
        uPlane.bytesPerRow;

    final uvPixelStride =
        uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex =
            y * yRowStride + x;

        final uvIndex =
            (y ~/ 2) * uvRowStride +
                (x ~/ 2) * uvPixelStride;

        if (yIndex >= yBytes.length ||
            uvIndex >= uBytes.length ||
            uvIndex >= vBytes.length) {
          continue;
        }

        final yValue =
        yBytes[yIndex];

        final uValue =
            uBytes[uvIndex] - 128;

        final vValue =
            vBytes[uvIndex] - 128;

        int r =
        (yValue +
            1.402 * vValue)
            .round();

        int g =
        (yValue -
            0.344136 * uValue -
            0.714136 * vValue)
            .round();

        int b =
        (yValue +
            1.772 * uValue)
            .round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        convertedImage.setPixelRgb(
          x,
          y,
          r,
          g,
          b,
        );
      }
    }

    return convertedImage;
  }

  // NV21 → RGB

  img.Image _convertNv21ToRgb(
      CameraImage image,
      ) {
    final width = image.width;
    final height = image.height;

    final convertedImage = img.Image(
      width: width,
      height: height,
    );

    if (image.planes.isEmpty) {
      throw Exception(
        'Invalid NV21 image',
      );
    }

    final plane =
        image.planes.first;

    final bytes =
        plane.bytes;

    final ySize =
        width * height;

    if (bytes.length < ySize) {
      throw Exception(
        'Invalid NV21 camera image',
      );
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex =
            y * width + x;

        if (yIndex >= bytes.length) {
          continue;
        }

        final yValue =
        bytes[yIndex];

        final uvRow =
            y ~/ 2;

        final uvColumn =
            (x ~/ 2) * 2;

        final uvIndex =
            ySize +
                uvRow * width +
                uvColumn;

        if (uvIndex + 1 >=
            bytes.length) {
          continue;
        }

        final vValue =
            bytes[uvIndex] - 128;

        final uValue =
            bytes[uvIndex + 1] - 128;

        int r =
        (yValue +
            1.402 * vValue)
            .round();

        int g =
        (yValue -
            0.344136 * uValue -
            0.714136 * vValue)
            .round();

        int b =
        (yValue +
            1.772 * uValue)
            .round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        convertedImage.setPixelRgb(
          x,
          y,
          r,
          g,
          b,
        );
      }
    }

    return convertedImage;
  }

  // BGRA8888 → RGB

  img.Image _convertBgra8888ToRgb(
      CameraImage image,
      ) {
    final width = image.width;
    final height = image.height;

    final convertedImage = img.Image(
      width: width,
      height: height,
    );

    final plane =
    image.planes[0];

    final bytes =
        plane.bytes;

    final bytesPerRow =
        plane.bytesPerRow;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index =
            y * bytesPerRow +
                x * 4;

        if (index + 3 >=
            bytes.length) {
          continue;
        }

        final b = bytes[index];
        final g = bytes[index + 1];
        final r = bytes[index + 2];

        convertedImage.setPixelRgb(
          x,
          y,
          r,
          g,
          b,
        );
      }
    }

    return convertedImage;
  }

  // CROPPED IMAGE to 192D EMBEDDING
  // BOTH PHOTO AND LIVE CAMERA USE THIS METHOD

  List<double> _generateEmbeddingFromImage(
      img.Image croppedFace,
      ) {
    // RESIZE TO MOBILEFACENET INPUT

    final resized = img.copyResize(
      croppedFace,
      width: 112,
      height: 112,
    );

    // MODEL INPUT
    // [2, 112, 112, 3]

    final input = List.generate(
      2,
          (_) => List.generate(
        112,
            (_) => List.generate(
          112,
              (_) => List.filled(
            3,
            0.0,
          ),
        ),
      ),
    );

    // RGB NORMALIZATION

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel =
        resized.getPixel(x, y);

        input[0][y][x][0] =
            pixel.r / 255.0;

        input[0][y][x][1] =
            pixel.g / 255.0;

        input[0][y][x][2] =
            pixel.b / 255.0;
      }
    }

    // MODEL OUTPUT
    // [2, 192]

    final output = List.generate(
      2,
          (_) => List.filled(
        192,
        0.0,
      ),
    );

    // RUN MODEL
    faceRecognitionService
        .interpreter!
        .run(
      input,
      output,
    );

    return List<double>.from(
      output[0],
    );
  }
}

// GLOBAL INSTANCE

final faceEmbeddingService =
FaceEmbeddingService();