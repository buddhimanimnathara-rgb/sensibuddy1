import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {

  Interpreter? _interpreter;

  Future<void> loadModel() async {

    try {

      print("Loading MobileFaceNet...");

      final data = await rootBundle.load(
        'assets/models/MobileFaceNet.tflite',
      );

      print(
        "MODEL FOUND: ${data.lengthInBytes} bytes",
      );

      _interpreter =
      await Interpreter.fromAsset(
        'assets/models/MobileFaceNet.tflite',
      );

      print(
        " MobileFaceNet Loaded",
      );

    } catch (e) {

      print(
        " Model Load Error: $e",
      );
    }
  }

  void printModelInfo() {
    if (_interpreter == null) {
      print("Model not loaded");
      return;
    }

    print(
      "Input Shape: ${_interpreter!.getInputTensor(0).shape}",
    );

    print(
      "Output Shape: ${_interpreter!.getOutputTensor(0).shape}",
    );
  }

  bool get isLoaded =>
      _interpreter != null;

  Interpreter? get interpreter =>
      _interpreter;
}

final faceRecognitionService =
FaceRecognitionService();
