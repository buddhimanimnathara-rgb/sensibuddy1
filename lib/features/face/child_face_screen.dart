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

class _ChildFaceScreenState extends State<ChildFaceScreen> {

  final List<File> faceImages = [];
  final List<List<double>> faceEmbeddings = [];

  bool loading = false;
  bool cameraOpening = false;

  int currentSample = 1;

  Future<void> captureFace({int? sampleIndex}) async {
    if (loading || cameraOpening) {
      return;
    }

    final int targetIndex =
        sampleIndex ?? faceImages.length;

    if (targetIndex < 0 || targetIndex >= 3) {
      return;
    }

    setState(() {
      cameraOpening = true;
    });

    try {
      debugPrint(
        '========================================',
      );

      debugPrint(
        ' Opening child live face registration',
      );

      debugPrint(
        'Target Sample: ${targetIndex + 1}',
      );

      debugPrint(
        '========================================',
      );
      // OPEN LIVE CAMERA

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
          'Captured face image is invalid.',
        );
      }

      final File image = imageValue;

      // VALIDATE IMAGE FILE

      final bool imageExists =
      await image.exists();

      if (!imageExists) {
        throw Exception(
          'Captured image file not found.',
        );
      }

      final int imageSize =
      await image.length();

      if (imageSize <= 0) {
        throw Exception(
          'Captured image is empty.',
        );
      }

      // GET EMBEDDING

      final dynamic embeddingValue =
      result['embedding'];

      if (embeddingValue is! List) {
        throw Exception(
          'Face embedding is invalid.',
        );
      }

      // CONVERT EMBEDDING TO List<double>

      final List<double> embedding =
      embeddingValue.map<double>((item) {
        if (item is num) {
          return item.toDouble();
        }

        final parsed =
        double.tryParse(item.toString());

        if (parsed == null) {
          throw Exception(
            'Invalid embedding value: $item',
          );
        }

        return parsed;
      }).toList();

      // EMBEDDING LENGTH

      if (embedding.length != 192) {
        throw Exception(
          'Invalid face embedding length: '
              '${embedding.length}. Expected 192.',
        );
      }

      // EMBEDDING VALUE VALIDATION

      for (final value in embedding) {
        if (!value.isFinite) {
          throw Exception(
            'Face embedding contains an invalid value.',
          );
        }
      }

      if (!mounted) {
        return;
      }

      // REPLACE EXISTING SAMPLE
      // OR ADD NEW SAMPLE

      setState(() {
        if (targetIndex < faceImages.length) {
          // RETAKE / REPLACE

          faceImages[targetIndex] = image;

          faceEmbeddings[targetIndex] =
          List<double>.from(embedding);
        } else {


          faceImages.add(image);

          faceEmbeddings.add(
            List<double>.from(embedding),
          );
        }

        // Next sample
        currentSample =
        faceImages.length < 3
            ? faceImages.length + 1
            : 4;
      });

      // DEBUG

      debugPrint(
        '========================================',
      );

      debugPrint(
        ' Child face sample ready',
      );

