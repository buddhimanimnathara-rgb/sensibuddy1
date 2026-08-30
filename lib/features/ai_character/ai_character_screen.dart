import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/models/ai_chat_message.dart';
import '../../core/models/ai_interaction_analysis.dart';
import '../../core/models/ai_model_service.dart';
import '../../core/models/assessment_model.dart';
import '../../core/models/content_permission_model.dart';
import '../../core/services/child_content_request_service.dart';
import '../../core/services/child_interest_firestore_service.dart';
import '../../core/services/child_interest_service.dart';
import '../../core/services/content_permission_firestore_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/ai_character_model.dart';
import '../../core/models/child_model.dart';
import '../../core/services/face_embedding_service.dart';

import 'dart:async';
import '../../core/services/person_recognition_service.dart';
import '../../core/models/ai_conversation_context.dart';

import '../../core/services/ai_character_service.dart';
import '../../core/services/audio_recording_service.dart';
import '../../core/services/elevenlabs_tts_service.dart';
import '../../core/services/unified_speech_service.dart';

import '../../screens/kidstube_screen.dart';
import 'character_selection_screen.dart';
import 'widgets/ai_character_avater.dart';

class AICharacterScreen extends StatefulWidget {
  final ChildModel child;
  final String emotion;

  const AICharacterScreen({
    super.key,
    required this.child,
    this.emotion = 'neutral',

  });

  @override
  State<AICharacterScreen> createState() =>
      _AICharacterScreenState();
}

class _AICharacterScreenState
    extends State<AICharacterScreen> {



// SERVICES

  final AICharacterService _aiService =
  AICharacterService();

  final ElevenLabsTtsService _ttsService =
  ElevenLabsTtsService();

  final AIModelService _aiModelService =
  AIModelService();

  final AudioRecordingService _audioRecordingService =
  AudioRecordingService();

  final FaceEmbeddingService _faceEmbeddingService =
  FaceEmbeddingService();

  final FirestoreService _firestoreService =
  FirestoreService();

  final ChildInterestService _childInterestService =
  ChildInterestService();

  final ChildInterestFirestoreService _childInterestFirestoreService =
  ChildInterestFirestoreService();

  final PersonRecognitionService _personRecognitionService =
      PersonRecognitionService.instance;

  final UnifiedSpeechService unifiedSpeechService =
      UnifiedSpeechService.instance;

  final ChildContentRequestService _childContentRequestService =
  ChildContentRequestService();

  final ContentPermissionFirestoreService
  _contentPermissionFirestoreService =
  ContentPermissionFirestoreService();


// AI CONVERSATION MEMORY


  final List<AIChatMessage> _conversationMemory =
  [];


// AI CONVERSATION CONTEXT

  AIConversationContext? _conversationContext;


// CONTROLLERS


  final TextEditingController _messageController =
  TextEditingController();

  CameraController? _cameraController;

  late final FaceDetector _faceDetector;


// CAMERA / FACE STATE

  bool _isFaceDetected = false;

  bool _isCameraLoading = true;

  bool _isCameraInitialized = false;

  String _faceStatus = '';

  DateTime? _lastRecognitionTime;

// Prevent multiple camera image processing
  bool _isProcessing = false;

// Prevent multiple person recognition processes
  bool _isRecognizingPerson = false;

  static const Duration _recognitionInterval =
  Duration(seconds: 2);


// RECOGNIZED PERSON

  RecognizedPerson? _recognizedPerson;

  String? _recognizedName;

  String? _recognizedType;


// MICROPHONE / VOICE STATE

  bool _isListening = false;

  bool _isTranscribing = false;


// AI MESSAGE STATE

  bool _isSendingMessage = false;


// CHARACTER

  late AICharacterModel _character;

  late String _selectedCharacter;


// CHAT

  String _userMessage = '';

  String _aiMessage = '';


  // INIT


  @override
  void initState() {
    super.initState();

    _selectedCharacter =
        widget.child.selectedCharacter ?? 'bunny';

    _createCharacter();

    _conversationMemory.clear();

    _createGuestConversationContext();

    _aiMessage = _aiService.getGreeting(
      widget.child.language,
    );

    _character = _character.copyWith(
      emotion: _normalizeEmotion(widget.emotion),
    );

    _faceStatus =
        _getLookingForYouText();


    // FACE DETECTOR

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // INITIALIZE CAMERA

    _initializeCamera();
  }


  // LANGUAGE

  String get _language {
    final language = widget.child.language
        .toString()
        .toLowerCase()
        .trim();

    switch (language) {
      case 'si':
      case 'sinhala':
      case 'සිංහල':
        return 'si';

      case 'ta':
      case 'tamil':
      case 'தமிழ்':
        return 'ta';

      case 'en':
      case 'english':
      default:
        return 'en';
    }
  }

  bool get _isSinhala =>
      _language == 'si';

  bool get _isTamil =>
      _language == 'ta';

  bool get _isEnglish =>
      _language == 'en';

  // CREATE CHARACTER

  void _createCharacter() {
    _character = _aiService.createCharacter(
      language: widget.child.language,
      characterId: _selectedCharacter,
    );
  }


// CREATE GUEST AI CONVERSATION CONTEXT

  void _createGuestConversationContext() {
    _conversationContext =
        AIConversationContext(
          mode: AIConversationMode.guest,
          child: widget.child,
          guardian: null,
          assessment: null,
          character: _character,

          emotion: _normalizeEmotion(widget.emotion),
          // Guest identity is unknown.
          personName: null,
        );

    debugPrint(
      ' GUEST AI CONVERSATION CONTEXT CREATED',
    );
  }

  String _normalizeEmotion(String emotion) {
    switch (emotion.toLowerCase().trim()) {
      case 'natural':
      case 'neutral':
        return 'neutral';

      case 'angry':
      case 'anger':
        return 'angry';

      case 'fear':
        return 'fear';

      case 'joy':
        return 'joy';

      case 'sadness':
        return 'sadness';

      case 'surprise':
        return 'surprise';

      default:
        return 'neutral';
    }
  }


  Future<void> _changeFriend() async {
    try {
      await _ttsService.stop();

      if (!mounted) return;

      final selectedCharacter =
      await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterSelectionScreen(
            child: widget.child,
          ),
        ),
      );

      if (!mounted || selectedCharacter == null) {
        return;
      }

      setState(() {
        _selectedCharacter = selectedCharacter;

        _character = AICharacterModel.defaultCharacter(
          language: widget.child.language,
          characterId: selectedCharacter,
        ).copyWith(
          isSpeaking: false,
        );

        // UPDATE AI CONVERSATION CONTEXT
        if (_conversationContext != null) {
          final currentContext = _conversationContext!;

          _conversationContext = AIConversationContext(
            mode: currentContext.mode,
            child: currentContext.child,
            guardian: currentContext.guardian,
            assessment: currentContext.assessment,
            emotion: currentContext.emotion,
            personName: currentContext.personName,
            character: _character,
          );
        }
      });

      debugPrint(
        ' CHARACTER CHANGED: ${_character.characterId}',
      );

      debugPrint(
        ' CHARACTER NAME: ${_character.name}',
      );

      debugPrint(
        ' CHARACTER PERSONALITY: ${_character.personality}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' CHANGE CHARACTER ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }



// GET LARGEST FACE

  Face _getLargestFace(
      List<Face> faces,
      ) {
    Face largestFace =
        faces.first;

    double largestArea =
        largestFace.boundingBox.width *
            largestFace.boundingBox.height;

    for (final face in faces) {
      final area =
          face.boundingBox.width *
              face.boundingBox.height;

      if (area > largestArea) {
        largestFace = face;

        largestArea = area;
      }
    }

    return largestFace;
  }


// CAMERA INITIALIZATION

  Future<void> _initializeCamera() async {
    try {
      if (mounted) {
        setState(() {
          _isCameraLoading = true;
          _isCameraInitialized = false;
        });
      }

      // GET AVAILABLE CAMERAS

      final cameras =
      await availableCameras();

      if (cameras.isEmpty) {
        throw Exception(
          'No camera available',
        );
      }

      // SELECT FRONT CAMERA

      final frontCamera =
      cameras.firstWhere(
            (camera) =>
        camera.lensDirection ==
            CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // CREATE CAMERA CONTROLLER

      _cameraController =
          CameraController(
            frontCamera,
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup:
            ImageFormatGroup.nv21,
          );

      // INITIALIZE CAMERA

      await _cameraController!
          .initialize();

      if (!mounted) {
        await _cameraController?.dispose();
        return;
      }

      // START IMAGE STREAM

      await _cameraController!
          .startImageStream(
        _processCameraImage,
      );

      if (!mounted) {
        return;
      }

      // UPDATE STATE

      setState(() {
        _isCameraInitialized = true;
        _isCameraLoading = false;
      });

      debugPrint(
        ' AI Camera started',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' Camera initialization error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isCameraLoading = false;
        });
      }
    }
  }

