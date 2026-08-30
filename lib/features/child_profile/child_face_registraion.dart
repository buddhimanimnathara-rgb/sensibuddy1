import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import '../face/live_face_registration_screen.dart';

class ChildFaceRegistrationScreen extends StatefulWidget {
  final String childId;

  const ChildFaceRegistrationScreen({
    super.key,
    required this.childId,
  });

  @override
  State<ChildFaceRegistrationScreen> createState() =>
      _ChildFaceRegistrationScreenState();
}

class _ChildFaceRegistrationScreenState
    extends State<ChildFaceRegistrationScreen> {

  // FACE DATA

  final List<File> faceImages = [];

  final List<List<double>> faceEmbeddings = [];

  // LOADING

  bool _loading = false;


  // CAPTURE FACE USING LIVE CAMERA


  Future<void> _captureFace() async {
    // LIMIT TO 3 SAMPLES


    if (faceImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'You already captured 3 face samples. Remove one to recapture.',
          ),
        ),
      );

      return;
    }

    try {

      // OPEN LIVE FACE REGISTRATION SCREEN

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LiveFaceRegistrationScreen(),
        ),
      );

      // USER CANCELLED


      if (result == null) {
        return;
      }


      // VALIDATE RESULT


      if (result is! Map) {
        throw Exception(
          'Invalid face capture result',
        );
      }

      final dynamic imageValue = result['image'];

      final dynamic embeddingValue =
      result['embedding'];

      if (imageValue is! File) {
        throw Exception(
          'Captured face image is invalid',
        );
      }

      if (embeddingValue is! List) {
        throw Exception(
          'Captured face embedding is invalid',
        );
      }

      // CONVERT EMBEDDING TO List<double>

      final embedding =
      embeddingValue.map<double>((value) {
        if (value is num) {
          return value.toDouble();
        }

        return double.parse(
          value.toString(),
        );
      }).toList();

      // VALIDATE EMBEDDING

      if (embedding.length != 192) {
        throw Exception(
          'Invalid embedding length: ${embedding.length}',
        );
      }

      // CHECK IMAGE EXISTS

      final imageExists =
      await imageValue.exists();

      if (!imageExists) {
        throw Exception(
          'Captured image file not found',
        );
      }

      if (!mounted) {
        return;
      }


      // SAVE IMAGE + LIVE EMBEDDING TO MEMORY

      setState(() {
        faceImages.add(
          imageValue,
        );

        faceEmbeddings.add(
          List<double>.from(
            embedding,
          ),
        );
      });

      debugPrint(
        '========================================',
      );

      debugPrint(
        '📷 Child face sample captured',
      );

      debugPrint(
        'Face images: ${faceImages.length}',
      );

      debugPrint(
        'Face embeddings: ${faceEmbeddings.length}',
      );

      debugPrint(
        'Embedding length: ${embedding.length}',
      );

      debugPrint(
        '========================================',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Face sample ${faceImages.length} captured successfully',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Child face capture error: $e',
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
            'Camera error: $e',
          ),
        ),
      );
    }
  }

  // REMOVE FACE SAMPLE

  void _removeFace(int index) {
    if (_loading) {
      return;
    }

    if (index < 0 ||
        index >= faceImages.length ||
        index >= faceEmbeddings.length) {
      return;
    }

    setState(() {
      faceImages.removeAt(index);

      faceEmbeddings.removeAt(index);
    });

    debugPrint(
      '🗑️ Child face sample removed',
    );

    debugPrint(
      'Remaining images: ${faceImages.length}',
    );

    debugPrint(
      'Remaining embeddings: ${faceEmbeddings.length}',
    );
  }


  // SAVE CHILD FACE

  Future<void> _saveFace() async {
    // CHECK 3 FACE SAMPLES

    if (faceImages.length < 3 ||
        faceEmbeddings.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
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
          backgroundColor: Colors.red,
          content: Text(
            'Face images and embeddings do not match',
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      debugPrint(
        '========== SAVE CHILD FACE START ==========',
      );

      debugPrint(
        '📷 Face images: ${faceImages.length}',
      );

      debugPrint(
        '🧠 Face embeddings: ${faceEmbeddings.length}',
      );

      // VALIDATE ALL 3 EMBEDDINGS

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

      // CHECK ALL IMAGE FILES

      for (int i = 0; i < 3; i++) {
        final exists =
        await faceImages[i].exists();

        if (!exists) {
          throw Exception(
            'Face image ${i + 1} not found',
          );
        }
      }

      // SAVE FIRST IMAGE AS DISPLAY IMAGE

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

          // DISPLAY IMAGE

          'imageData': imageData,

          // LIVE CAMERA EMBEDDINGS

          'embedding1':
          faceEmbeddings[0],

          'embedding2':
          faceEmbeddings[1],

          'embedding3':
          faceEmbeddings[2],

          // REGISTRATION DETAILS

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

      // RETURN SUCCESS

      Navigator.pop(
        context,
        true,
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
          backgroundColor: Colors.red,
          content: Text(
            'Error saving child face: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xffF7F3FF),

      appBar: AppBar(
        title: const Text(
          'Child Face Registration',
        ),
        centerTitle: true,
        backgroundColor:
        Colors.deepPurple,
        foregroundColor:
        Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(20),

          child: Card(
            elevation: 8,

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(25),
            ),

            child: Padding(
              padding:
              const EdgeInsets.all(24),

              child: Column(
                children: [
                  // MAIN IMAGE

                  CircleAvatar(
                    radius: 70,

                    backgroundColor:
                    Colors.deepPurple.shade100,

                    backgroundImage:
                    faceImages.isNotEmpty
                        ? FileImage(
                      faceImages.first,
                    )
                        : null,

                    child:
                    faceImages.isEmpty
                        ? const Icon(
                      Icons.child_care,
                      size: 70,
                      color:
                      Colors.deepPurple,
                    )
                        : null,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // TITLE

                  const Text(
                    'Register Child Face',

                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Capture three live face samples. '
                        'Each sample is scanned and converted to a face embedding immediately.',

                    textAlign:
                    TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // PROGRESS

                  LinearProgressIndicator(
                    value:
                    faceImages.length / 3,

                    minHeight: 10,

                    borderRadius:
                    BorderRadius.circular(20),

                    backgroundColor:
                    Colors.grey.shade300,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    '${faceImages.length} of 3 Face Samples Captured',

                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // CAPTURED FACE SAMPLES

                  if (faceImages.isNotEmpty)
                    SizedBox(
                      height: 115,

                      child: ListView.builder(
                        scrollDirection:
                        Axis.horizontal,

                        itemCount:
                        faceImages.length,

                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(
                              right: 12,
                            ),

                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(
                                    15,
                                  ),

                                  child: Image.file(
                                    faceImages[index],

                                    width: 90,
                                    height: 90,

                                    fit:
                                    BoxFit.cover,
                                  ),
                                ),

                                Positioned(
                                  top: 2,
                                  right: 2,

                                  child:
                                  GestureDetector(
                                    onTap:
                                    _loading
                                        ? null
                                        : () {
                                      _removeFace(
                                        index,
                                      );
                                    },

                                    child: Container(
                                      padding:
                                      const EdgeInsets.all(
                                        4,
                                      ),

                                      decoration:
                                      const BoxDecoration(
                                        color:
                                        Colors.red,
                                        shape:
                                        BoxShape.circle,
                                      ),

                                      child:
                                      const Icon(
                                        Icons.close,
                                        color:
                                        Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,

                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color:
                                      Colors.black.withValues(
                                        alpha: 0.6,
                                      ),

                                      borderRadius:
                                      const BorderRadius.only(
                                        bottomLeft:
                                        Radius.circular(
                                          15,
                                        ),

                                        bottomRight:
                                        Radius.circular(
                                          15,
                                        ),
                                      ),
                                    ),

                                    child: Text(
                                      'Sample ${index + 1}',

                                      textAlign:
                                      TextAlign.center,

                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  if (faceImages.isNotEmpty)
                    const SizedBox(
                      height: 20,
                    ),

                  // INFORMATION

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(16),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.deepPurple.shade50,

                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                          Colors.deepPurple,
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        Text(
                          'Look directly at the camera.\n'
                              'Keep your face clearly visible.\n'
                              'Capture slightly different angles for better recognition.',

                          textAlign:
                          TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // CAPTURE BUTTON

                  SizedBox(
                    width:
                    double.infinity,

                    height: 55,

                    child:
                    ElevatedButton.icon(
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
                            16,
                          ),
                        ),
                      ),

                      onPressed:
                      _loading ||
                          faceImages.length >= 3
                          ? null
                          : _captureFace,

                      icon:
                      const Icon(
                        Icons.camera_alt,
                      ),

                      label: Text(
                        faceImages.length >= 3
                            ? '3 Samples Captured'
                            : 'Capture Face '
                            '(${faceImages.length + 1}/3)',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // SAVE BUTTON

                  SizedBox(
                    width:
                    double.infinity,

                    height: 55,

                    child:
                    ElevatedButton.icon(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,

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
                      _loading
                          ? null
                          : _saveFace,

                      icon:
                      const Icon(
                        Icons.save,
                      ),

                      label: Text(
                        _loading
                            ? 'Saving...'
                            : 'Save Registration',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  if (_loading)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}