      debugPrint(
        'Sample: ${targetIndex + 1}',
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

      // SUCCESS MESSAGE

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            targetIndex < faceImages.length
                ? 'Face Sample ${targetIndex + 1} updated successfully'
                : 'Face Sample ${targetIndex + 1} captured successfully',
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
    } finally {
      if (mounted) {
        setState(() {
          cameraOpening = false;
        });
      }
    }
  }

  // SAVE CHILD FACE

  Future<void> saveFace() async {
    // CHECK EXACTLY 3 SAMPLES

    if (faceImages.length != 3 ||
        faceEmbeddings.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          content: Text(
            'Please capture all 3 face samples.',
          ),
        ),
      );

      return;
    }

    // CHECK COUNTS MATCH

    if (faceImages.length !=
        faceEmbeddings.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Face images and embeddings do not match.',
          ),
        ),
      );

      return;
    }

    if (loading) {
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
        ' Face images: ${faceImages.length}',
      );

      debugPrint(
        ' Face embeddings: ${faceEmbeddings.length}',
      );

      // VALIDATE ALL IMAGES
      for (int i = 0; i < 3; i++) {
        final bool exists =
        await faceImages[i].exists();

        if (!exists) {
          throw Exception(
            'Face image ${i + 1} was not found.',
          );
        }

        final int size =
        await faceImages[i].length();

        if (size <= 0) {
          throw Exception(
            'Face image ${i + 1} is empty.',
          );
        }
      }

      debugPrint(
        ' All child images validated',
      );

      // VALIDATE ALL EMBEDDINGS

      for (int i = 0; i < 3; i++) {
        if (faceEmbeddings[i].length != 192) {
          throw Exception(
            'Invalid embedding ${i + 1}: '
                '${faceEmbeddings[i].length}. '
                'Expected 192.',
          );
        }

        for (final value in faceEmbeddings[i]) {
          if (!value.isFinite) {
            throw Exception(
              'Embedding ${i + 1} contains an invalid value.',
            );
          }
        }
      }

      debugPrint(
        ' All child embeddings validated',
      );

      // SAVE FIRST IMAGE AS BASE64

      final bytes =
      await faceImages.first.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'First face image is empty.',
        );
      }

      final imageData =
      base64Encode(bytes);

      debugPrint(
        ' Preparing child Firestore data...',
      );

      final Map<String, dynamic> faceData = {
        // ID
        'childId': widget.childId,

        // IMAGE
        'imageData': imageData,

        // LIVE CAMERA EMBEDDINGS
        'embedding1':
        List<double>.from(
          faceEmbeddings[0],
        ),

        'embedding2':
        List<double>.from(
          faceEmbeddings[1],
        ),

        'embedding3':
        List<double>.from(
          faceEmbeddings[2],
        ),

        // REGISTRATION STATUS
        'registered': true,

        'faceCount':
        faceImages.length,

        'embeddingCount':
        faceEmbeddings.length,

        'createdAt':
        DateTime.now()
            .toIso8601String(),
      };

      // SAVE TO FIRESTORE

      await firestoreService.saveChildFace(
        widget.childId,
        faceData,
      );

      debugPrint(
        ' Child face successfully saved',
      );

      if (!mounted) {
        return;
      }

      // SUCCESS

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Child face registered successfully.',
          ),
        ),
      );

      // GO TO PARENT PIN

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
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
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
    if (loading || cameraOpening) {
      return;
    }

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

  // SAMPLE STATUS

  bool _isSampleCompleted(int index) {
    return faceImages.length > index &&
        faceEmbeddings.length > index &&
        faceEmbeddings[index].length == 192;
  }

  // SAMPLE CARD

  Widget _buildSampleCard({
    required int sample,
  }) {
    final int index = sample - 1;

    final bool completed =
    _isSampleCompleted(index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.shade50
            : Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? Colors.green.shade200
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // THUMBNAIL

          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color:
              Colors.deepPurple.shade50,
              borderRadius:
              BorderRadius.circular(14),
            ),
            clipBehavior:
            Clip.antiAlias,
            child: completed
                ? Image.file(
              faceImages[index],
              fit: BoxFit.cover,
            )
                : const Icon(
              Icons.face,
              size: 34,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(width: 14),

          // SAMPLE INFORMATION

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Face Sample $sample',
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  completed
                      ? 'Ready'
                      : 'Not captured',
                  style: TextStyle(
                    color: completed
                        ? Colors.green
                        : Colors.grey,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // RETAKE BUTTON

          if (completed)
            OutlinedButton(
              onPressed:
              loading ||
                  cameraOpening
                  ? null
                  : () {
                captureFace(
                  sampleIndex:
                  index,
                );
              },
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Colors.deepPurple,
                side:
                const BorderSide(
                  color: Colors.deepPurple,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: const Text(
                'Retake',
              ),
            ),
        ],
      ),
    );
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(20),

            child: Column(
              children: [


                Image.asset(
                  'assets/images/mascot.png',
                  height: 120,
                )
                    .animate(
                  onPlay: (controller) =>
                      controller.repeat(
                        reverse: true,
                      ),
                )
                    .moveY(
                  begin: 0,
                  end: -10,
                  duration: 2.seconds,
                ),

                const SizedBox(
                  height: 20,
                ),

                // TITLE

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
                  'Capture three clear live face samples of the child.\nYou can retake any sample if the photo is not clear.',
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
                        // MAIN IMAGE PREVIEW

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
                              color: Colors
                                  .deepPurple,
                              fontSize: 16,
                            ),
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
                          ElevatedButton
                              .icon(
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              Colors
                                  .deepPurple,
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
                                cameraOpening ||
                                currentSample >
                                    3
                                ? null
                                : () {
                              captureFace();
                            },
                            icon: cameraOpening
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                3,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons
                                  .camera_alt,
                            ),
                            label: Text(
                              cameraOpening
                                  ? 'Opening Camera...'
                                  : currentSample <=
                                  3
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


                        Container(
                          width:
                          double.infinity,
                          padding:
                          const EdgeInsets
                              .all(
                            15,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            Colors.green.shade50,
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSampleCard(
                                sample: 1,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _buildSampleCard(
                                sample: 2,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _buildSampleCard(
                                sample: 3,
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
                          OutlinedButton
                              .icon(
                            style:
                            OutlinedButton
                                .styleFrom(
                              foregroundColor:
                              Colors
                                  .deepPurple,
                              side:
                              const BorderSide(
                                color: Colors
                                    .deepPurple,
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
                            loading ||
                                cameraOpening
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
                          ElevatedButton
                              .icon(
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              Colors
                                  .deepPurple,
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
                              Icons
                                  .arrow_forward,
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
}