// PERSON RECOGNITION

  Future<void> _recognizePerson(
      List<double> embedding,
      ) async {
    if (_isRecognizingPerson) {
      return;
    }

    _isRecognizingPerson = true;

    try {
      // IDENTIFY PERSON

      final person =
      await personRecognitionService
          .identifyPerson(
        embedding,
      );

      if (!mounted) {
        return;
      }

      // PERSON NOT RECOGNIZED

      if (person == null) {
        setState(() {
          _recognizedPerson = null;
          _recognizedName = null;
          _recognizedType = null;
        });

        debugPrint(
          ' Person not recognized',
        );

        return;
      }

      // SAVE RECOGNIZED PERSON

      setState(() {
        _recognizedPerson = person;
        _recognizedType = person.type;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        ' PERSON RECOGNIZED',
      );
      debugPrint(
        'Type: ${person.type}',
      );
      debugPrint(
        'ID: ${person.id}',
      );
      debugPrint(
        'Similarity: ${person.similarity}',
      );
      debugPrint(
        '========================================',
      );

      // BUILD AI CONVERSATION CONTEXT

      await _buildConversationContext(
        person,
      );

    } catch (e, stackTrace) {
      debugPrint(
        ' Recognition error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      _isRecognizingPerson = false;
    }
  }

// PROCESS CAMERA IMAGE

  Future<void> _processCameraImage(
      CameraImage image,
      ) async {

    // PREVENT MULTIPLE PROCESSING

    if (_isProcessing ||
        _isRecognizingPerson ||
        !mounted) {
      return;
    }

    _isProcessing = true;

    try {

      // CONVERT CAMERA IMAGE FOR ML KIT

      final inputImage =
      _inputImageFromCameraImage(
        image,
      );

      if (inputImage == null) {
        return;
      }

      // DETECT FACE

      final faces =
      await _faceDetector.processImage(
        inputImage,
      );

      final bool faceDetected =
          faces.isNotEmpty;


// NO FACE DETECTED

      if (!faceDetected) {
        if (mounted && _isFaceDetected) {
          setState(() {
            _isFaceDetected = false;
            _recognizedPerson = null;
            _recognizedName = null;
            _recognizedType = null;

            _faceStatus =
                _getLookingForYouText();
          });
        }

        // SWITCH BACK TO GUEST CONTEXT

        if (_conversationContext == null ||
            !_conversationContext!.isGuestMode) {
          _createGuestConversationContext();
        }

        return;
      }

      // GET LARGEST FACE

      final Face face =
      _getLargestFace(
        faces,
      );

      if (!mounted) {
        return;
      }

      // FACE DETECTED

      if (!_isFaceDetected) {
        setState(() {
          _isFaceDetected = true;

          _faceStatus =
              _getFaceDetectedText();
        });

        debugPrint(
          ' FACE DETECTED',
        );
      }

      // ALREADY RECOGNIZED

      if (_recognizedPerson != null) {
        return;
      }

      // RECOGNITION INTERVAL

      final now = DateTime.now();

      if (_lastRecognitionTime != null &&
          now
              .difference(
            _lastRecognitionTime!,
          )
              .compareTo(
            _recognitionInterval,
          ) <
              0) {
        return;
      }

      _lastRecognitionTime = now;

      // START RECOGNITION

      _isRecognizingPerson = true;

      debugPrint('');
      debugPrint(
        ' STARTING LIVE FACE RECOGNITION',
      );

      // GET CAMERA

      final camera =
          _cameraController?.description;

      if (camera == null) {
        debugPrint(
          ' CAMERA DESCRIPTION IS NULL',
        );

        return;
      }


      // GET CAMERA ROTATION

      final rotation =
      InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );

      if (rotation == null) {
        debugPrint(
          ' UNSUPPORTED CAMERA ROTATION',
        );

        return;
      }

      // GENERATE LIVE FACE EMBEDDING

      final embedding =
      await _faceEmbeddingService
          .generateEmbeddingFromCameraImage(
        image,
        face,
        rotation,
      );

      debugPrint(
        ' LIVE EMBEDDING LENGTH: '
            '${embedding.length}',
      );

      // VALIDATE EMBEDDING

      if (embedding.length != 192) {
        debugPrint(
          ' INVALID EMBEDDING LENGTH',
        );

        return;
      }

      // IDENTIFY PERSON

      final person =
      await _personRecognitionService
          .identifyPerson(
        embedding,
      );

      if (!mounted) {
        return;
      }


// PERSON NOT RECOGNIZED

      if (person == null) {
        debugPrint(
          ' PERSON NOT RECOGNIZED',
        );

        if (mounted) {
          setState(() {
            _recognizedPerson = null;
            _recognizedName = null;
            _recognizedType = null;

            _faceStatus =
                _getUnknownFaceText();
          });
        }

        // KEEP / RESTORE GUEST AI CONTEXT

        if (_conversationContext == null ||
            !_conversationContext!.isGuestMode) {
          _createGuestConversationContext();
        }

        debugPrint(
          ' GUEST AI CHAT REMAINS AVAILABLE',
        );

        return;
      }

      // PERSON RECOGNIZED

      debugPrint('');
      debugPrint(
        '================================',
      );

      debugPrint(
        ' PERSON RECOGNIZED',
      );

      debugPrint(
        'Type: ${person.type}',
      );

      debugPrint(
        'ID: ${person.id}',
      );

      debugPrint(
        'Similarity: ${person.similarity}',
      );

      debugPrint(
        '================================',
      );

      // UPDATE RECOGNIZED PERSON

      setState(() {
        _recognizedPerson = person;

        _recognizedType =
            person.type;

        _recognizedName =
            _getRecognizedPersonName(
              person,
            );

        _faceStatus =
            _getRecognitionStatusText(
              person,
            );
      });

      // BUILD AI CONVERSATION CONTEXT

      debugPrint(
        ' BUILDING AI CONTEXT...',
      );

      await _buildConversationContext(
        person,
      );

      if (!mounted) {
        return;
      }

      // CHECK AI CONTEXT

      final context =
          _conversationContext;

      if (context == null) {
        debugPrint(
          ' AI CONVERSATION CONTEXT NOT READY',
        );

        return;
      }

      debugPrint(
        ' AI CONVERSATION CONTEXT READY',
      );

      // CHILD RECOGNIZED

      if (person.isChild) {
        debugPrint(
          ' CHILD RECOGNIZED BY AI ASSISTANT',
        );

        await _handleChildRecognized(
          person,
        );

        return;
      }

      // GUARDIAN RECOGNIZED

      if (person.isGuardian) {
        debugPrint(
          ' GUARDIAN RECOGNIZED BY AI ASSISTANT',
        );

        await _handleGuardianRecognized(
          person,
        );

        return;
      }

      // UNKNOWN PERSON TYPE

      debugPrint(
        ' UNKNOWN PERSON TYPE: '
            '${person.type}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' LIVE FACE RECOGNITION ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      _isProcessing = false;
      _isRecognizingPerson = false;
    }
  }


// BUILD AI CONVERSATION CONTEXT

  Future<void> _buildConversationContext(
      RecognizedPerson person,
      ) async {
    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        ' BUILDING AI CONVERSATION CONTEXT',
      );
      debugPrint(
        '========================================',
      );

      // PERSON IS CHILD

      if (person.isChild) {
        debugPrint(
          ' Loading child data...',
        );

        final child =
        await _firestoreService.getChild(
          person.id,
        );

        if (child == null) {
          debugPrint(
            ' Child data not found',
          );

          return;
        }

        // GET LATEST ASSESSMENT

        final assessmentData =
        await _firestoreService
            .getLatestAssessment(
          child.id,
        );

        AssessmentModel? assessment;

        if (assessmentData != null) {
          assessment =
              AssessmentModel.fromMap(
                assessmentData,
              );

          debugPrint(
            ' Assessment loaded',
          );
        } else {
          debugPrint(
            ' No assessment found',
          );
        }

        // CREATE CHILD AI CONTEXT

        final context =
        AIConversationContext(
          mode: AIConversationMode.child,
          child: child,
          assessment: assessment,
          emotion: widget.emotion,
          character: _character,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _conversationContext = context;
        });

        debugPrint(
          '========================================',
        );
        debugPrint(
          ' CHILD AI CONTEXT READY',
        );
        debugPrint(
          'Child: ${child.name}',
        );
        debugPrint(
          'Language: ${child.language}',
        );
        debugPrint(
          'Emotion: ${widget.emotion}',
        );
        debugPrint(
          '========================================',
        );

        return;
      }

      // PERSON IS GUARDIAN

      if (person.isGuardian) {
        debugPrint(
          ' Loading guardian data...',
        );

        final guardian =
        await _firestoreService.getGuardian(
          person.id,
        );

        if (guardian == null) {
          debugPrint(
            ' Guardian data not found',
          );

          return;
        }

        // GET RELATED CHILD

        final child =
        await _firestoreService.getChild(
          guardian.childId,
        );

        if (child == null) {
          debugPrint(
            ' Child data not found',
          );

          return;
        }

        // GET CHILD'S LATEST ASSESSMENT

        final assessmentData =
        await _firestoreService
            .getLatestAssessment(
          child.id,
        );

        AssessmentModel? assessment;

        if (assessmentData != null) {
          assessment =
              AssessmentModel.fromMap(
                assessmentData,
              );

          debugPrint(
            ' Child assessment loaded',
          );
        } else {
          debugPrint(
            ' No assessment found',
          );
        }

        // CREATE GUARDIAN AI CONTEXT

        final context =
        AIConversationContext(
          mode: AIConversationMode.guardian,
          child: child,
          guardian: guardian,
          assessment: assessment,
          emotion: widget.emotion,
          character: _character,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _conversationContext = context;
        });

        debugPrint(
          '========================================',
        );
        debugPrint(
          ' GUARDIAN AI CONTEXT READY',
        );
        debugPrint(
          'Guardian: ${guardian.name}',
        );
        debugPrint(
          'Child: ${child.name}',
        );
        debugPrint(
          'Language: ${child.language}',
        );
        debugPrint(
          'Emotion: ${widget.emotion}',
        );
        debugPrint(
          '========================================',
        );

        return;
      }

      // UNKNOWN TYPE

      debugPrint(
        ' Unknown recognized person type: '
            '${person.type}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' BUILD CONTEXT ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }


