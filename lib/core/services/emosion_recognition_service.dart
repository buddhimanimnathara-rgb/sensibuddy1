import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class EmotionResult {
  final String emotion;
  final double confidence;

  const EmotionResult({
    required this.emotion,
    required this.confidence,
  });
}

class EmotionRecognitionService {
  Interpreter? _interpreter;

  static const String modelAsset =
      'assets/models/SensiBuddy_Emotion_CNN_Final.tflite';

  static const int inputSize = 160;

  // Exact order from your trained model
  static const List<String> labels = [
    'Natural',
    'anger',
    'fear',
    'joy',
    'sadness',
    'surprise',
  ];

  Future<void> initialize() async {
    if (_interpreter != null) return;

    _interpreter = await Interpreter.fromAsset(modelAsset);

    _interpreter!.allocateTensors();
  }

  Future<EmotionResult> predictFromFile(String imagePath) async {
    await initialize();

    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('Image file not found: $imagePath');
    }

    final bytes = await file.readAsBytes();

    return predictFromBytes(bytes);
  }

  EmotionResult predictFromBytes(Uint8List bytes) {
    if (_interpreter == null) {
      throw StateError(
        'Emotion model is not initialized.',
      );
    }

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Could not decode image.');
    }

    return predict(decoded);
  }

  EmotionResult predict(img.Image image) {
    if (_interpreter == null) {
      throw StateError(
        'Emotion model is not initialized.',
      );
    }

    // Model input = [1, 160, 160, 3]
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final input = [
      List.generate(
        inputSize,
            (y) => List.generate(
          inputSize,
              (x) {
            final pixel = resized.getPixel(x, y);

            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          },
        ),
      ),
    ];

    // Model output = [1, 6]
    final output = [
      List<double>.filled(labels.length, 0.0),
    ];

    _interpreter!.run(input, output);

    final probabilities = output[0];

    int bestIndex = 0;
    double bestConfidence = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > bestConfidence) {
        bestConfidence = probabilities[i];
        bestIndex = i;
      }
    }

    return EmotionResult(
      emotion: labels[bestIndex],
      confidence: bestConfidence.clamp(0.0, 1.0),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}