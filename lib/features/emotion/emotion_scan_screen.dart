import 'dart:io';
import 'dart:typed_data' as typed_data;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/services/emosion_history_service.dart';

import '../../core/models/child_model.dart';
import '../../core/services/tts_service.dart';
import 'emotion_choice_screen.dart';

class EmotionScanScreen extends StatefulWidget {
  final ChildModel child;

  const EmotionScanScreen({
    super.key,
    required this.child,
  });

  @override
  State<EmotionScanScreen> createState() =>
      _EmotionScanScreenState();
}

class _EmotionScanScreenState extends State<EmotionScanScreen> {

  CameraController? _cameraController;

  bool _isCameraInitialized = false;
  bool _isScanning = false;

  // ============================================================
  // FACE DETECTOR
  // ============================================================

  late final FaceDetector _faceDetector;

  // ============================================================
  // TFLITE
  // ============================================================

  Interpreter? _interpreter;

  bool _isModelInitialized = false;

  // SERVICES


  final TtsService _ttsService = TtsService();

  final EmotionHistoryService _emotionHistoryService =
  EmotionHistoryService();


  static const String _modelPath =
      'assets/models/SensiBuddy_Emotion_CNN_Final.tflite';

  static const int _inputSize = 160;

  static const List<String> _labels = [
    'Natural',
    'anger',
    'fear',
    'joy',
    'sadness',
    'surprise',
  ];


