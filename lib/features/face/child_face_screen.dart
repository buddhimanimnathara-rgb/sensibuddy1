import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/services/firestore_service.dart';
import '../security/parent_pin_screen.dart';
import 'live_face_registration_screen.dart';

class ChildFaceScreen extends StatefulWidget {
  final String childId;
  final String guardianId;

  const ChildFaceScreen({
    super.key,
    required this.childId,
    required this.guardianId,
  });

  @override
  State<ChildFaceScreen> createState() =>
      _ChildFaceScreenState();
}

class _ChildFaceScreenState
    extends State<ChildFaceScreen> {

  // FACE IMAGES

  final List<File> faceImages = [];


  // LIVE EMBEDDINGS
  final List<List<double>> faceEmbeddings = [];


  // STATES

  bool loading = false;

  int currentSample = 1;


  // CAPTURE FACE USING LIVE FACE REGISTRATION SCREEN
  Future<void> captureFace() async {
    if (loading || currentSample > 3) {
      return;
    }

    try {

      // OPEN LIVE CAMERA SCREEN
      final result =
      await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const LiveFaceRegistrationScreen(),
        ),
      );

      // USER CANCELLED
      if (result == null) {
        return;
      }

      // GET IMAGE

      final dynamic imageValue =
      result['image'];

      if (imageValue is! File) {
        throw Exception(
          'Captured face image is invalid',
        );
      }

      final File image = imageValue;

      // GET EMBEDDING
      final dynamic embeddingValue =
      result['embedding'];

      if (embeddingValue is! List) {
        throw Exception(
          'Face embedding is invalid',
        );
      }

      final List<double> embedding =
      embeddingValue.map((item) {
        if (item is num) {
          return item.toDouble();
        }

        return double.tryParse(
          item.toString(),
        ) ??
            0.0;
      }).toList();

      // VALIDATE IMAGE
      final exists =
      await image.exists();

      if (!exists) {
        throw Exception(
          'Captured image file not found',
        );
      }

      // VALIDATE EMBEDDING
      if (embedding.length != 192) {
        throw Exception(
          'Invalid face embedding length: '
              '${embedding.length}',
        );
      }

      if (!mounted) {
        return;
      }

      // ADD IMAGE + MATCHING EMBEDDING

      setState(() {
        faceImages.add(image);

        faceEmbeddings.add(
          List<double>.from(
            embedding,
          ),
        );

        currentSample++;
      });

      debugPrint(
        '========================================',
      );

      debugPrint(
        '📷 Child sample captured',
      );

      debugPrint(
        'Sample: ${faceImages.length}',
      );

      debugPrint(
        'Images: ${faceImages.length}',
      );

      debugPrint(
        'Embeddings: ${faceEmbeddings.length}',
      );

      debugPrint(
        'Embedding length: ${embedding.length}',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Face Sample ${faceImages.length} captured successfully',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========== CHILD FACE CAPTURE ERROR ==========',
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Face capture failed: $e',
          ),
        ),
      );
    }
  }

  // SAVE CHILD FACE

  Future<void> saveFace() async {

    // CHECK 3 FACE SAMPLES

    if (faceImages.length < 3 ||
        faceEmbeddings.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Please capture 3 face samples',
          ),
        ),
      );

      return;
    }

    // CHECK IMAGE / EMBEDDING COUNT MATCH

    if (faceImages.length !=
        faceEmbeddings.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
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
        '========== SAVE CHILD FACE START ==========',
      );

      debugPrint(
        '📷 Face images: ${faceImages.length}',
      );

      debugPrint(
        '🧠 Face embeddings: '
            '${faceEmbeddings.length}',
      );

      // VALIDATE ALL EMBEDDINGS

      for (int i = 0; i < 3; i++) {
        if (faceEmbeddings[i].length != 192) {
          throw Exception(
            'Invalid embedding ${i + 1}: '
                '${faceEmbeddings[i].length}',
          );
        }
      }

      debugPrint(
        '✅ All child embeddings validated',
      );

      // SAVE FIRST IMAGE AS IMAGE DATA

      final bytes =
      await faceImages.first.readAsBytes();

      final imageData =
      base64Encode(bytes);

      debugPrint(
        '💾 Preparing child Firestore data...',
      );

      // SAVE TO FIRESTORE

      await firestoreService.saveChildFace(
        widget.childId,
        {
          // ID
          'childId': widget.childId,

          // IMAGE
          'imageData': imageData,

          // LIVE CAMERA EMBEDDINGS
          'embedding1':
          faceEmbeddings[0],

          'embedding2':
          faceEmbeddings[1],

          'embedding3':
          faceEmbeddings[2],

          // REGISTRATION STATUS
          'registered': true,

          'faceCount':
          faceImages.length,

          'embeddingCount':
          faceEmbeddings.length,

          'createdAt':
          DateTime.now()
              .toIso8601String(),
        },
      );

      debugPrint(
        '✅ Child face successfully saved',
      );

      if (!mounted) {
        return;
      }

      // SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          Colors.green,
          content: Text(
            'Child face registered successfully',
          ),
        ),
      );

      // GO TO PARENT PIN SCREEN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParentPinScreen(
            guardianId: widget.guardianId,
            childId: widget.childId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========== SAVE CHILD FACE ERROR ==========',
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
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          Colors.red,
          content: Text(
            'Error saving child face: $e',
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

  // SKIP REGISTRATION
  void _skipForNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ParentPinScreen(
          guardianId: widget.guardianId,
          childId: widget.childId,
        ),
      ),
    );
  }

  // BUILD
  @override
  Widget build(
      BuildContext context,
      ) {
    final bool allSamplesCaptured =
        faceImages.length == 3 &&
            faceEmbeddings.length == 3;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F3FF),

      appBar: AppBar(
        title: const Text(
          'Child Face Registration',
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

                // MASCOT
                Image.asset(
                  'assets/images/mascot.png',
                  height: 120,
                )
                    .animate(
                  onPlay: (c) =>
                      c.repeat(
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
                  'Child Face Registration',
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
                  'Capture three clear live face samples of the child.\nYou can skip this step and register later.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color:
                    Colors.black54,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // MAIN CARD
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

                        // IMAGE PREVIEW
                        CircleAvatar(
                          radius: 80,

                          backgroundColor:
                          Colors.deepPurple
                              .shade50,

                          backgroundImage:
                          faceImages.isNotEmpty
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
                            size: 70,
                            color: Colors
                                .deepPurple,
                          )
                              : null,
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // SAMPLE STATUS
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .deepPurple
                                .shade50,

                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),

                          child: Text(
                            currentSample <= 3
                                ? 'Current Sample : $currentSample / 3'
                                : 'All Samples Captured',

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // CAPTURE BUTTON
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
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                              ),
                            ),

                            onPressed:
                            loading ||
                                currentSample >
                                    3
                                ? null
                                : captureFace,

                            icon:
                            const Icon(
                              Icons.camera_alt,
                            ),

                            label: Text(
                              currentSample <= 3
                                  ? 'Capture Sample $currentSample'
                                  : 'Completed',

                              style:
                              const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // SAMPLE CHECKLIST
                        Container(
                          width:
                          double.infinity,

                          padding:
                          const EdgeInsets
                              .all(15),

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .green
                                .shade50,

                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),

                          child: Column(
                            children: [

                              _buildSampleStatus(
                                sample: 1,
                                completed:
                                faceImages.isNotEmpty &&
                                    faceEmbeddings.isNotEmpty,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _buildSampleStatus(
                                sample: 2,
                                completed:
                                faceImages
                                    .length >=
                                    2 &&
                                    faceEmbeddings
                                        .length >=
                                        2,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _buildSampleStatus(
                                sample: 3,
                                completed:
                                faceImages
                                    .length >=
                                    3 &&
                                    faceEmbeddings
                                        .length >=
                                        3,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // SKIP
                        SizedBox(
                          width:
                          double.infinity,
                          height: 55,

                          child:
                          OutlinedButton.icon(
                            style:
                            OutlinedButton
                                .styleFrom(
                              foregroundColor:
                              Colors.deepPurple,

                              side:
                              const BorderSide(
                                color:
                                Colors.deepPurple,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                              ),
                            ),

                            onPressed:
                            loading
                                ? null
                                : _skipForNow,

                            icon:
                            const Icon(
                              Icons.skip_next,
                            ),

                            label:
                            const Text(
                              'Skip For Now',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // CONTINUE
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
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                              ),
                            ),

                            onPressed:
                            loading ||
                                !allSamplesCaptured
                                ? null
                                : saveFace,

                            icon:
                            const Icon(
                              Icons.arrow_forward,
                            ),

                            label: loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                3,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Text(
                              'Continue',
                              style:
                              TextStyle(
                                fontSize:
                                18,
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

  // SAMPLE STATUS WIDGET
  Widget _buildSampleStatus({
    required int sample,
    required bool completed,
  }) {
    return Row(
      children: [

        Icon(
          completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,

          color: completed
              ? Colors.green
              : Colors.grey,
        ),

        const SizedBox(
          width: 10,
        ),

        Text(
          'Face Sample $sample',
        ),

        const Spacer(),

        if (completed)
          const Text(
            'Ready',
            style: TextStyle(
              color: Colors.green,
              fontWeight:
              FontWeight.bold,
            ),
          ),
      ],
    );
  }
}