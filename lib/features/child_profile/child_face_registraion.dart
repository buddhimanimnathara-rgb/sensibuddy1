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
  final List<File> faceImages = [];
  final List<List<double>> faceEmbeddings = [];

  bool _loading = false;
  bool _cameraOpening = false;

  int get currentSample {
    if (faceImages.length >= 3) {
      return 3;
    }
    return faceImages.length + 1;
  }

  bool _isSampleCompleted(int index) {
    return index >= 0 &&
        index < faceImages.length &&
        index < faceEmbeddings.length &&
        faceEmbeddings[index].length == 192;
  }

  Future<void> _captureFace({int? sampleIndex}) async {
    if (_loading || _cameraOpening) {
      return;
    }

    final int targetIndex =
        sampleIndex ?? faceImages.length;

    if (targetIndex < 0 || targetIndex >= 3) {
      return;
    }

    setState(() {
      _cameraOpening = true;
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

      if (result == null) {
        return;
      }

      final dynamic imageValue = result['image'];
      final dynamic embeddingValue =
      result['embedding'];

      if (imageValue is! File) {
        throw Exception(
          'Captured face image is invalid.',
        );
      }

      if (embeddingValue is! List) {
        throw Exception(
          'Captured face embedding is invalid.',
        );
      }

      final File image = imageValue;

      if (!await image.exists()) {
        throw Exception(
          'Captured image file not found.',
        );
      }

      if (await image.length() <= 0) {
        throw Exception(
          'Captured image is empty.',
        );
      }

      final List<double> embedding =
      embeddingValue.map<double>((value) {
        if (value is num) {
          return value.toDouble();
        }

        final parsed =
        double.tryParse(value.toString());

        if (parsed == null) {
          throw Exception(
            'Invalid embedding value.',
          );
        }

        return parsed;
      }).toList();

      if (embedding.length != 192) {
        throw Exception(
          'Invalid embedding length: '
              '${embedding.length}. Expected 192.',
        );
      }

      for (final value in embedding) {
        if (!value.isFinite) {
          throw Exception(
            'Face embedding contains invalid values.',
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (targetIndex < faceImages.length) {
          faceImages[targetIndex] = image;
          faceEmbeddings[targetIndex] =
          List<double>.from(embedding);
        } else {
          faceImages.add(image);
          faceEmbeddings.add(
            List<double>.from(embedding),
          );
        }
      });

      debugPrint(
        'Child face sample ${targetIndex + 1} ready.',
      );

      debugPrint(
        'Images: ${faceImages.length}',
      );

      debugPrint(
        'Embeddings: ${faceEmbeddings.length}',
      );

      debugPrint(
        'Embedding dimension: ${embedding.length}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            sampleIndex == null
                ? 'Face Sample ${targetIndex + 1} captured successfully.'
                : 'Face Sample ${targetIndex + 1} updated successfully.',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Child face capture error: $e',
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
            'Camera error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cameraOpening = false;
        });
      }
    }
  }

  Future<void> _removeFace(int index) async {
    if (_loading || _cameraOpening) {
      return;
    }

    if (index < 0 ||
        index >= faceImages.length ||
        index >= faceEmbeddings.length) {
      return;
    }

    final File oldImage = faceImages[index];

    setState(() {
      faceImages.removeAt(index);
      faceEmbeddings.removeAt(index);
    });

    try {
      if (await oldImage.exists()) {
        await oldImage.delete();
      }
    } catch (e) {
      debugPrint(
        'Temporary image delete failed: $e',
      );
    }

    debugPrint(
      'Child face sample ${index + 1} removed.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Face Sample ${index + 1} removed.',
        ),
      ),
    );
  }

  Future<void> _saveFace() async {
    if (faceImages.length != 3 ||
        faceEmbeddings.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'Please capture all 3 face samples.',
          ),
        ),
      );
      return;
    }

    if (faceImages.length !=
        faceEmbeddings.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Face images and embeddings do not match.',
          ),
        ),
      );
      return;
    }

    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      for (int i = 0; i < 3; i++) {
        if (!await faceImages[i].exists()) {
          throw Exception(
            'Face image ${i + 1} not found.',
          );
        }

        if (await faceImages[i].length() <= 0) {
          throw Exception(
            'Face image ${i + 1} is empty.',
          );
        }

        if (faceEmbeddings[i].length != 192) {
          throw Exception(
            'Invalid embedding ${i + 1}: '
                '${faceEmbeddings[i].length}. Expected 192.',
          );
        }

        for (final value in faceEmbeddings[i]) {
          if (!value.isFinite) {
            throw Exception(
              'Embedding ${i + 1} contains invalid values.',
            );
          }
        }
      }

      final bytes =
      await faceImages.first.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'First face image is empty.',
        );
      }

      final String imageData =
      base64Encode(bytes);

      await firestoreService.saveChildFace(
        widget.childId,
        {
          'childId': widget.childId,
          'imageData': imageData,
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
          'registered': true,
          'faceCount': faceImages.length,
          'embeddingCount':
          faceEmbeddings.length,
          'createdAt':
          DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
        'Child face registration saved successfully.',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Child face registered successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint(
        'Child face save error: $e',
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
          _loading = false;
        });
      }
    }
  }

  Widget _buildSampleCard(int sample) {
    final int index = sample - 1;
    final bool completed =
    _isSampleCompleted(index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
          Container(
            width: 65,
            height: 65,
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
              size: 35,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 12),
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
          if (completed)
            OutlinedButton(
              onPressed:
              _loading ||
                  _cameraOpening
                  ? null
                  : () {
                _captureFace(
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

  @override
  Widget build(BuildContext context) {
    final bool allSamplesCaptured =
        faceImages.length == 3 &&
            faceEmbeddings.length == 3;

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
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                      color: Colors
                          .deepPurple,
                    )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Register Child Face',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture three clear live face samples. '
                        'You can retake any sample if the photo is not clear.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  LinearProgressIndicator(
                    value:
                    faceImages.length / 3,
                    minHeight: 10,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                    backgroundColor:
                    Colors.grey.shade300,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${faceImages.length} of 3 Face Samples Captured',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSampleCard(1),
                  const SizedBox(height: 10),
                  _buildSampleCard(2),
                  const SizedBox(height: 10),
                  _buildSampleCard(3),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      16,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors
                          .deepPurple.shade50,
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                          Colors.deepPurple,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Look directly at the camera.\n'
                              'Keep the child\'s face clearly visible.\n'
                              'Capture slightly different angles for better recognition.',
                          textAlign:
                          TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
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
                          _cameraOpening ||
                          faceImages.length >=
                              3
                          ? null
                          : () {
                        _captureFace();
                      },
                      icon: _cameraOpening
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          color:
                          Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.camera_alt,
                      ),
                      label: Text(
                        _cameraOpening
                            ? 'Opening Camera...'
                            : faceImages.length >= 3
                            ? '3 Samples Captured'
                            : 'Capture Sample $currentSample',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
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
                      _loading ||
                          !allSamplesCaptured
                          ? null
                          : _saveFace,
                      icon: const Icon(
                        Icons.save,
                      ),
                      label: _loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          color:
                          Colors.white,
                        ),
                      )
                          : const Text(
                        'Save Registration',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}