// CHILD RECOGNIZED

  Future<void> _handleChildRecognized(
      RecognizedPerson person,
      ) async {
    if (!mounted) {
      return;
    }

    // CHECK AI CONTEXT

    final context = _conversationContext;

    if (context == null || !context.isChildMode) {
      debugPrint(
        ' CHILD AI CONTEXT NOT READY',
      );

      return;
    }

    debugPrint(
      ' STARTING AI ASSISTANT FOR CHILD',
    );

    // GET CHILD NAME FROM CONTEXT

    final name = context.child.name;

    final greeting =
    _getPersonalGreeting(
      name,
    );

    setState(() {
      _aiMessage = greeting;
    });

    // SPEAK GREETING

    try {
      if (mounted) {
        setState(() {
          _character =
              _character.copyWith(
                isSpeaking: true,
              );
        });
      }

      debugPrint(
        ' AI SPEAKING TO CHILD: $name',
      );

      await _ttsService.speak(
        greeting,
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' CHILD TTS ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() {
          _character =
              _character.copyWith(
                isSpeaking: false,
              );
        });
      }
    }
  }

// GUARDIAN RECOGNIZED

  Future<void> _handleGuardianRecognized(
      RecognizedPerson person,
      ) async {
    if (!mounted) {
      return;
    }

    // CHECK AI CONTEXT

    final context = _conversationContext;

    if (context == null) {
      debugPrint(
        ' GUARDIAN AI CONTEXT NOT READY',
      );

      return;
    }

    if (!context.isGuardianMode) {
      debugPrint(
        ' CURRENT AI CONTEXT IS NOT GUARDIAN MODE',
      );

      return;
    }

    // GET GUARDIAN DATA

    final guardian = context.guardian;

    if (guardian == null) {
      debugPrint(
        ' GUARDIAN DATA NOT AVAILABLE',
      );

      return;
    }

    debugPrint(
      ' GUARDIAN RECOGNIZED BY AI ASSISTANT',
    );

    debugPrint(
      'Guardian: ${guardian.name}',
    );

    debugPrint(
      'Child: ${context.child.name}',
    );

    // GET DATA FROM AI CONTEXT

    final guardianName =
        guardian.name;

    final childName =
        context.child.name;

    // CREATE PERSONALIZED MESSAGE

    final message =
    _getGuardianWelcomeMessage(
      guardianName: guardianName,
      childName: childName,
    );

    if (!mounted) {
      return;
    }

    // UPDATE AI MESSAGE

    setState(() {
      _aiMessage = message;

      _character =
          _character.copyWith(
            isSpeaking: true,
          );
    });

    // SPEAK MESSAGE

    try {
      debugPrint(
        ' AI SPEAKING TO GUARDIAN: $guardianName',
      );

      debugPrint(
        ' MESSAGE: $message',
      );

      await _ttsService.speak(
        message,
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' GUARDIAN TTS ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() {
          _character =
              _character.copyWith(
                isSpeaking: false,
              );
        });
      }
    }
  }


