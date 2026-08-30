import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../core/services/face_embedding_service.dart';

class LiveFaceRegistrationScreen extends StatefulWidget {
  const LiveFaceRegistrationScreen({
    super.key,
  });

  @override
  State<LiveFaceRegistrationScreen> createState() =>
      _LiveFaceRegistrationScreenState();
}

class _LiveFaceRegistrationScreenState
    extends State<LiveFaceRegistrationScreen> {


  CameraController? _cameraController;

  late FaceDetector _faceDetector;

  bool _isCameraInitialized = false;

  bool _isProcessing = false;

  bool _isCapturing = false;

  bool _isDisposed = false;

  bool _faceDetected = false;

  Face? _currentFace;

  List<double>? _currentEmbedding;


  DateTime? _lastEmbeddingTime;

  static const Duration _embeddingInterval =
  Duration(milliseconds: 800);


  // INIT

  @override
  void initState() {
    super.initState();

    _initializeFaceDetector();
    _initializeCamera();
  }


  // INITIALIZE FACE DETECTOR

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }


  // INITIALIZE CAMERA

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No camera available');
      }

      final frontCamera = cameras.firstWhere(
            (camera) =>
        camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,


        // Android ML Kit compatible format
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();

      if (!mounted || _isDisposed) {
        return;
      }

      setState(() {
        _isCameraInitialized = true;
      });

      await _cameraController!.startImageStream(
        _processCameraImage,
      );

      debugPrint('📷 Live camera started');
      debugPrint(
        '📷 Camera format: '
            '${_cameraController!.value.description.lensDirection}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Camera initialization error: $e');

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Camera initialization failed: $e',
            ),
          ),
        );
      }
    }
  }

  // GET CORRECT ROTATION

  InputImageRotation? _getRotation() {
    final camera = _cameraController?.description;

    if (camera == null) {
      return null;
    }

    return InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
  }

  // PROCESS LIVE CAMERA IMAGE

  Future<void> _processCameraImage(
      CameraImage image,
      ) async {
    if (_isProcessing ||
        _isCapturing ||
        _isDisposed) {
      return;
    }

    _isProcessing = true;

    try {
      // DEBUG CAMERA FORMAT

      debugPrint(
        '📷 Image format: '
            '${image.format.group}',
      );


      // GET ROTATION

      final rotation = _getRotation();

      if (rotation == null) {
        debugPrint('❌ Camera rotation not supported');
        return;
      }

      // CONVERT CAMERA IMAGE → INPUT IMAGE

      final inputImage = _inputImageFromCameraImage(
        image,
        rotation,
      );

      if (inputImage == null) {
        return;
      }

      // DETECT FACE

      final faces = await _faceDetector.processImage(
        inputImage,
      );

      // NO FACE

      if (faces.isEmpty) {
        if (mounted &&
            !_isDisposed &&
            _faceDetected) {
          setState(() {
            _faceDetected = false;
            _currentFace = null;
            _currentEmbedding = null;
          });
        }

        return;
      }

      // USE FIRST FACE

      final face = faces.first;

      if (mounted && !_isDisposed) {
        if (!_faceDetected) {
          setState(() {
            _faceDetected = true;
          });
        }

        _currentFace = face;
      }

      // EMBEDDING INTERVAL

      final now = DateTime.now();

      if (_lastEmbeddingTime != null &&
          now.difference(_lastEmbeddingTime!) <
              _embeddingInterval) {
        return;
      }

      _lastEmbeddingTime = now;

      // GENERATE LIVE EMBEDDING

      final embedding =
      await faceEmbeddingService
          .generateEmbeddingFromCameraImage(
        image,
        face,
        rotation,
      );

      if (!mounted ||
          _isDisposed ||
          _isCapturing) {
        return;
      }

      // VALIDATE EMBEDDING

      if (embedding.length == 192) {
        setState(() {
          _currentEmbedding =
          List<double>.from(embedding);
        });

        debugPrint(
          '🧠 Live embedding ready: '
              '${embedding.length}',
        );
      } else {
        debugPrint(
          '⚠️ Invalid embedding length: '
              '${embedding.length}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Live face processing error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      _isProcessing = false;
    }
  }

  // CAMERA IMAGE → ML KIT INPUT IMAGE

  InputImage? _inputImageFromCameraImage(
      CameraImage image,
      InputImageRotation rotation,
      ) {
    if (image.planes.isEmpty) {
      debugPrint('❌ Camera image has no planes');

      return null;
    }

    // ONLY SUPPORT NV21

    if (image.format.group !=
        ImageFormatGroup.nv21) {
      debugPrint(
        '❌ Unsupported camera image format: '
            '${image.format.group}',
      );

      return null;
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // CAPTURE FACE
  Future<void> _captureFace() async {
    if (_isCapturing) {
      return;
    }

    // CHECK FACE

    if (!_faceDetected ||
        _currentFace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please keep your face visible to the camera.',
          ),
        ),
      );

      return;
    }

    // CHECK EMBEDDING
    if (_currentEmbedding == null ||
        _currentEmbedding!.length != 192) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'Face is still scanning. Please wait a moment.',
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      debugPrint('📸 Capturing face sample...');


      // SAFE COPY OF LIVE EMBEDDING

      final embedding =
      List<double>.from(
        _currentEmbedding!,
      );

      // STOP LIVE STREAM

      if (_cameraController != null &&
          _cameraController!
              .value
              .isStreamingImages) {
        await _cameraController!
            .stopImageStream();
      }

      // CHECK CAMERA

      if (_cameraController == null ||
          !_cameraController!
              .value
              .isInitialized) {
        throw Exception(
          'Camera is not ready',
        );
      }

      // TAKE PHOTO


      final XFile photo =
      await _cameraController!
          .takePicture();

      final File file =
      File(photo.path);

      final bool exists =
      await file.exists();

      if (!exists) {
        throw Exception(
          'Captured image file not found',
        );
      }

      debugPrint(
        '📷 Photo captured: '
            '${file.path}',
      );

      debugPrint(
        '🧠 Live embedding captured: '
            '${embedding.length}',
      );

      if (!mounted ||
          _isDisposed) {
        return;
      }

      // RETURN PHOTO + SAME LIVE EMBEDDING

      Navigator.pop(
        context,
        {
          'image': file,
          'embedding': embedding,
        },
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Capture error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (mounted &&
          !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Capture failed: $e',
            ),
          ),
        );
      }

      // RESTART STREAM

      if (_cameraController != null &&
          _cameraController!
              .value
              .isInitialized &&
          !_cameraController!
              .value
              .isStreamingImages) {
        try {
          await _cameraController!
              .startImageStream(
            _processCameraImage,
          );
        } catch (restartError) {
          debugPrint(
            '❌ Failed to restart stream: '
                '$restartError',
          );
        }
      }

      if (mounted &&
          !_isDisposed) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // DISPOSE

  @override
  void dispose() {
    _isDisposed = true;

    final controller =
        _cameraController;

    if (controller != null) {
      if (controller
          .value
          .isStreamingImages) {
        controller.stopImageStream();
      }

      controller.dispose();
    }

    _faceDetector.close();

    super.dispose();
  }

  // UI

  @override
  Widget build(
      BuildContext context,
      ) {
    final bool readyToCapture =
        _isCameraInitialized &&
            _faceDetected &&
            _currentEmbedding != null &&
            _currentEmbedding!.length == 192 &&
            !_isCapturing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding:
              const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isCapturing
                        ? null
                        : () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Live Face Registration',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),
            ),

            // CAMERA PREVIEW

            Expanded(
              child: _isCameraInitialized &&
                  _cameraController !=
                      null
                  ? CameraPreview(
                _cameraController!,
              )
                  : const Center(
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

            // FACE STATUS

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(16),
              color: readyToCapture
                  ? Colors.green
                  : _faceDetected
                  ? Colors.orange
                  : Colors.red,
              child: Text(
                !_isCameraInitialized
                    ? 'Starting camera...'
                    : !_faceDetected
                    ? 'Looking for face...'
                    : _currentEmbedding == null
                    ? 'Face detected • Scanning...'
                    : _currentEmbedding!
                    .length !=
                    192
                    ? 'Face detected • Preparing...'
                    : 'Face detected • Ready to capture',
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            // CAPTURE BUTTON

            Padding(
              padding:
              const EdgeInsets.all(25),
              child: GestureDetector(
                onTap: readyToCapture
                    ? _captureFace
                    : null,
                child: AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 200,
                  ),
                  width: 80,
                  height: 80,
                  decoration:
                  BoxDecoration(
                    color: readyToCapture
                        ? Colors.deepPurple
                        : Colors.grey,
                    shape:
                    BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: _isCapturing
                      ? const Padding(
                    padding:
                    EdgeInsets.all(22),
                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),

            const Padding(
              padding:
              EdgeInsets.only(
                bottom: 20,
              ),
              child: Text(
                'Keep your face clearly visible before capturing',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}