import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'live_face_registration_screen.dart';
import '../../core/services/firestore_service.dart';


import 'child_face_screen.dart';

class GuardianFaceScreen extends StatefulWidget {
  final String guardianId;
  final String childId;

  const GuardianFaceScreen({
    super.key,
    required this.guardianId,
    required this.childId,
  });

  @override
  State<GuardianFaceScreen> createState() =>
      _GuardianFaceScreenState();
}

class _GuardianFaceScreenState
    extends State<GuardianFaceScreen> {

  final ImagePicker _picker = ImagePicker();

  final List<File> faceImages = [];

  final List<List<double>> faceEmbeddings = [];

  bool loading = false;
  bool cameraOpening = false;

  int currentSample = 0;

  Future<void> captureFace() async {
    if (cameraOpening || currentSample >= 3) {
      return;
    }

    setState(() {
      cameraOpening = true;
    });

    try {
      final result =
      await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const LiveFaceRegistrationScreen(),
        ),
      );

      if (!mounted) return;

      if (result == null) {
        return;
      }

      final image = result['image'];
      final embeddingData = result['embedding'];

      if (image is! File) {
        throw Exception(
          'Invalid captured image',
        );
      }

      if (embeddingData is! List) {
        throw Exception(
          'Invalid face embedding',
        );
      }

      final embedding =
      List<double>.from(embeddingData);

      if (embedding.length != 192) {
        throw Exception(
          'Invalid embedding length: '
              '${embedding.length}',
        );
      }

      setState(() {
        if (faceImages.length > currentSample) {
          faceImages[currentSample] = image;
        } else {
          faceImages.add(image);
        }

        if (faceEmbeddings.length > currentSample) {
          faceEmbeddings[currentSample] = embedding;
        } else {
          faceEmbeddings.add(embedding);
        }

        currentSample++;
      });

      debugPrint(
        ' Sample $currentSample saved',
      );

      debugPrint(
        ' Embedding ${embedding.length}D saved',
      );
    } catch (e, stackTrace) {
      debugPrint(
        ' Capture error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Capture failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          cameraOpening = false;
        });
      }
    }
  }

  Future<void> saveFace() async {

    // PREVENT DUPLICATE SAVE

    if (loading) {
      debugPrint(
        ' Save already in progress',
      );

      return;
    }

    // CHECK EXACTLY 3 FACE SAMPLES

    if (faceImages.length != 3 ||
        faceEmbeddings.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please capture exactly 3 face samples',
          ),
        ),
      );

      return;
    }

    // CHECK IMAGE / EMBEDDING COUNT MATCH

    if (faceImages.length != faceEmbeddings.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Face images and embeddings do not match',
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      debugPrint(
        '========== SAVE GUARDIAN FACE START ==========',
      );

      debugPrint(
        ' Face images: ${faceImages.length}',
      );

      debugPrint(
        ' Face embeddings: ${faceEmbeddings.length}',
      );

      // VALIDATE ALL IMAGE FILES

      for (int i = 0; i < faceImages.length; i++) {
        final exists = await faceImages[i].exists();

        if (!exists) {
          throw Exception(
            'Face image ${i + 1} no longer exists',
          );
        }

        final imageSize =
        await faceImages[i].length();

        if (imageSize <= 0) {
          throw Exception(
            'Face image ${i + 1} is empty',
          );
        }

        debugPrint(
          ' Image ${i + 1} validated: '
              '$imageSize bytes',
        );
      }

      // VALIDATE ALL LIVE EMBEDDINGS

      for (int i = 0; i < 3; i++) {
        final embedding =
        faceEmbeddings[i];

        // CHECK EMBEDDING LENGTH

        if (embedding.length != 192) {
          throw Exception(
            'Invalid embedding ${i + 1}: '
                'Expected 192 values, '
                'but received ${embedding.length}',
          );
        }

        // CHECK INVALID NUMBERS

        for (final value in embedding) {
          if (!value.isFinite) {
            throw Exception(
              'Embedding ${i + 1} contains '
                  'invalid values',
            );
          }
        }

        debugPrint(
          ' Embedding ${i + 1} validated: '
              '${embedding.length}D',
        );
      }

      debugPrint(
        ' All face data validated successfully',
      );

      // SAVE FIRST IMAGE AS REFERENCE IMAGE

      final bytes =
      await faceImages.first.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'Reference face image is empty',
        );
      }

      final imageData =
      base64Encode(bytes);

      debugPrint(
        ' Reference image encoded successfully',
      );

      // PREPARE FIRESTORE DATA

      final faceData = <String, dynamic>{


        'guardianId': widget.guardianId,

        'childId': widget.childId,


        'imageData': imageData,

        'embedding1': faceEmbeddings[0],

        'embedding2': faceEmbeddings[1],

        'embedding3': faceEmbeddings[2],

        'registered': true,

        'faceCount': 3,

        'embeddingCount': 3,

        'embeddingDimension': 192,

        'createdAt':
        DateTime.now().toIso8601String(),
      };

      debugPrint(
        ' Preparing Firestore data...',
      );

      // SAVE TO FIRESTORE

      await firestoreService.saveGuardianFace(
        widget.guardianId,
        faceData,
      );

      debugPrint(
        '===============================================',
      );

      debugPrint(
        ' GUARDIAN FACE SUCCESSFULLY SAVED',
      );

      debugPrint(
        'Guardian ID: ${widget.guardianId}',
      );

      debugPrint(
        'Samples: 3',
      );

      debugPrint(
        'Embeddings: 3 × 192D',
      );

      debugPrint(
        '===============================================',
      );

      if (!mounted) {
        return;
      }

      // SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Guardian face registered successfully',
          ),
        ),
      );


      // GO TO CHILD FACE REGISTRATION
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChildFaceScreen(
            childId: widget.childId,
            guardianId: widget.guardianId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========== SAVE GUARDIAN FACE ERROR ==========',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error saving face: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }




  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF7F3FF),

      appBar: AppBar(

        title: const Text(
          "Guardian Face Registration",
        ),

        centerTitle: true,

        backgroundColor:
        Colors.deepPurple,

        foregroundColor:
        Colors.white,

        elevation: 0,

      ),

      body: Container(

        decoration:
        const BoxDecoration(

          gradient:
          LinearGradient(

            begin:
            Alignment.topCenter,

            end:
            Alignment.bottomCenter,

            colors: [
              Color(0xFFF6F2FF),
              Color(0xFFE4D7FF),
            ],

          ),

        ),

        child: SafeArea(

          child:
          SingleChildScrollView(

            padding:
            const EdgeInsets.all(20),

            child: Column(

              children: [

                Image.asset(
                  "assets/images/mascot.png",
                  height: 120,
                )
                    .animate(
                  onPlay: (
                      controller,
                      ) =>
                      controller.repeat(
                        reverse: true,
                      ),
                )
                    .moveY(
                  begin: 0,
                  end: -10,
                  duration:
                  2.seconds,
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(

                  "Guardian Face Registration",

                  style: TextStyle(

                    fontSize: 25,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    Colors.deepPurple,

                  ),

                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(

                  "Capture 3 clear face samples "
                      "for secure authentication.",

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(

                    fontSize: 16,

                    color:
                    Colors.black54,

                  ),

                ),

                const SizedBox(
                  height: 30,
                ),

                Card(

                  elevation: 8,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),

                  ),

                  child: Padding(

                    padding:
                    const EdgeInsets.all(
                      20,
                    ),

                    child: Column(

                      children: [

                        CircleAvatar(

                          radius: 80,

                          backgroundColor:
                          Colors
                              .deepPurple
                              .shade50,

                          backgroundImage:
                          faceImages
                              .isNotEmpty
                              ? FileImage(
                            faceImages
                                .first,
                          )
                              : null,

                          child:
                          faceImages.isEmpty
                              ? const Icon(

                            Icons
                                .face_retouching_natural,

                            size: 80,

                          )
                              : null,

                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        LinearProgressIndicator(

                          value:
                          currentSample / 3,

                          minHeight: 10,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),

                          backgroundColor:
                          Colors.grey
                              .shade300,

                          valueColor:
                          const AlwaysStoppedAnimation(
                            Colors.deepPurple,
                          ),

                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(

                          "Captured "
                              "$currentSample "
                              "of 3 Face Samples",

                          style:
                          const TextStyle(

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        SizedBox(

                          width:
                          double.infinity,

                          height: 55,

                          child:
                          ElevatedButton.icon(

                            style:
                            ElevatedButton
                                .styleFrom(

                              backgroundColor:
                              Colors.deepPurple,

                              foregroundColor:
                              Colors.white,

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),

                              ),

                            ),

                            onPressed:
                            loading ||
                                cameraOpening ||
                                currentSample >= 3
                                ? null
                                : captureFace,

                            icon: const Icon(
                              Icons.photo_camera,
                            ),

                            label: Text(

                              cameraOpening
                                  ? "Opening Camera..."
                                  : "Capture Face "
                                  "(${faceImages.length}/3)",

                              style:
                              const TextStyle(

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),

                          ),

                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Container(

                          width:
                          double.infinity,

                          padding:
                          const EdgeInsets.all(
                            16,
                          ),

                          decoration:
                          BoxDecoration(

                            color:
                            Colors.green
                                .shade50,

                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),

                          ),

                          child: Column(

                            children: [

                              _sampleRow(
                                "Face Sample 1",
                                faceImages.length >= 1,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _sampleRow(
                                "Face Sample 2",
                                faceImages.length >=
                                    2,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _sampleRow(
                                "Face Sample 3",
                                faceImages.length >=
                                    3,
                              ),

                            ],

                          ),

                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        SizedBox(

                          width:
                          double.infinity,

                          height: 55,

                          child:
                          ElevatedButton.icon(

                            style:
                            ElevatedButton
                                .styleFrom(

                              backgroundColor:
                              Colors.deepPurple,

                              foregroundColor:
                              Colors.white,

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),

                              ),

                            ),

                            onPressed:
                            loading ||
                                currentSample < 3
                                ? null
                                : saveFace,

                            icon:
                            const Icon(
                              Icons.verified_user,
                            ),

                            label: loading

                                ? const SizedBox(

                              width: 24,

                              height: 24,

                              child:
                              CircularProgressIndicator(

                                strokeWidth: 3,

                                color:
                                Colors.white,

                              ),

                            )

                                : const Text(

                              "Continue",

                              style:
                              TextStyle(

                                fontSize: 18,

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),

                          ),

                        ),

                        const SizedBox(
                          height: 15,
                        ),

                      ],

                    ),

                  ),

                ),

                const SizedBox(
                  height: 20,
                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

  Widget _sampleRow(
      String title,
      bool completed,
      ) {

    return Row(

      children: [

        Icon(

          completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,

          color:
          completed
              ? Colors.green
              : Colors.grey,

        ),

        const SizedBox(
          width: 10,
        ),

        Text(title),

      ],

    );

  }

}