// GUARDIAN WELCOME MESSAGE

  String _getGuardianWelcomeMessage({
    required String guardianName,
    required String childName,
  }) {
    if (_isSinhala) {
      return 'ආයුබෝවන් $guardianName. 😊 '
          '$childName සමඟ කතා කිරීමට සහ උදව් කිරීමට මම සූදානම්.';
    }

    if (_isTamil) {
      return 'வணக்கம் $guardianName. 😊 '
          '$childName உடன் பேசவும் உதவவும் நான் தயாராக இருக்கிறேன்.';
    }

    return 'Hello $guardianName. 😊 '
        'I am ready to help and talk about $childName.';
  }




// GET RECOGNIZED PERSON NAME

  String _getRecognizedPersonName(
      RecognizedPerson person,
      ) {
    final Map<String, dynamic> data =
        person.faceData;


    // DIRECT NAME

    final directName =
    data['name']
        ?.toString()
        .trim();

    if (directName != null &&
        directName.isNotEmpty) {
      return directName;
    }

    // CHILD NAME

    final childName =
    data['childName']
        ?.toString()
        .trim();

    if (childName != null &&
        childName.isNotEmpty) {
      return childName;
    }

    // GUARDIAN NAME

    final guardianName =
    data['guardianName']
        ?.toString()
        .trim();

    if (guardianName != null &&
        guardianName.isNotEmpty) {
      return guardianName;
    }

    // NESTED CHILD DATA


    final childData =
    data['child'];

    if (childData is Map) {
      final name =
      childData['name']
          ?.toString()
          .trim();

      if (name != null &&
          name.isNotEmpty) {
        return name;
      }
    }

    // NESTED GUARDIAN DATA

    final guardianData =
    data['guardian'];

    if (guardianData is Map) {
      final name =
      guardianData['name']
          ?.toString()
          .trim();

      if (name != null &&
          name.isNotEmpty) {
        return name;
      }
    }

    // FALLBACK NAME

    if (person.isChild) {
      if (_isSinhala) {
        return 'යාලුවා';
      }

      if (_isTamil) {
        return 'நண்பா';
      }

      return 'Friend';
    }

    if (person.isGuardian) {
      if (_isSinhala) {
        return 'භාරකරු';
      }

      if (_isTamil) {
        return 'பாதுகாவலர்';
      }

      return 'Guardian';
    }

    // ==========================================================
    // UNKNOWN PERSON
    // ==========================================================

    if (_isSinhala) {
      return 'හඳුනා නොගත් පුද්ගලයා';
    }

    if (_isTamil) {
      return 'அடையாளம் தெரியாத நபர்';
    }

    return 'Unknown person';
  }

// PERSONAL GREETING


  String _getPersonalGreeting(
      String name,
      ) {
    if (_isSinhala) {
      return 'හායි $name! 😊 ඔයාව දැකලා මට ගොඩක් සතුටුයි. අද කොහොමද? මම ඔයාගේ AI යාලුවා. අපි ටිකක් කතා කරමුද?';
    }

    if (_isTamil) {
      return 'வணக்கம் $name! 😊 உங்களைப் பார்த்ததில் எனக்கு மிகவும் மகிழ்ச்சி. இன்று எப்படி இருக்கிறீர்கள்? நான் உங்கள் AI நண்பன். நாம் கொஞ்சம் பேசலாமா?';
    }

    return 'Hi $name! 😊 I am so happy to see you. How are you feeling today? I am your AI friend. Would you like to talk with me?';
  }



// GUARDIAN RECOGNIZED TEXT

  String _getGuardianRecognizedText(
      String name,
      ) {
    if (_isSinhala) {
      return 'ආයුබෝවන් $name. 😊 ඔබව සාර්ථකව හඳුනාගත්තා.';
    }

    if (_isTamil) {
      return 'வணக்கம் $name. 😊 உங்களை வெற்றிகரமாக அடையாளம் கண்டுகொண்டேன்.';
    }

    return 'Hello $name. 😊 I successfully recognized you.';
  }



// UNKNOWN FACE TEXT


  String _getUnknownFaceText() {
    if (_isSinhala) {
      return 'ඔයාව හඳුනාගැනීමට උත්සාහ කරමින්...';
    }

    if (_isTamil) {
      return 'உங்களை அடையாளம் காண முயற்சிக்கிறேன்...';
    }

    return 'Trying to recognize you...';
  }


// RECOGNITION STATUS

  String _getRecognitionStatusText(
      RecognizedPerson person,
      ) {
    if (person.isChild) {
      if (_isSinhala) {
        return '😊 දරුවා හඳුනාගත්තා!';
      }

      if (_isTamil) {
        return '😊 குழந்தை அடையாளம் காணப்பட்டது!';
      }

      return '😊 Child recognized!';
    }

    if (person.isGuardian) {
      if (_isSinhala) {
        return ' Guardian හඳුනාගත්තා!';
      }

      if (_isTamil) {
        return ' பாதுகாவலர் அடையாளம் காணப்பட்டது!';
      }

      return ' Guardian recognized!';
    }

    return _getUnknownFaceText();
  }


// CONVERT CAMERA IMAGE FOR ML KIT



  InputImage? _inputImageFromCameraImage(
      CameraImage image,
      ) {
    final camera =
        _cameraController?.description;

    if (camera == null) {
      return null;
    }

    final rotation =
    InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );

    if (rotation == null) {
      return null;
    }

    final format =
    InputImageFormatValue.fromRawValue(
      image.format.raw,
    );

    if (format == null) {
      return null;
    }

    if (image.planes.isEmpty) {
      return null;
    }

    final plane =
        image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: format,
        bytesPerRow:
        plane.bytesPerRow,
      ),
    );
  }

// START LISTENING

  Future<void> _startListening() async {

    // PREVENT MULTIPLE LISTENING / SENDING


    if (_isListening ||
        _isTranscribing ||
        _isSendingMessage) {
      debugPrint(
        ' Speech service is already busy',
      );

      return;
    }

    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        ' START LISTENING',
      );
      debugPrint(
        ' Language: $_language',
      );
      debugPrint(
        '========================================',
      );


      // ENGLISH


      if (_isEnglish) {
        if (mounted) {
          setState(() {
            _isListening = true;
            _userMessage = '';
          });
        }

        final started =
        await unifiedSpeechService.startListening(
          language: _language,
          onResult: (
              String text,
              bool isFinal,
              ) async {
            if (!mounted) {
              return;
            }


            // UPDATE LIVE TRANSCRIPT

            setState(() {
              _userMessage = text;
            });

            debugPrint(
              ' USER SAID: $text',
            );

            debugPrint(
              ' IS FINAL: $isFinal',
            );


            // WAIT FOR FINAL RESULT


            if (!isFinal) {
              return;
            }

            final message =
            text.trim();

            if (message.isEmpty) {
              debugPrint(
                ' Empty speech result',
              );

              return;
            }


            // PREVENT DUPLICATE AI REQUESTS


            if (_isSendingMessage) {
              debugPrint(
                ' AI MESSAGE IS ALREADY BEING PROCESSED',
              );

              return;
            }

            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }

            debugPrint(
              ' SENDING VOICE MESSAGE TO AI: $message',
            );


            // SEND TO AI


            await _handleUserMessage(
              message,
            );
          },
        );


        // FAILED TO START

        if (!started) {
          debugPrint(
            ' FAILED TO START ENGLISH SPEECH RECOGNITION',
          );

          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }

        return;
      }


      // SINHALA / TAMIL

      if (mounted) {
        setState(() {
          _isListening = true;
          _userMessage = '';
        });
      }

      debugPrint(
        '🎙️ STARTING AUDIO RECORDING',
      );

      final started =
      await _audioRecordingService
          .startRecording();


      // FAILED TO START RECORDING


      if (!started) {
        debugPrint(
          ' FAILED TO START AUDIO RECORDING',
        );

        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }

        return;
      }

      debugPrint(
        ' AUDIO RECORDING STARTED',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' START LISTENING ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _isListening = false;
          _isTranscribing = false;
        });
      }
    }
  }


