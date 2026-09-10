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

  // CAPTURED PHOTO PREVIEW

  File? _capturedPhoto;

  List<double>? _capturedEmbedding;

  bool get _isPreviewingPhoto =>
      _capturedPhoto != null &&
          _capturedEmbedding != null;

  // INIT
  @override
  void initState() {
    super.initState();

    _initializeFaceDetector();
    _initializeCamera();
  }

  // FACE DETECTOR

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

  // CAMERA INITIALIZATION

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

      debugPrint(' Live camera started');

      debugPrint(
        ' Camera format: '
            '${_cameraController!.value.description.lensDirection}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' Camera initialization error: $e',
      );

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

  // CAMERA ROTATION

  InputImageRotation? _getRotation() {
    final camera = _cameraController?.description;

    if (camera == null) {
      return null;
    }

    return InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
  }

  // PROCESS CAMERA IMAGE

  Future<void> _processCameraImage(
      CameraImage image,
      ) async {
    if (_isProcessing ||
        _isCapturing ||
        _isDisposed ||
        _isPreviewingPhoto) {
      return;
    }

    _isProcessing = true;

    try {
      debugPrint(
        ' Image format: ${image.format.group}',
      );

      final rotation = _getRotation();

      if (rotation == null) {
        debugPrint(
          ' Camera rotation not supported',
        );

        return;
      }

      final inputImage = _inputImageFromCameraImage(
        image,
        rotation,
      );

      if (inputImage == null) {
        return;
      }

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

      // FIRST FACE

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

      // GENERATE EMBEDDING

      final embedding =
      await faceEmbeddingService
          .generateEmbeddingFromCameraImage(
        image,
        face,
        rotation,
      );

      if (!mounted ||
          _isDisposed ||
          _isCapturing ||
          _isPreviewingPhoto) {
        return;
      }

      // VALIDATE EMBEDDING

      if (embedding.length == 192) {
        setState(() {
          _currentEmbedding =
          List<double>.from(embedding);
        });

        debugPrint(
          ' Live embedding ready: '
              '${embedding.length}',
        );
      } else {
        debugPrint(
          ' Invalid embedding length: '
              '${embedding.length}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        ' Live face processing error: $e',
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
      debugPrint(
        ' Camera image has no planes',
      );

      return null;
    }

    if (image.format.group !=
        ImageFormatGroup.nv21) {
      debugPrint(
        ' Unsupported camera image format: '
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

  // CAPTURE PHOTO

  Future<void> _captureFace() async {
    if (_isCapturing ||
        _isPreviewingPhoto) {
      return;
    }

    // FACE CHECK

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

    // EMBEDDING CHECK

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

      debugPrint(
        ' Capturing face sample...',
      );

      // SAFE COPY OF EMBEDDING

      final embedding =
      List<double>.from(
        _currentEmbedding!,
      );

      // STOP STREAM

      if (_cameraController != null &&
          _cameraController!
              .value
              .isStreamingImages) {
        await _cameraController!
            .stopImageStream();
      }

      // CAMERA CHECK

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
        ' Photo captured: ${file.path}',
      );

      debugPrint(
        ' Embedding captured: '
            '${embedding.length}',
      );

      if (!mounted ||
          _isDisposed) {
        return;
      }

      // SHOW PREVIEW

      setState(() {
        _capturedPhoto = file;

        _capturedEmbedding =
        List<double>.from(embedding);

        _isCapturing = false;
      });

      debugPrint(
        ' Showing captured photo preview',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' Capture error: $e',
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

      await _restartCameraStream();

      if (mounted &&
          !_isDisposed) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // RETAKE PHOTO

  Future<void> _retakePhoto() async {
    if (_isCapturing ||
        _isDisposed) {
      return;
    }

    debugPrint(
      ' Retaking face photo...',
    );

    // DELETE OLD TEMP PHOTO

    final oldPhoto =
        _capturedPhoto;

    if (oldPhoto != null) {
      try {
        if (await oldPhoto.exists()) {
          await oldPhoto.delete();

          debugPrint(
            ' Old temporary photo deleted',
          );
        }
      } catch (e) {
        debugPrint(
          ' Could not delete old photo: $e',
        );
      }
    }

    // CLEAR PREVIEW
    if (mounted &&
        !_isDisposed) {
      setState(() {
        _capturedPhoto = null;
        _capturedEmbedding = null;

        _currentFace = null;
        _currentEmbedding = null;

        _faceDetected = false;

        _lastEmbeddingTime = null;
      });
    }

    // START CAMERA STREAM AGAIN

    await _restartCameraStream();
  }

  // RESTART CAMERA STREAM

  Future<void> _restartCameraStream() async {
    if (_cameraController == null ||
        _isDisposed) {
      return;
    }

    try {
      if (!_cameraController!
          .value
          .isInitialized) {
        return;
      }

      if (!_cameraController!
          .value
          .isStreamingImages) {
        await _cameraController!
            .startImageStream(
          _processCameraImage,
        );

        debugPrint(
          ' Camera stream restarted',
        );
      }
    } catch (e) {
      debugPrint(
        ' Failed to restart camera stream: $e',
      );

      if (mounted &&
          !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Could not restart camera: $e',
            ),
          ),
        );
      }
    }
  }

  // USE THIS PHOTO

  void _useThisPhoto() {
    if (_isCapturing ||
        _capturedPhoto == null ||
        _capturedEmbedding == null ||
        _capturedEmbedding!.length != 192) {
      return;
    }

    debugPrint(
      ' Using captured face photo',
    );

    final File photo =
    _capturedPhoto!;

    final List<double> embedding =
    List<double>.from(
      _capturedEmbedding!,
    );

    Navigator.pop(
      context,
      {
        'image': photo,
        'embedding': embedding,
      },
    );
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

  // BUILD

  @override
  Widget build(
      BuildContext context,
      ) {
    final bool readyToCapture =
        _isCameraInitialized &&
            _faceDetected &&
            _currentEmbedding != null &&
            _currentEmbedding!.length == 192 &&
            !_isCapturing &&
            !_isPreviewingPhoto;

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
                    onPressed:
                    _isCapturing
                        ? null
                        : () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      _isPreviewingPhoto
                          ? 'Review Face Photo'
                          : 'Live Face Registration',
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
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

            // MAIN AREA

            Expanded(
              child: _isPreviewingPhoto
                  ? _buildPhotoPreview()
                  : _buildCameraPreview(),
            ),

            // BOTTOM AREA

            _isPreviewingPhoto
                ? _buildPreviewControls()
                : _buildCameraControls(
              readyToCapture,
            ),
          ],
        ),
      ),
    );
  }

  // CAMERA PREVIEW

  Widget _buildCameraPreview() {
    return _isCameraInitialized &&
        _cameraController != null
        ? CameraPreview(
      _cameraController!,
    )
        : const Center(
      child:
      CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  // PHOTO PREVIEW

  Widget _buildPhotoPreview() {
    final photo =
        _capturedPhoto;

    if (photo == null) {
      return const Center(
        child: Text(
          'No photo available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),

          const Text(
            'Is this photo clear?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Make sure your face is clearly visible.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              clipBehavior:
              Clip.antiAlias,
              child: Image.file(
                photo,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  // CAMERA CONTROLS

  Widget _buildCameraControls(
      bool readyToCapture,
      ) {
    return Column(
      children: [
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
                : _currentEmbedding ==
                null
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
                color:
                Colors.white,
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
    );
  }

  // PREVIEW CONTROLS

  Widget _buildPreviewControls() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20,
      ),
      color: Colors.black,
      child: Column(
        children: [
          // RETAKE

          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed:
              _isCapturing
                  ? null
                  : _retakePhoto,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Retake Photo',
                style:
                TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Colors.white,
                side:
                const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // USE PHOTO

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed:
              _isCapturing
                  ? null
                  : _useThisPhoto,
              icon: const Icon(
                Icons.check_circle,
              ),
              label: const Text(
                'Use This Photo',
                style:
                TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.deepPurple,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}