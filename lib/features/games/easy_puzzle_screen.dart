import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class EasyPuzzleScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const EasyPuzzleScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<EasyPuzzleScreen> createState() => _EasyPuzzleScreenState();
}

class _EasyPuzzleScreenState extends State<EasyPuzzleScreen> {
  final Random _random = Random();

  final AudioPlayer _soundPlayer = AudioPlayer();

  final ActivityService _activityService = ActivityService();

  static const int totalPieces = 6;

  final List<PuzzleItem> _items = const [
    PuzzleItem(
      id: 'sun',
      emoji: '☀️',
      name: 'Sun',
    ),
    PuzzleItem(
      id: 'star',
      emoji: '⭐',
      name: 'Star',
    ),
    PuzzleItem(
      id: 'heart',
      emoji: '❤️',
      name: 'Heart',
    ),
    PuzzleItem(
      id: 'flower',
      emoji: '🌸',
      name: 'Flower',
    ),
    PuzzleItem(
      id: 'rainbow',
      emoji: '🌈',
      name: 'Rainbow',
    ),
    PuzzleItem(
      id: 'butterfly',
      emoji: '🦋',
      name: 'Butterfly',
    ),
  ];

  List<PuzzleItem> _pieces = [];

  List<PuzzleItem> _slots = [];

  String? _selectedPieceId;

  final Set<String> _completedPieces = {};

  // GAME ANALYTICS


  int _score = 0;

  int _attempts = 0;

  int _correctAnswers = 0;

  int _wrongAnswers = 0;


  // GAME STATE


  bool _isStarted = false;

  bool _isFinished = false;

  bool _isLocked = false;

  bool _isSaving = false;