// STOP LISTENING

  Future<void> _stopListening() async {
    // CHECK LISTENING STATE

    if (!_isListening) {
      debugPrint(
        ' NOT CURRENTLY LISTENING',
      );

      return;
    }

    // Prevent duplicate processing
    if (_isTranscribing ||
        _isSendingMessage) {
      debugPrint(
        ' SPEECH SERVICE IS BUSY',
      );

      return;
    }

    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        ' STOP LISTENING',
      );
      debugPrint(
        ' LANGUAGE: $_language',
      );
      debugPrint(
        '========================================',
      );


      // ENGLISH

      if (_isEnglish) {
        debugPrint(
          ' STOPPING ENGLISH SPEECH RECOGNITION',
        );

        await unifiedSpeechService.stopListening();

        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }

        debugPrint(
          ' ENGLISH LISTENING STOPPED',
        );

        return;
      }

      // SINHALA / TAMIL

      if (mounted) {
        setState(() {
          _isListening = false;
          _isTranscribing = true;
        });
      }

      debugPrint(
        ' STOPPING AUDIO RECORDING...',
      );

      // STOP RECORDING


      final audioPath =
      await _audioRecordingService
          .stopRecording();

      if (audioPath == null ||
          audioPath.trim().isEmpty) {
        throw Exception(
          'Audio recording was not found',
        );
      }

      debugPrint(
        ' AUDIO FILE: $audioPath',
      );


      // TRANSCRIBE AUDIO


      debugPrint(
        ' STARTING SPEECH TRANSCRIPTION...',
      );

      final text =
      await unifiedSpeechService.transcribe(
        audioPath: audioPath,
        language: _language,
      );

      if (!mounted) {
        return;
      }

      final message =
      text.trim();

      setState(() {
        _userMessage = message;
        _isTranscribing = false;
      });

      debugPrint(
        ' TRANSCRIBED TEXT: $message',
      );

      // VALIDATE MESSAGE

      if (message.isEmpty) {
        debugPrint(
          ' TRANSCRIPTION RETURNED EMPTY TEXT',
        );

        return;
      }

      // PREVENT DUPLICATE SEND

      if (_isSendingMessage) {
        debugPrint(
          ' AI IS ALREADY PROCESSING A MESSAGE',
        );

        return;
      }

      // SEND MESSAGE TO AI

      debugPrint(
        ' SENDING TRANSCRIBED MESSAGE TO AI: '
            '$message',
      );

      await _handleUserMessage(
        message,
      );

    } catch (e, stackTrace) {
      debugPrint(
        ' STOP LISTENING ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      // ALWAYS RESET VOICE STATES

      if (mounted) {
        setState(() {
          _isListening = false;
          _isTranscribing = false;
        });
      }
    }
  }

// CANCEL LISTENING

  Future<void> _cancelListening() async {
    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        ' CANCEL LISTENING',
      );
      debugPrint(
        ' LANGUAGE: $_language',
      );
      debugPrint(
        '========================================',
      );

      // ENGLISH

      if (_isEnglish) {
        debugPrint(
          ' CANCELLING ENGLISH SPEECH RECOGNITION...',
        );

        await unifiedSpeechService.cancelListening();

        debugPrint(
          ' ENGLISH SPEECH RECOGNITION CANCELLED',
        );
      }

      // SINHALA / TAMIL

      else {
        debugPrint(
          '️ CANCELLING AUDIO RECORDING...',
        );

        await _audioRecordingService.cancelRecording();

        debugPrint(
          ' AUDIO RECORDING CANCELLED',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        ' CANCEL LISTENING ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      // ALWAYS RESET VOICE STATES

      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _isTranscribing = false;
      });

      debugPrint(
        ' LISTENING STATES RESET',
      );
    }
  }

  Future<bool> _showParentPinDialog() async {
    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Parent Permission Required',
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the 4-digit Parent PIN '
                        'to allow this content.',
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    autofocus: true,

                    decoration: InputDecoration(
                      labelText: 'Parent PIN',
                      errorText: errorMessage,
                      border: const OutlineInputBorder(),
                    ),

                    onChanged: (value) {
                      if (errorMessage != null) {
                        setDialogState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                ],
              ),

              actions: [

                // CANCEL


                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(dialogContext).pop(
                      false,
                    );
                  },

                  child: const Text(
                    'Cancel',
                  ),
                ),


                // VERIFY PIN


                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    final pin =
                    pinController.text.trim();


                    // VALIDATE PIN

                    if (pin.length != 4 ||
                        int.tryParse(pin) == null) {
                      setDialogState(() {
                        errorMessage =
                        'Enter a valid 4-digit PIN.';
                      });

                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    try {
                      // GET AI CONVERSATION CONTEXT

                      final aiContext =
                          _conversationContext;

                      if (aiContext == null) {
                        setDialogState(() {
                          errorMessage =
                          'Guardian information not found.';
                          isLoading = false;
                        });

                        return;
                      }


                      // GET GUARDIAN


                      final guardian =
                          aiContext.guardian;

                      if (guardian == null) {
                        setDialogState(() {
                          errorMessage =
                          'Guardian information not found.';
                          isLoading = false;
                        });

                        return;
                      }

                      // GET SAVED PARENT PIN

                      final doc =
                      await firestoreService
                          .getParentPin(
                        guardian.id,
                      );

                      if (doc == null) {
                        setDialogState(() {
                          errorMessage =
                          'Parent PIN not found.';
                          isLoading = false;
                        });

                        return;
                      }

                      // VERIFY PIN

                      final savedPin =
                      doc['pin']?.toString();

                      if (savedPin == null ||
                          savedPin.isEmpty) {
                        setDialogState(() {
                          errorMessage =
                          'Parent PIN not found.';
                          isLoading = false;
                        });

                        return;
                      }

                      if (savedPin == pin) {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext)
                              .pop(true);
                        }

                        return;
                      }

                      // INCORRECT PIN

                      pinController.clear();

                      setDialogState(() {
                        errorMessage =
                        'Incorrect PIN. Try again.';
                        isLoading = false;
                      });
                    } catch (e, stackTrace) {
                      debugPrint(
                        ' PIN VERIFICATION ERROR: $e',
                      );

                      debugPrintStack(
                        stackTrace: stackTrace,
                      );

                      setDialogState(() {
                        errorMessage =
                        'PIN verification failed.';
                        isLoading = false;
                      });
                    }
                  },

                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Verify',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    pinController.dispose();

    return result ?? false;
  }

  Future<void> _openKidsTube({
    required String topic,
  }) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KidsTubeScreen(
          childId: widget.child.id,
          topic: topic,
        ),
      ),
    );
  }


