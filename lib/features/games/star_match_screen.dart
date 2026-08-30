import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class StarMatchScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const StarMatchScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<StarMatchScreen> createState() => _StarMatchScreenState();
}

class _StarMatchScreenState extends State<StarMatchScreen> {
  final Random _random = Random();

  final AudioPlayer _soundPlayer = AudioPlayer();

  final ActivityService _activityService = ActivityService();

  static const int totalRounds = 5;

  final List<StarItem> _items = const [
    StarItem(
      id: 'star',
      emoji: '⭐',
      name: 'Star',
    ),
    StarItem(
      id: 'glowing_star',
      emoji: '🌟',
      name: 'Glowing Star',
    ),
    StarItem(
      id: 'sparkles',
      emoji: '✨',
      name: 'Sparkles',
    ),
    StarItem(
      id: 'dizzy',
      emoji: '💫',
      name: 'Dizzy Star',
    ),
    StarItem(
      id: 'moon',
      emoji: '🌙',
      name: 'Moon',
    ),
    StarItem(
      id: 'sun',
      emoji: '☀️',
      name: 'Sun',
    ),
    StarItem(
      id: 'rainbow',
      emoji: '🌈',
      name: 'Rainbow',
    ),
  ];

  List<StarItem> _questions = [];
  List<StarItem> _options = [];

  int _currentRound = 0;

  int _score = 0;

  // ============================================================
  // ANALYTICS
  // ============================================================

  int _correctAnswers = 0;

  int _wrongAnswers = 0;

  int _attempts = 0;

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

  // ============================================================
  // PLAY SOUND
  // ============================================================

  Future<void> _playSound(String fileName) async {
    try {
      await _soundPlayer.stop();

      await _soundPlayer.play(
        AssetSource('sounds/$fileName'),
      );
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  // ============================================================
  // START GAME
  // ============================================================

  void _startGame() {
    final shuffled = List<StarItem>.from(_items)
      ..shuffle(_random);

    setState(() {
      _questions = shuffled.take(totalRounds).toList();

      _currentRound = 0;

      _score = 0;

      // Reset analytics
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _attempts = 0;

      _isStarted = true;
      _isFinished = false;
      _isLocked = false;

      _startedAt = DateTime.now();

      _generateOptions();
    });
  }

  // ============================================================
  // GENERATE OPTIONS
  // ============================================================

  void _generateOptions() {
    if (_questions.isEmpty) return;

    final correctItem = _questions[_currentRound];

    final wrongItems = _items
        .where(
          (item) => item.id != correctItem.id,
    )
        .toList()
      ..shuffle(_random);

    _options = [
      correctItem,
      ...wrongItems.take(2),
    ]..shuffle(_random);
  }

  // ============================================================
  // SELECT ITEM
  // ============================================================

  Future<void> _selectItem(
      StarItem selected,
      ) async {
    if (_isLocked || _isFinished) return;

    _isLocked = true;

    // Every selection is an attempt
    _attempts++;

    final correctItem = _questions[_currentRound];

    final bool isCorrect =
        selected.id == correctItem.id;

    if (isCorrect) {
      setState(() {
        _score++;

        _correctAnswers++;
      });

      await _playSound('success.mp3');

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      if (_currentRound >= totalRounds - 1) {
        await _finishGame();
      } else {
        setState(() {
          _currentRound++;

          _isLocked = false;

          _generateOptions();
        });
      }
    } else {
      setState(() {
        _wrongAnswers++;
      });

      await _playSound('try_again.mp3');

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      setState(() {
        _isLocked = false;
      });
    }
  }

  // ============================================================
  // CALCULATE ACCURACY
  // ============================================================

  double _calculateAccuracy() {
    if (_attempts == 0) return 0;

    return (_correctAnswers / _attempts) * 100;
  }

  // ============================================================
  // SAVE RESULT
  // ============================================================

  Future<void> _saveResult() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      final duration = DateTime.now()
          .difference(
        _startedAt ?? DateTime.now(),
      )
          .inSeconds;

      final accuracy = _calculateAccuracy();

      final session = ActivitySessionModel(
        childId: widget.childId,

        activityName: 'Star Match',

        activityType: 'visual_matching_game',

        emotion: widget.emotion,

        score: _score,

        totalRounds: totalRounds,

        correctAnswers: _correctAnswers,

        wrongAnswers: _wrongAnswers,

        attempts: _attempts,

        accuracy: accuracy,

        durationSeconds: duration,

        completed: true,

        completedAt: DateTime.now(),
      );

      await _activityService.saveActivitySession(
        session,
      );

      debugPrint(
        'Star Match analytics saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Star Match save error: $e',
      );
    } finally {
      _isSaving = false;
    }
  }

  // ============================================================
  // FINISH GAME
  // ============================================================

  Future<void> _finishGame() async {
    if (_isFinished) return;

    setState(() {
      _isStarted = false;

      _isFinished = true;
    });

    await _playSound('success.mp3');

    await _saveResult();

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    _showResultDialog();
  }

  // ============================================================
  // RESULT DIALOG
  // ============================================================

  void _showResultDialog() {
    final accuracy = _calculateAccuracy();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⭐🎉',
                  style: TextStyle(
                    fontSize: 75,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Great Job!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B61FF),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'You matched $_score out of $totalRounds!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0FF),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Score',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '$_score / $totalRounds ⭐',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B61FF),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Correct: $_correctAnswers   Wrong: $_wrongAnswers',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF7B61FF),
                      foregroundColor:
                      Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF5B3FA6),
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Text(
              '⭐ Star Match',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Text(
                '${_currentRound + 1}/$totalRounds',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B61FF),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // START SCREEN
  // ============================================================

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⭐',
              style: TextStyle(
                fontSize: 95,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Star Match',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Look carefully and choose '
                  'the matching item!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _startGame,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF7B61FF),
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(18),
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

  // ============================================================
  // GAME SCREEN
  // ============================================================

  Widget _buildGameScreen() {
    if (_questions.isEmpty) {
      return const SizedBox();
    }

    final target =
    _questions[_currentRound];

    return Column(
      children: [
        const SizedBox(height: 10),

        const Text(
          'Find the matching item!',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: const Color(
              0xFFFFF4D6,
            ),
            borderRadius:
            BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              target.emoji,
              style: const TextStyle(
                fontSize: 80,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Choose the same one',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 30),

        Row(
          children: _options.map(
                (item) {
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      _selectItem(item),
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(25),
                      border: Border.all(
                        color:
                        const Color(0xFFE1D8F5),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(
                          fontSize: 65,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),

        const Spacer(),

        Text(
          'Score: $_score ⭐',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7B61FF),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
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

// ============================================================
// STAR ITEM MODEL
// ============================================================

class StarItem {
  final String id;

  final String emoji;

  final String name;

  const StarItem({
    required this.id,
    required this.emoji,
    required this.name,
  });
}