  DateTime? _startedAt;

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }


  // PLAY SOUND


  Future<void> _playSound(String fileName) async {
    try {
      await _soundPlayer.stop();

      await _soundPlayer.play(
        AssetSource('sounds/$fileName'),
      );
    } catch (e) {
      debugPrint(
        'Easy Puzzle sound error: $e',
      );
    }
  }


  // START GAME


  void _startGame() {
    final shuffledPieces =
    List<PuzzleItem>.from(_items)
      ..shuffle(_random);

    final shuffledSlots =
    List<PuzzleItem>.from(_items)
      ..shuffle(_random);

    setState(() {
      _pieces = shuffledPieces;

      _slots = shuffledSlots;

      _selectedPieceId = null;

      _completedPieces.clear();

      // Reset analytics
      _score = 0;
      _attempts = 0;
      _correctAnswers = 0;
      _wrongAnswers = 0;

      // Reset state
      _isStarted = true;
      _isFinished = false;
      _isLocked = false;
      _isSaving = false;

      _startedAt = DateTime.now();
    });
  }


  // SELECT PUZZLE PIECE


  void _selectPiece(PuzzleItem piece) {
    if (_isLocked ||
        _isFinished ||
        !_isStarted ||
        _completedPieces.contains(piece.id)) {
      return;
    }

    setState(() {
      _selectedPieceId = piece.id;
    });
  }


  // SELECT MATCHING SLOT


  Future<void> _selectSlot(
      PuzzleItem slot,
      ) async {
    if (_isLocked ||
        _isFinished ||
        !_isStarted ||
        _selectedPieceId == null ||
        _completedPieces.contains(slot.id)) {
      return;
    }

    // Lock screen + count attempt
    setState(() {
      _isLocked = true;

      _attempts++;
    });

    final bool isCorrect =
        _selectedPieceId == slot.id;


    // CORRECT ANSWER


    if (isCorrect) {
      setState(() {
        _completedPieces.add(slot.id);

        _score++;

        _correctAnswers++;

        _selectedPieceId = null;
      });

      await _playSound(
        'success.mp3',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      if (!mounted) return;

      // Check if all puzzle pieces completed
      if (_completedPieces.length >= totalPieces) {
        await _finishGame();

        return;
      }

      setState(() {
        _isLocked = false;
      });
    }


    // WRONG ANSWER


    else {
      setState(() {
        _wrongAnswers++;
      });

      await _playSound(
        'try_again.mp3',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isLocked = false;
      });
    }
  }


  // CALCULATE ACCURACY


  double _calculateAccuracy() {
    if (_attempts == 0) {
      return 0.0;
    }

    return (
        _correctAnswers / _attempts
    ) *
        100;
  }


  // SAVE RESULT


  Future<void> _saveResult() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      final startedAt =
          _startedAt ?? DateTime.now();

      final duration =
          DateTime.now()
              .difference(startedAt)
              .inSeconds;

      final double accuracy =
      _calculateAccuracy();

      final session =
      ActivitySessionModel(
        childId: widget.childId,

        activityName: 'Easy Puzzle',

        activityType: 'puzzle_game',

        emotion: widget.emotion,

        score: _score,

        durationSeconds: duration,

        // Required analytics fields
        accuracy: accuracy,

        attempts: _attempts,

        correctAnswers: _correctAnswers,

        wrongAnswers: _wrongAnswers,

        totalRounds: totalPieces,

        completed: true,

        completedAt: DateTime.now(),
      );

      await _activityService
          .saveActivitySession(
        session,
      );

      debugPrint(
        'Easy Puzzle game saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Easy Puzzle save error: $e',
      );
    } finally {
      _isSaving = false;
    }
  }


  // FINISH GAME


  Future<void> _finishGame() async {
    if (_isFinished) return;

    setState(() {
      _isStarted = false;

      _isFinished = true;

      _isLocked = true;

      _selectedPieceId = null;
    });

    await _playSound(
      'success.mp3',
    );

    await _saveResult();

    if (!mounted) return;

    await Future.delayed(
      const Duration(
        milliseconds: 400,
      ),
    );

    if (!mounted) return;

    _showResultDialog();
  }


  // RESULT DIALOG


  void _showResultDialog() {
    final accuracy =
    _calculateAccuracy();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(30),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(26),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Text(
                  '🧩🎉',
                  style: TextStyle(
                    fontSize: 75,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                const Text(
                  'Amazing!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                    color: Color(
                      0xFF7B61FF,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'You completed all '
                      '$totalPieces puzzle matches!',
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color:
                    Colors.black54,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  decoration:
                  BoxDecoration(
                    color: const Color(
                      0xFFF4F0FF,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Score',
                        style: TextStyle(
                          color:
                          Colors.black54,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        '$_score / $totalPieces ⭐',
                        style:
                        const TextStyle(
                          fontSize: 34,
                          fontWeight:
                          FontWeight.bold,
                          color: Color(
                            0xFF7B61FF,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        'Accuracy: '
                            '${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                          color: Color(
                            0xFF5B3FA6,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'Attempts: $_attempts',
                        style: const TextStyle(
                          color:
                          Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  height: 55,
                  child:
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );

                      _startGame();
                    },
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF7B61FF,
                      ),
                      foregroundColor:
                      Colors.white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );

                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    'Exit Game',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // HEADER

  Widget _buildHeader() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(
                0xFF5B3FA6,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          const Expanded(
            child: Text(
              '🧩 Easy Puzzle',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
                color: Color(
                  0xFF5B3FA6,
                ),
              ),
            ),
          ),

          if (_isStarted)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Text(
                '$_score/$totalPieces',
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: Color(
                    0xFF7B61FF,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  // START SCREEN


  Widget _buildStartScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Text(
              '🧩',
              style: TextStyle(
                fontSize: 95,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Easy Puzzle!',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                FontWeight.bold,
                color: Color(
                  0xFF5B3FA6,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Choose a puzzle piece and '
                  'find the matching picture!',
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

            SizedBox(
              width:
              double.infinity,
              height: 58,
              child:
              ElevatedButton.icon(
                onPressed:
                _startGame,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF7B61FF,
                  ),
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text(
                  'Start Playing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // GAME SCREEN


  Widget _buildGameScreen() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),

        const Text(
          'Match the puzzle pieces!',
          style: TextStyle(
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
            color: Color(
              0xFF5B3FA6,
            ),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          _selectedPieceId == null
              ? 'Choose a puzzle piece'
              : 'Now find the matching picture!',
          style: const TextStyle(
            fontSize: 16,
            color:
            Colors.black54,
          ),
        ),

        const SizedBox(
          height: 20,
        ),


        // PUZZLE PIECES

        SizedBox(
          height: 125,
          child:
          ListView.separated(
            scrollDirection:
            Axis.horizontal,
            itemCount:
            _pieces.length,
            separatorBuilder:
                (_, __) =>
            const SizedBox(
              width: 12,
            ),
            itemBuilder:
                (context, index) {
              final piece =
              _pieces[index];

              final isCompleted =
              _completedPieces
                  .contains(
                piece.id,
              );

              final isSelected =
                  _selectedPieceId ==
                      piece.id;

              return GestureDetector(
                onTap:
                isCompleted ||
                    _isLocked
                    ? null
                    : () =>
                    _selectPiece(
                      piece,
                    ),
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 250,
                  ),
                  width: 110,
                  decoration:
                  BoxDecoration(
                    color: isCompleted
                        ? Colors
                        .green
                        .shade50
                        : isSelected
                        ? const Color(
                      0xFFE6DFFF,
                    )
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),
                    border:
                    Border.all(
                      color: isSelected
                          ? const Color(
                        0xFF7B61FF,
                      )
                          : isCompleted
                          ? Colors.green
                          : const Color(
                        0xFFE1D8F5,
                      ),
                      width:
                      isSelected
                          ? 3
                          : 2,
                    ),
                    boxShadow:
                    isSelected
                        ? const [
                      BoxShadow(
                        color:
                        Colors
                            .black12,
                        blurRadius:
                        8,
                        offset:
                        Offset(
                          0,
                          3,
                        ),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                      Colors.green,
                      size: 40,
                    )
                        : Text(
                      piece.emoji,
                      style:
                      const TextStyle(
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(
          height: 25,
        ),


        // MATCHING SLOTS


        Expanded(
          child:
          GridView.builder(
            itemCount:
            _slots.length,
            physics:
            const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder:
                (context, index) {
              final slot =
              _slots[index];

              final isCompleted =
              _completedPieces
                  .contains(
                slot.id,
              );

              return GestureDetector(
                onTap:
                isCompleted ||
                    _isLocked
                    ? null
                    : () =>
                    _selectSlot(
                      slot,
                    ),
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 250,
                  ),
                  decoration:
                  BoxDecoration(
                    color: isCompleted
                        ? const Color(
                      0xFFE8F5E9,
                    )
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      25,
                    ),
                    border:
                    Border.all(
                      color: isCompleted
                          ? Colors.green
                          : const Color(
                        0xFFE1D8F5,
                      ),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                      Colors.green,
                      size: 45,
                    )
                        : Text(
                      slot.emoji,
                      style:
                      const TextStyle(
                        fontSize: 58,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(
          height: 12,
        ),


        // SCORE

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                'Score: $_score / $totalPieces ⭐',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.bold,
                  color: Color(
                    0xFF7B61FF,
                  ),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                'Attempts: $_attempts',
                style: const TextStyle(
                  fontSize: 13,
                  color:
                  Colors.black54,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 10,
        ),
      ],
    );
  }


  // MAIN BUILD


  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF8F6FF,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  20,
                ),
                child: !_isStarted &&
                    !_isFinished
                    ? _buildStartScreen()
                    : _buildGameScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// PUZZLE ITEM MODEL


class PuzzleItem {
  final String id;

  final String emoji;

  final String name;

  const PuzzleItem({
    required this.id,
    required this.emoji,
    required this.name,
  });
}