// HANDLE USER MESSAGE

  Future<void> _handleUserMessage(
      String message,
      ) async
  {
    final cleanMessage = message.trim();

    // VALIDATE MESSAGE

    if (cleanMessage.isEmpty) {
      debugPrint(
        ' EMPTY MESSAGE - IGNORING',
      );

      return;
    }

    // PREVENT MULTIPLE REQUESTS

    if (_isSendingMessage) {
      debugPrint(
        ' MESSAGE ALREADY BEING PROCESSED',
      );

      return;
    }


// ENSURE AI CONTEXT

    if (_conversationContext == null) {
      debugPrint(
        ' AI CONTEXT WAS NULL - CREATING GUEST CONTEXT',
      );

      _createGuestConversationContext();
    }

    final aiContext = _conversationContext!;

    if (aiContext == null) {
      debugPrint(
        ' FAILED TO CREATE AI CONTEXT',
      );

      return;
    }

    // START MESSAGE PROCESSING

    if (mounted) {
      setState(() {
        _isSendingMessage = true;
        _userMessage = cleanMessage;
      });
    }

    try {
      debugPrint('');
      debugPrint(
        '==========================================',
      );

      debugPrint(
        ' USER MESSAGE RECEIVED',
      );

      debugPrint(
        ' MESSAGE: $cleanMessage',
      );

      debugPrint(
        ' LANGUAGE: $_language',
      );

      debugPrint(
        ' AI MODE: ${aiContext.mode}',
      );

      debugPrint(
        '==========================================',
      );

      // USE EMOTION FROM EMOTION SCAN / CURRENT AI CONTEXT
      final emotion = _normalizeEmotion(
        aiContext.emotion,
      );

      debugPrint(
        '😊 CURRENT EMOTION FROM CONTEXT: $emotion',
      );



      // UPDATE CHARACTER EMOTION FIRST

      if (mounted) {
        setState(() {
          _character = _character.copyWith(
            emotion: emotion,
          );
        });
      } else {
        _character = _character.copyWith(
          emotion: emotion,
        );
      }

      // UPDATE AI CONVERSATION CONTEXT

      final oldContext = _conversationContext!;

      _conversationContext = AIConversationContext(
        mode: oldContext.mode,
        child: oldContext.child,
        guardian: oldContext.guardian,
        assessment: oldContext.assessment,
        emotion: emotion,
        personName: oldContext.personName,
        character: _character,
      );

      final aicontext = _conversationContext!;

      debugPrint(
        ' CHARACTER: ${aicontext.character.name}',
      );

      debugPrint(
        ' CHARACTER ID: ${aicontext.character.characterId}',
      );

      debugPrint(
        ' CHARACTER EMOTION: ${aicontext.character.emotion}',
      );

      debugPrint(
        ' AI MODE: ${aicontext.mode}',
      );



      // CHILD INTEREST DETECTION

      if (aicontext.isChildMode) {
        final detectedInterest =
        _childInterestService.detectInterest(
          childId: widget.child.id,
          message: cleanMessage,
        );

        if (detectedInterest != null) {
          debugPrint(
            ' INTEREST DETECTED: '
                '${detectedInterest.interest}',
          );

          try {
            await _childInterestFirestoreService
                .saveOrUpdateInterest(
              detectedInterest,
            );

            debugPrint(
              ' CHILD INTEREST SAVED',
            );
          } catch (e) {
            debugPrint(
              ' INTEREST SAVE ERROR: $e',
            );
          }
        }
      }





// CONTENT REQUEST DETECTION

      final contentRequest =
      _childContentRequestService.detectRequest(
        message: cleanMessage,
      );

      if (contentRequest != null) {
        debugPrint(
          ' CONTENT REQUEST DETECTED',
        );

        debugPrint(
          ' TOPIC: ${contentRequest.topic}',
        );

        debugPrint(
          ' KNOWN TOPIC: '
              '${contentRequest.isKnownTopic}',
        );

        // CHECK SAVED PERMISSION

        final permission =
        await _contentPermissionFirestoreService
            .checkPermission(
          childId: widget.child.id,
          topic: contentRequest.topic,
        );

        debugPrint(
          ' SAVED PERMISSION: $permission',
        );

        // BLOCKED BY PARENT

        if (permission == false) {
          debugPrint(
            ' CONTENT BLOCKED BY PARENT',
          );

          // Video will not be opened.
          // Normal AI conversation continues.
        }

        // UNKNOWN CONTENT - PARENT PIN REQUIRED

        else if (!contentRequest.isKnownTopic &&
            permission == null) {
          debugPrint(
            ' PARENT PERMISSION REQUIRED',
          );

          debugPrint(
            ' REQUESTED CONTENT: '
                '${contentRequest.topic}',
          );

          // SHOW PARENT PIN DIALOG

          final isPinCorrect =
          await _showParentPinDialog();

          // PIN NOT VERIFIED

          if (!isPinCorrect) {
            debugPrint(
              ' CONTENT PERMISSION NOT GRANTED',
            );

            // Normal AI conversation continues.
          }

          // PIN VERIFIED

          else {
            debugPrint(
              ' PARENT PIN VERIFIED',
            );

            final now = DateTime.now();

            // CREATE PERMISSION MODEL

            final contentPermission =
            ContentPermissionModel(
              id:
              '${widget.child.id}_${contentRequest.topic}',
              childId: widget.child.id,
              topic: contentRequest.topic,
              isAllowed: true,
              createdAt: now,
              updatedAt: now,
            );

            try {
              // SAVE PERMISSION TO FIRESTORE

              await _contentPermissionFirestoreService
                  .saveOrUpdatePermission(
                contentPermission,
              );

              debugPrint(
                ' CONTENT PERMISSION SAVED',
              );

              debugPrint(
                ' CONTENT APPROVED: '
                    '${contentRequest.topic}',
              );

              await _openKidsTube(
                topic: contentRequest.topic,
              );


            } catch (e, stackTrace) {
              debugPrint(
                ' FAILED TO SAVE CONTENT PERMISSION: $e',
              );

              debugPrintStack(
                stackTrace: stackTrace,
              );
            }
          }
        }

        // ALREADY ALLOWED / KNOWN CONTENT

        else {
          debugPrint(
            ' CONTENT ALLOWED',
          );

          debugPrint(
            ' READY FOR VIDEO: '
                '${contentRequest.topic}',
          );

          // VIDEO FLOW

          // Next step:
          // _openKidsTube(
          //   topic: contentRequest.topic,
          // );
        }
      }


      // SAVE USER MESSAGE TO MEMORY FIRST

      _conversationMemory.add(
        AIChatMessage(
          role: 'user',
          content: cleanMessage,
        ),
      );


      // LIMIT MEMORY SIZE

      if (_conversationMemory.length > 20) {
        _conversationMemory.removeRange(
          0,
          _conversationMemory.length - 20,
        );
      }

      debugPrint(
        ' MEMORY COUNT: '
            '${_conversationMemory.length}',
      );

      // SEND MESSAGE TO AI

      debugPrint(
        ' SENDING MESSAGE TO GEMINI...',
      );

      String response;

      try {
        response =
        await _aiModelService
            .generateResponse(
          context: aicontext,
          memory: _conversationMemory,
          userMessage: cleanMessage,
        ).timeout(
          const Duration(
            seconds: 30,
          ),
          onTimeout: () {
            throw Exception(
              'AI response timeout',
            );
          },
        );
      } catch (e) {
        debugPrint(
          ' GEMINI REQUEST FAILED: $e',
        );

        rethrow;
      }


      // VALIDATE RESPONSE


      response = response.trim();

      if (response.isEmpty) {
        debugPrint(
          ' GEMINI RETURNED EMPTY RESPONSE',
        );

        throw Exception(
          'Empty AI response',
        );
      }

      debugPrint(
        ' GEMINI RESPONSE RECEIVED',
      );

      debugPrint(
        ' RESPONSE: $response',
      );


      // SAVE AI RESPONSE TO MEMORY


      _conversationMemory.add(
        AIChatMessage(
          role: 'assistant',
          content: response,
        ),
      );

      try {
        final analysis = AIInteractionAnalysisModel(
          childId: aicontext.child.id,
          emotion: emotion,
          message: cleanMessage,
          createdAt: DateTime.now(),
        );

        await firestoreService.saveAIInteractionAnalysis(
          analysis: analysis,
        );

        debugPrint(
          'AI interaction analysis saved',
        );
      } catch (e, stackTrace) {
        debugPrint(
          'AI interaction analysis save error: $e',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }


      // LIMIT MEMORY AGAIN


      if (_conversationMemory.length > 20) {
        _conversationMemory.removeRange(
          0,
          _conversationMemory.length - 20,
        );
      }

      debugPrint(
        ' CONVERSATION MEMORY UPDATED',
      );

      if (!mounted) {
        return;
      }

      // UPDATE UI


      setState(() {
        _aiMessage = response;

        _character =
            _character.copyWith(
              emotion: emotion,
            );
      });

      debugPrint(
        ' AI RESPONSE DISPLAYED',
      );


      // SPEAK RESPONSE

      debugPrint(
        ' STARTING TTS...',
      );

      await _speakResponse(
        response: response,
        emotion: emotion,
      );

      debugPrint(
        ' TTS COMPLETED',
      );
    }


    // ERROR / FALLBACK RESPONSE

    catch (e, stackTrace) {
      debugPrint('');
      debugPrint(
        '==========================================',
      );

      debugPrint(
        ' AI RESPONSE ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      debugPrint(
        ' USING FALLBACK RESPONSE...',
      );

      debugPrint(
        '==========================================',
      );

      // GET FALLBACK RESPONSE

      final fallbackResponse =
      _aiService.getBasicResponse(
        message: cleanMessage,
        language: _language,
      );

      // SAVE FALLBACK RESPONSE

      _conversationMemory.add(
        AIChatMessage(
          role: 'assistant',
          content: fallbackResponse,
        ),
      );

      // LIMIT MEMORY

      if (_conversationMemory.length > 20) {
        _conversationMemory.removeRange(
          0,
          _conversationMemory.length - 20,
        );
      }

      // UPDATE UI

      if (mounted) {
        setState(() {
          _aiMessage = fallbackResponse;

          _character = _character.copyWith(
            emotion: _normalizeEmotion(
              _conversationContext?.emotion ?? 'neutral',
            ),
          );
        });
      }

      debugPrint(
        ' FALLBACK RESPONSE:',
      );

      debugPrint(
        fallbackResponse,
      );

      // SPEAK FALLBACK RESPONSE

      try {
        await _speakResponse(
          response: fallbackResponse,
          emotion: 'neutral',
        );
      } catch (ttsError, ttsStackTrace) {
        debugPrint(
          ' FALLBACK TTS ERROR: $ttsError',
        );

        debugPrintStack(
          stackTrace: ttsStackTrace,
        );
      }
    }

    // FINISH PROCESSING

    finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }

      debugPrint(
        ' MESSAGE PROCESSING FINISHED',
      );

      debugPrint(
        '==========================================',
      );
    }
  }