  // INIT STATE


  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
        minFaceSize: 0.15,
      ),
    );

    _initialize();
  }

  // INITIALIZE EVERYTHING


  Future<void> _initialize() async {
    await _initializeCamera();
    await _initializeModel();
  }


  // CAMERA INITIALIZATION


  Future<void> _initializeCamera() async {
    try {
      final List<CameraDescription> cameras =
      await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isCameraInitialized = false;
        });

        return;
      }

      CameraDescription selectedCamera = cameras.first;

      // Prefer front camera
      for (final camera in cameras) {
        if (camera.lensDirection ==
            CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      _cameraController = controller;

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      await _speakWelcome();
    } catch (e) {
      debugPrint(
        'Camera initialization error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = false;
      });
    }
  }


  // TFLITE MODEL INITIALIZATION


  Future<void> _initializeModel() async {
    try {
      debugPrint(
        'Loading emotion model...',
      );

      final interpreter =
      await Interpreter.fromAsset(
        _modelPath,
      );

      interpreter.allocateTensors();

      _interpreter = interpreter;

      final inputDetails =
      interpreter.getInputTensor(0);

      final outputDetails =
      interpreter.getOutputTensor(0);

      debugPrint(
        '==========================================',
      );

      debugPrint(
        'EMOTION MODEL LOADED',
      );

      debugPrint(
        'Input shape: ${inputDetails.shape}',
      );

      debugPrint(
        'Input type: ${inputDetails.type}',
      );

      debugPrint(
        'Output shape: ${outputDetails.shape}',
      );

      debugPrint(
        'Output type: ${outputDetails.type}',
      );

      debugPrint(
        'Labels: $_labels',
      );

      debugPrint(
        '==========================================',
      );

      if (!mounted) return;

      setState(() {
        _isModelInitialized = true;
      });
    } catch (e) {
      debugPrint(
        'Emotion model initialization error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isModelInitialized = false;
      });
    }
  }


  // WELCOME VOICE


  Future<void> _speakWelcome() async {
    String message;

    switch (widget.child.language) {
      case 'si':
        message =
        '${widget.child.name}, මගේ දිහා බලන්න. '
            'ඔයාගේ හැඟීම මම බලන්නම්.';
        break;

      case 'ta':
        message =
        '${widget.child.name}, என்னைப் பாருங்கள். '
            'உங்கள் உணர்வை நான் பார்க்கிறேன்.';
        break;

      default:
        message =
        '${widget.child.name}, look at me. '
            'I will check how you are feeling.';
    }

    try {
      await _ttsService.speak(
        message,
        language: widget.child.language,
      );
    } catch (e) {
      debugPrint(
        'Welcome TTS error: $e',
      );
    }
  }


  // START EMOTION SCAN


  Future<void> _startEmotionScan() async {
    if (_isScanning) return;

    if (!_isCameraInitialized ||
        _cameraController == null) {
      _showError(
        'Camera is not ready.',
      );
      return;
    }

    if (!_isModelInitialized ||
        _interpreter == null) {
      _showError(
        'Emotion model is not ready.',
      );
      return;
    }

    if (!_cameraController!.value.isInitialized) {
      _showError(
        'Camera is not initialized.',
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {

      debugPrint(
        '==========================================',
      );

      debugPrint(
        'STARTING EMOTION RECOGNITION',
      );

      final XFile capturedFile =
      await _cameraController!.takePicture();

      debugPrint(
        'Captured image: ${capturedFile.path}',
      );

      // READ IMAGE

      final typed_data.Uint8List imageBytes =
      await File(
        capturedFile.path,
      ).readAsBytes();

      debugPrint(
        'Image bytes: ${imageBytes.length}',
      );

      // ML KIT FACE DETECTION

      final InputImage inputImage =
      InputImage.fromFilePath(
        capturedFile.path,
      );

      final List<Face> faces =
      await _faceDetector.processImage(
        inputImage,
      );

      debugPrint(
        'Faces detected: ${faces.length}',
      );

      if (faces.isEmpty) {
        throw Exception(
          'NO_FACE_DETECTED',
        );
      }

      // SELECT LARGEST FACE

      final Face selectedFace =
      _selectLargestFace(faces);

      debugPrint(
        'Selected face: ${selectedFace.boundingBox}',
      );

      // DECODE IMAGE

      img.Image? originalImage =
      img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception(
          'IMAGE_DECODE_FAILED',
        );
      }

      originalImage =
          img.bakeOrientation(
            originalImage,
          );

      debugPrint(
        'Original image size: '
            '${originalImage.width} x '
            '${originalImage.height}',
      );

      // CROP FACE

      final img.Image? faceImage =
      _cropFace(
        originalImage,
        selectedFace.boundingBox,
      );

      if (faceImage == null) {
        throw Exception(
          'FACE_CROP_FAILED',
        );
      }

      debugPrint(
        'Face crop size: '
            '${faceImage.width} x '
            '${faceImage.height}',
      );

      // RUN CNN MODEL

      final EmotionPrediction prediction =
      _predictEmotion(
        faceImage,
      );

// SAVE EMOTION RESULT TO FIRESTORE

      try {
        await _emotionHistoryService.saveEmotion(
          childId: widget.child.id,
          emotion: prediction.emotion,
          confidence: prediction.confidence,
          language: widget.child.language,
        );

        debugPrint(
          'Emotion history saved successfully.',
        );
      } catch (e) {
        debugPrint(
          'Emotion history save failed: $e',
        );
      }

      debugPrint(
        '------------------------------------------',
      );

      debugPrint(
        'PREDICTION RESULT',
      );

      debugPrint(
        'Emotion: ${prediction.emotion}',
      );

      debugPrint(
        'Confidence: '
            '${(prediction.confidence * 100).toStringAsFixed(2)}%',
      );

      debugPrint(
        'Class index: ${prediction.index}',
      );

      debugPrint(
        'All probabilities: '
            '${prediction.probabilities}',
      );

      debugPrint(
        '------------------------------------------',
      );

      if (!mounted) return;

      // SPEAK RESULT

      await _speakDetectedEmotion(
        prediction.emotion,
      );

      if (!mounted) return;

      // NAVIGATE

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmotionChoiceScreen(
                child: widget.child,
                emotion:
                prediction.emotion.toLowerCase(),
                confidence:
                prediction.confidence,
              ),
        ),
      );
    } catch (e) {
      debugPrint(
        '==========================================',
      );

      debugPrint(
        'EMOTION RECOGNITION ERROR',
      );

      debugPrint(
        '$e',
      );

      debugPrint(
        '==========================================',
      );

      if (!mounted) return;

      _showFriendlyError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // SELECT LARGEST FACE

  Face _selectLargestFace(
      List<Face> faces,
      ) {
    Face largestFace = faces.first;

    double largestArea =
        largestFace.boundingBox.width *
            largestFace.boundingBox.height;

    for (final face in faces.skip(1)) {
      final double area =
          face.boundingBox.width *
              face.boundingBox.height;

      if (area > largestArea) {
        largestFace = face;
        largestArea = area;
      }
    }

    return largestFace;
  }

  // CROP FACE

  img.Image? _cropFace(
      img.Image original,
      Rect boundingBox,
      ) {
    try {

      int left =
      boundingBox.left.round();

      int top =
      boundingBox.top.round();

      int right =
      boundingBox.right.round();

      int bottom =
      boundingBox.bottom.round();

      int faceWidth =
          right - left;

      int faceHeight =
          bottom - top;

      if (faceWidth <= 0 ||
          faceHeight <= 0) {
        return null;
      }

      // PADDING

      final int paddingX =
      (faceWidth * 0.20).round();

      final int paddingY =
      (faceHeight * 0.20).round();

      left -= paddingX;
      top -= paddingY;

      right += paddingX;
      bottom += paddingY;

      // CLAMP TO IMAGE

      left = left.clamp(
        0,
        original.width - 1,
      );

      top = top.clamp(
        0,
        original.height - 1,
      );

      right = right.clamp(
        left + 1,
        original.width,
      );

      bottom = bottom.clamp(
        top + 1,
        original.height,
      );

      final int cropWidth =
          right - left;

      final int cropHeight =
          bottom - top;

      if (cropWidth <= 1 ||
          cropHeight <= 1) {
        return null;
      }

      return img.copyCrop(
        original,
        x: left,
        y: top,
        width: cropWidth,
        height: cropHeight,
      );
    } catch (e) {
      debugPrint(
        'Face crop error: $e',
      );

      return null;
    }
  }

  // EMOTION PREDICTION

  EmotionPrediction _predictEmotion(
      img.Image faceImage,
      ) {
    if (_interpreter == null) {
      throw Exception(
        'MODEL_NOT_INITIALIZED',
      );
    }

    // RESIZE TO 160 x 160

    final img.Image resized =
    img.copyResize(
      faceImage,
      width: _inputSize,
      height: _inputSize,
      interpolation:
      img.Interpolation.linear,
    );


    final List<List<List<List<double>>>> input =
    [
      List.generate(
        _inputSize,
            (y) => List.generate(
          _inputSize,
              (x) {
            final pixel =
            resized.getPixel(x, y);

            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    ];

    // OUTPUT
    // Model output:
    // [1, 6]

    final List<List<double>> output =
    [
      List<double>.filled(
        _labels.length,
        0.0,
      ),
    ];

    // RUN TFLITE

    _interpreter!.run(
      input,
      output,
    );

    final List<double> probabilities =
    List<double>.from(
      output[0],
    );

    if (probabilities.length !=
        _labels.length) {
      throw Exception(
        'Unexpected model output size: '
            '${probabilities.length}',
      );
    }

    // FIND HIGHEST PROBABILITY

    int bestIndex = 0;

    double bestProbability =
    probabilities[0];

    for (int i = 1;
    i < probabilities.length;
    i++) {
      if (probabilities[i] >
          bestProbability) {
        bestProbability =
        probabilities[i];

        bestIndex = i;
      }
    }

    // RETURN RESULT

    return EmotionPrediction(
      emotion: _labels[bestIndex],
      confidence: bestProbability,
      index: bestIndex,
      probabilities: probabilities,
    );
  }

  // SPEAK DETECTED EMOTION

  Future<void> _speakDetectedEmotion(
      String emotion,
      ) async {
    final String normalized =
    emotion.toLowerCase();

    String message;

    switch (widget.child.language) {
      case 'si':
        switch (normalized) {
          case 'joy':
            message =
            'ඔයා සතුටින් වගේ පේනවා!';
            break;

          case 'sadness':
            message =
            'ඔයා ටිකක් දුකෙන් වගේ පේනවා.';
            break;

          case 'anger':
          case 'angry':
            message =
            'ඔයා ටිකක් කේන්තියෙන් වගේ පේනවා.';
            break;

          case 'fear':
            message =
            'ඔයා ටිකක් බය වෙලා වගේ පේනවා.';
            break;

          case 'surprise':
            message =
            'ඔයා පුදුම වෙලා වගේ පේනවා!';
            break;

          case 'natural':
            message =
            'ඔයා සන්සුන්ව වගේ පේනවා.';
            break;

          default:
            message =
            'මට ඔයාගේ හැඟීම හඳුනාගන්න පුළුවන් වුණා.';
        }
        break;

      case 'ta':
        switch (normalized) {
          case 'joy':
            message =
            'நீங்கள் மகிழ்ச்சியாக இருக்கிறீர்கள்!';
            break;

          case 'sadness':
            message =
            'நீங்கள் கொஞ்சம் சோகமாக இருக்கிறீர்கள்.';
            break;

          case 'anger':
          case 'angry':
            message =
            'நீங்கள் கொஞ்சம் கோபமாக இருக்கிறீர்கள்.';
            break;

          case 'fear':
            message =
            'நீங்கள் கொஞ்சம் பயமாக இருக்கிறீர்கள்.';
            break;

          case 'surprise':
            message =
            'நீங்கள் ஆச்சரியமாக இருக்கிறீர்கள்!';
            break;

          case 'natural':
            message =
            'நீங்கள் அமைதியாக இருக்கிறீர்கள்.';
            break;

          default:
            message =
            'உங்கள் உணர்வை என்னால் கண்டறிய முடிந்தது.';
        }
        break;

      default:
        switch (normalized) {
          case 'joy':
            message =
            'You look happy!';
            break;

          case 'sadness':
            message =
            'You look a little sad.';
            break;

          case 'anger':
          case 'angry':
            message =
            'You look a little angry.';
            break;

          case 'fear':
            message =
            'You look a little scared.';
            break;

          case 'surprise':
            message =
            'You look surprised!';
            break;

          case 'natural':
            message =
            'You look calm.';
            break;

          default:
            message =
            'I detected your emotion.';
        }
    }

    try {
      await _ttsService.speak(
        message,
        language: widget.child.language,
      );
    } catch (e) {
      debugPrint(
        'Emotion TTS error: $e',
      );
    }
  }

  // ERROR HANDLING

  void _showFriendlyError(
      Object error,
      ) {
    final String errorText =
    error.toString();

    if (errorText.contains(
      'NO_FACE_DETECTED',
    )) {
      _showError(
        _getNoFaceText(),
      );

      return;
    }

    if (errorText.contains(
      'IMAGE_DECODE_FAILED',
    )) {
      _showError(
        _getImageErrorText(),
      );

      return;
    }

    if (errorText.contains(
      'FACE_CROP_FAILED',
    )) {
      _showError(
        _getFaceCropErrorText(),
      );

      return;
    }

    if (errorText.contains(
      'MODEL_NOT_INITIALIZED',
    )) {
      _showError(
        _getModelErrorText(),
      );

      return;
    }

    _showError(
      _getGeneralErrorText(),
    );
  }

  String _getNoFaceText() {
    switch (widget.child.language) {
      case 'si':
        return 'මුහුණ හඳුනාගන්න බැරි වුණා. '
            'කරුණාකර කැමරාව දිහා කෙලින් බලන්න.';

      case 'ta':
        return 'முகத்தை கண்டறிய முடியவில்லை. '
            'தயவுசெய்து கேமராவை நேராக பாருங்கள்.';

      default:
        return 'I could not detect your face. '
            'Please look directly at the camera.';
    }
  }

  String _getImageErrorText() {
    switch (widget.child.language) {
      case 'si':
        return 'ඡායාරූපය කියවීමට නොහැකි වුණා. '
            'කරුණාකර නැවත උත්සාහ කරන්න.';

      case 'ta':
        return 'படத்தை படிக்க முடியவில்லை. '
            'மீண்டும் முயற்சிக்கவும்.';

      default:
        return 'I could not read the camera image. '
            'Please try again.';
    }
  }

  String _getFaceCropErrorText() {
    switch (widget.child.language) {
      case 'si':
        return 'මුහුණ process කිරීමට නොහැකි වුණා. '
            'කරුණාකර නැවත උත්සාහ කරන්න.';

      case 'ta':
        return 'முகத்தை செயலாக்க முடியவில்லை. '
            'மீண்டும் முயற்சிக்கவும்.';

      default:
        return 'I could not process the detected face. '
            'Please try again.';
    }
  }

  String _getModelErrorText() {
    switch (widget.child.language) {
      case 'si':
        return 'Emotion model එක සූදානම් නැහැ.';

      case 'ta':
        return 'Emotion model தயாராக இல்லை.';

      default:
        return 'The emotion model is not ready.';
    }
  }

  String _getGeneralErrorText() {
    switch (widget.child.language) {
      case 'si':
        return 'Emotion එක හඳුනාගැනීමේදී '
            'ගැටලුවක් ඇති වුණා. නැවත උත්සාහ කරන්න.';

      case 'ta':
        return 'உணர்வை கண்டறிவதில் சிக்கல் ஏற்பட்டது. '
            'மீண்டும் முயற்சிக்கவும்.';

      default:
        return 'Something went wrong while '
            'checking your emotion. Please try again.';
    }
  }

  void _showError(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          duration:
          const Duration(seconds: 4),
          content: Text(
            message,
          ),
        ),
      );
  }

  // DISPOSE

  @override
  void dispose() {
    _ttsService.stop();

    _faceDetector.close();

    _interpreter?.close();

    _cameraController?.dispose();

    super.dispose();
  }

  // BUILD

  @override
  Widget build(
      BuildContext context,
      ) {
    final bool ready =
        _isCameraInitialized &&
            _isModelInitialized &&
            !_isScanning;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F3FF),

      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                            0.06,
                          ),
                          blurRadius: 10,
                          offset:
                          const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isScanning
                          ? null
                          : () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .arrow_back_rounded,
                        color:
                        Color(0xFF5B3FA6),
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Check My Emotion',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xFF5B3FA6),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),
            ),

            // CAMERA

            Expanded(
              child: Center(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration:
                      BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF7B61FF,
                            ).withOpacity(
                              0.20,
                            ),
                            blurRadius: 22,
                            offset:
                            const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                      ),
                      clipBehavior:
                      Clip.antiAlias,
                      child:
                      _buildCameraView(),
                    ),
                  ),
                ),
              ),
            ),

            // STATUS

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 12,
              ),
              child: Text(
                _getStatusText(),
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color:
                  Colors.black54,
                ),
              ),
            ),

            // CHECK BUTTON

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                24,
                5,
                24,
                28,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 62,
                child:
                ElevatedButton.icon(
                  onPressed:
                  ready
                      ? _startEmotionScan
                      : null,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xFF7B61FF,
                    ),
                    foregroundColor:
                    Colors.white,
                    disabledBackgroundColor:
                    Colors.grey.shade400,
                    elevation: 6,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                  icon: Icon(
                    _isScanning
                        ? Icons
                        .hourglass_top_rounded
                        : Icons
                        .face_retouching_natural_rounded,
                    size: 27,
                  ),
                  label: Text(
                    _isScanning
                        ? 'Checking...'
                        : 'Check My Emotion',
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CAMERA VIEW

  Widget _buildCameraView() {
    if (!_isCameraInitialized ||
        _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color:
          Color(0xFF7B61FF),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // CAMERA PREVIEW

        CameraPreview(
          _cameraController!,
        ),

        // DARK GRADIENT OVERLAY

        IgnorePointer(
          child: DecoratedBox(
            decoration:
            BoxDecoration(
              gradient:
              LinearGradient(
                begin:
                Alignment.topCenter,
                end:
                Alignment.bottomCenter,
                colors: [
                  Colors.black
                      .withOpacity(
                    0.05,
                  ),
                  Colors.transparent,
                  Colors.black
                      .withOpacity(
                    0.20,
                  ),
                ],
              ),
            ),
          ),
        ),

        // FACE GUIDE

        Center(
          child: Container(
            width: 215,
            height: 270,
            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                130,
              ),
              border:
              Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
        ),

        // MODEL STATUS

        Positioned(
          top: 18,
          left: 18,
          right: 18,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              _buildStatusChip(
                icon:
                Icons.camera_alt_rounded,
                text:
                _isCameraInitialized
                    ? 'Camera Ready'
                    : 'Camera...',
              ),
              _buildStatusChip(
                icon:
                Icons.psychology_rounded,
                text:
                _isModelInitialized
                    ? 'AI Ready'
                    : 'AI...',
              ),
            ],
          ),
        ),

        // SCANNING OVERLAY

        if (_isScanning)
          Container(
            color: Colors.black
                .withOpacity(
              0.40,
            ),
            child: const Center(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth: 4,
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Text(
                    'Checking your emotion...',
                    textAlign:
                    TextAlign.center,
                    style:
                    TextStyle(
                      color:
                      Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // STATUS CHIP

  Widget _buildStatusChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration:
      BoxDecoration(
        color: Colors.black
            .withOpacity(
          0.45,
        ),
        borderRadius:
        BorderRadius.circular(
          30,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            text,
            style:
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // STATUS TEXT


  String _getStatusText() {
    if (_isScanning) {
      switch (widget.child.language) {
        case 'si':
          return 'ඔයාගේ මුහුණ සහ හැඟීම පරීක්ෂා කරමින්...';

        case 'ta':
          return 'உங்கள் முகத்தையும் உணர்வையும் சரிபார்க்கிறேன்...';

        default:
          return 'Checking your face and emotion...';
      }
    }

    if (!_isCameraInitialized) {
      return 'Starting camera...';
    }

    if (!_isModelInitialized) {
      return 'Loading emotion AI model...';
    }

    switch (widget.child.language) {
      case 'si':
        return 'කැමරාව දිහා බලලා '
            'ඔයාගේ මුහුණ පැහැදිලිව පෙන්වන්න 😊';

      case 'ta':
        return 'கேமராவை நேராக பார்த்து '
            'உங்கள் முகத்தை தெளிவாக காட்டுங்கள் 😊';

      default:
        return 'Look at the camera and '
            'show your face clearly 😊';
    }
  }
}

// EMOTION PREDICTION MODEL


class EmotionPrediction {
  final String emotion;
  final double confidence;
  final int index;
  final List<double> probabilities;

  const EmotionPrediction({
    required this.emotion,
    required this.confidence,
    required this.index,
    required this.probabilities,
  });
}