// SPEAK AI RESPONSE

  Future<void> _speakResponse({
    required String response,
    required String emotion,
  }) async {
    final cleanResponse = response.trim();


    // VALIDATE RESPONSE

    if (cleanResponse.isEmpty) {
      debugPrint(
        ' TTS SKIPPED - EMPTY RESPONSE',
      );

      return;
    }

    debugPrint('');
    debugPrint(
      '==========================================',
    );

    debugPrint(
      ' STARTING AI SPEECH',
    );

    debugPrint(
      '😊 EMOTION: $emotion',
    );

    debugPrint(
      ' TEXT: $cleanResponse',
    );

    debugPrint(
      '==========================================',
    );

    try {
      // STOP PREVIOUS SPEECH

      try {
        await _ttsService.stop();
      } catch (e) {
        debugPrint(
          ' PREVIOUS TTS STOP ERROR: $e',
        );
      }

      // SET CHARACTER SPEAKING

      if (mounted) {
        setState(() {
          _character =
              _character.copyWith(
                emotion: emotion,
                isSpeaking: true,
              );
        });
      }

      debugPrint(
        ' CALLING TTS SERVICE...',
      );

      // SPEAK

      await _ttsService.speak(
        cleanResponse,

        onStart: () {
          debugPrint(
            ' TTS STARTED',
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _character =
                _character.copyWith(
                  emotion: emotion,
                  isSpeaking: true,
                );
          });
        },

        onComplete: () {
          debugPrint(
            ' TTS COMPLETED',
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _character =
                _character.copyWith(
                  isSpeaking: false,
                );
          });
        },

        onError: (error) {
          debugPrint(
            ' TTS CALLBACK ERROR: $error',
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _character =
                _character.copyWith(
                  isSpeaking: false,
                );
          });
        },
      );

      debugPrint(
        ' TTS SERVICE FINISHED',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' SPEAK RESPONSE ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      // ALWAYS STOP CHARACTER ANIMATION

      if (mounted) {
        setState(() {
          _character =
              _character.copyWith(
                isSpeaking: false,
              );
        });
      }

      debugPrint(
        ' AI SPEECH FINISHED',
      );
    }
  }

  // FACE STATUS TEXT

  String _getLookingForYouText() {
    if (_isSinhala) {
      return 'මම ඔයාව බලනවා... 👀';
    }

    if (_isTamil) {
      return 'நான் உங்களை பார்க்கிறேன்... 👀';
    }

    return 'Looking for you... 👀';
  }

  String _getFaceDetectedText() {
    if (_isSinhala) {
      return 'මම ඔයාව දැක්කා! 😊';
    }

    if (_isTamil) {
      return 'நான் உங்களை பார்த்தேன்! 😊';
    }

    return 'I can see you! 😊';
  }

  // SPEECH TEXT

  String _getMicPermissionText() {
    if (_isSinhala) {
      return 'මයික්‍රෆෝනය භාවිතා කිරීමට අවසර ලබා දෙන්න.';
    }

    if (_isTamil) {
      return 'மைக்ரோஃபோன் அனுமதியை வழங்கவும்.';
    }

    return 'Please allow microphone permission.';
  }

  String _getSpeechUnavailableText() {
    if (_isSinhala) {
      return 'Speech recognition දැන් භාවිතා කළ නොහැක.';
    }

    if (_isTamil) {
      return 'Speech recognition தற்போது கிடைக்கவில்லை.';
    }

    return 'Speech recognition is unavailable.';
  }

  String _getNoAudioText() {
    if (_isSinhala) {
      return 'Audio recording එකක් ලැබුණේ නැහැ.';
    }

    if (_isTamil) {
      return 'Audio recording கிடைக்கவில்லை.';
    }

    return 'No audio recording was found.';
  }

  String _getNoSpeechText() {
    if (_isSinhala) {
      return 'කථාව හඳුනාගත නොහැකි විය.';
    }

    if (_isTamil) {
      return 'பேச்சை அடையாளம் காண முடியவில்லை.';
    }

    return 'No speech was recognized.';
  }

// SHOW MESSAGE

  void _showMessage(
      String message,
      ) {
    if (!mounted || message.trim().isEmpty) {
      return;
    }

    final messenger =
    ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message.trim(),
        ),
        behavior:
        SnackBarBehavior.floating,
      ),
    );

    debugPrint(
      ' MESSAGE: ${message.trim()}',
    );
  }


// HIDDEN CAMERA


  Widget _buildCameraView() {
    return const SizedBox.shrink();
  }

  // MESSAGE BUBBLE

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
  }) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin:
        const EdgeInsets.symmetric(
          vertical: 6,
        ),
        padding:
        const EdgeInsets.all(14),
        constraints:
        const BoxConstraints(
          maxWidth: 320,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.deepPurple
              : Colors.white,
          borderRadius:
          BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

// BUILD

  @override
  Widget build(
      BuildContext context,
      ) {


    // BUSY STATE

    final isProcessing =
        _isTranscribing ||
            _isSendingMessage;

    final inputDisabled =
        _isListening ||
            _isTranscribing ||
            _isSendingMessage;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F3FF),

      appBar: AppBar(
        title: Text(
          _isSinhala
              ? 'මගේ AI යාළුවා'
              : _isTamil
              ? 'என் AI நண்பன்'
              : 'My AI Friend',
        ),
        centerTitle: true,
        backgroundColor:
        Colors.deepPurple,
        foregroundColor:
        Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: inputDisabled
                ? null
                : _changeFriend,
            icon: const Icon(
              Icons.face_retouching_natural,
            ),
          ),
        ],
      ),

      body: Container(
        decoration:
        const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F3FF),
              Color(0xFFE7DBFF),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              // MAIN CONTENT

              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      const SizedBox(
                        height: 10,
                      ),


                      // FACE STATUS

                      AnimatedContainer(
                        duration:
                        const Duration(
                          milliseconds: 300,
                        ),
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration:
                        BoxDecoration(
                          color: _isFaceDetected
                              ? Colors.green
                              .withOpacity(0.12)
                              : Colors.white
                              .withOpacity(0.75),
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              _isFaceDetected
                                  ? Icons.face_rounded
                                  : Icons
                                  .visibility_outlined,
                              color: _isFaceDetected
                                  ? Colors.green
                                  : Colors.deepPurple,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Text(
                                _faceStatus,
                                textAlign:
                                TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // AI AVATAR

                      SizedBox(
                        height: 280,
                        child: Stack(
                          alignment:
                          Alignment.center,
                          children: [
                            Positioned(
                              bottom: 10,
                              child:
                              AICharacterAvatar(
                                characterId:
                                _character.characterId,
                                emotion:
                                _character.emotion,
                                isSpeaking:
                                _character.isSpeaking,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // AI MESSAGE

                      _buildMessageBubble(
                        text: _aiMessage,
                        isUser: false,
                      ),

                      // USER MESSAGE


                      _buildMessageBubble(
                        text: _userMessage,
                        isUser: true,
                      ),

                      // LISTENING STATUS

                      if (_isListening)
                        Padding(
                          padding:
                          const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                _isSinhala
                                    ? 'මම අහගෙන ඉන්නවා...'
                                    : _isTamil
                                    ? 'நான் கேட்டு கொண்டிருக்கிறேன்...'
                                    : 'Listening...',
                              ),
                            ],
                          ),
                        ),


                      // TRANSCRIBING STATUS

                      if (_isTranscribing)
                        Padding(
                          padding:
                          const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                _isSinhala
                                    ? 'කථාව හඳුනාගනිමින්...'
                                    : _isTamil
                                    ? 'பேச்சை செயலாக்குகிறது...'
                                    : 'Processing speech...',
                              ),
                            ],
                          ),
                        ),


                      // AI THINKING STATUS

                      if (_isSendingMessage)
                        Padding(
                          padding:
                          const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                _isSinhala
                                    ? 'AI යාළුවා හිතමින් ඉන්නවා...'
                                    : _isTamil
                                    ? 'AI நண்பன் சிந்திக்கிறான்...'
                                    : 'AI is thinking...',
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),


              // INPUT AREA

              SafeArea(
                top: false,
                child: Container(
                  padding:
                  const EdgeInsets.all(12),
                  decoration:
                  const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          0x11000000,
                        ),
                        blurRadius: 10,
                        offset: Offset(
                          0,
                          -2,
                        ),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [


                      // TEXT INPUT

                      Expanded(
                        child: TextField(
                          controller:
                          _messageController,

                          enabled:
                          !inputDisabled,

                          textInputAction:
                          TextInputAction.send,

                          onSubmitted:
                              (value) async {
                            if (inputDisabled) {
                              return;
                            }

                            final message =
                            value.trim();

                            if (message.isEmpty) {
                              return;
                            }

                            _messageController
                                .clear();

                            await _handleUserMessage(
                              message,
                            );
                          },

                          decoration:
                          InputDecoration(
                            hintText:
                            _isSinhala
                                ? 'ඔයාගේ පණිවිඩය...'
                                : _isTamil
                                ? 'உங்கள் செய்தி...'
                                : 'Type your message...',

                            filled: true,

                            fillColor:
                            const Color(
                              0xFFF4EEFF,
                            ),

                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(
                                24,
                              ),
                              borderSide:
                              BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      // MICROPHONE BUTTON

                      Material(
                        color: _isListening
                            ? Colors.red
                            : isProcessing
                            ? Colors.grey
                            : Colors.deepPurple,

                        shape:
                        const CircleBorder(),

                        child: IconButton(
                          onPressed:
                          isProcessing
                              ? null
                              : () async {

                            // STOP LISTENING


                            if (_isListening) {
                              await _stopListening();
                              return;
                            }


                            // START LISTENING

                            await _startListening();
                          },

                          icon: Icon(
                            _isListening
                                ? Icons.stop
                                : Icons.mic,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 6,
                      ),


                      // SEND BUTTON

                      Material(
                        color: inputDisabled
                            ? Colors.grey
                            : Colors.deepPurple,

                        shape:
                        const CircleBorder(),

                        child: IconButton(
                          onPressed:
                          inputDisabled
                              ? null
                              : () async {
                            final message =
                            _messageController
                                .text
                                .trim();

                            if (message.isEmpty) {
                              return;
                            }

                            _messageController
                                .clear();

                            await _handleUserMessage(
                              message,
                            );
                          },

                          icon:
                          const Icon(
                            Icons.send_rounded,
                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // DISPOSE


  @override
  void dispose() {
    // TEXT CONTROLLER

    _messageController.dispose();

    // STOP SPEECH LISTENING

    try {
      unifiedSpeechService.cancelListening();
    } catch (e) {
      debugPrint(
        ' Speech cancel dispose error: $e',
      );
    }

    // STOP AUDIO RECORDING

    try {
      _audioRecordingService.cancelRecording();
    } catch (e) {
      debugPrint(
        ' Audio cancel dispose error: $e',
      );
    }

    try {
      _audioRecordingService.dispose();
    } catch (e) {
      debugPrint(
        ' Audio dispose error: $e',
      );
    }

    // STOP TTS

    try {
      _ttsService.stop();
    } catch (e) {
      debugPrint(
        ' TTS stop dispose error: $e',
      );
    }

    try {
      _ttsService.dispose();
    } catch (e) {
      debugPrint(
        ' TTS dispose error: $e',
      );
    }

    // CAMERA

    try {
      _cameraController?.dispose();
    } catch (e) {
      debugPrint(
        ' Camera dispose error: $e',
      );
    }


    // FACE DETECTOR

    try {
      _faceDetector.close();
    } catch (e) {
      debugPrint(
        ' Face detector dispose error: $e',
      );
    }

    super.dispose();
  }
}

