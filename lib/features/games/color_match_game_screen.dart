import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class ColorMatchGameScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const ColorMatchGameScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<ColorMatchGameScreen> createState() =>
      _ColorMatchGameScreenState();
}

class _ColorMatchGameScreenState extends State<ColorMatchGameScreen> {
  final Random _random = Random();

  final AudioPlayer _audioPlayer = AudioPlayer();

  final ActivityService _activityService = ActivityService();

  Timer? _gameTimer;
  DateTime? _gameStartedAt;

  int score = 0;
  int timeLeft = 30;
  int questionNumber = 1;

  // ACTIVITY ANALYTICS

  int attempts = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  static const int targetScore = 8;

  bool isGameStarted = false;
  bool isGameOver = false;
  bool _isSaving = false;
  bool _isAnswerLocked = false;

  late Color targetColor;
  late String targetColorName;

  final List<Map<String, dynamic>> colors = [
    {
      'name': 'Red',
      'color': Colors.red,
    },
    {
      'name': 'Blue',
      'color': Colors.blue,
    },
    {
      'name': 'Green',
      'color': Colors.green,
    },
    {
      'name': 'Yellow',
      'color': Colors.yellow,
    },
    {
      'name': 'Orange',
      'color': Colors.orange,
    },
    {
      'name': 'Purple',
      'color': Colors.purple,
    },
  ];

  List<Map<String, dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }


  // SOUND METHODS

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource('sounds/success.mp3'),
      );
    } catch (e) {
      debugPrint('Success sound error: $e');
    }
  }

  Future<void> _playTryAgainSound() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource('sounds/try_again.mp3'),
      );
    } catch (e) {
      debugPrint('Try again sound error: $e');
    }
  }

  // GENERATE QUESTION

  void _generateQuestion() {
    final selected =
    colors[_random.nextInt(colors.length)];

    targetColor = selected['color'] as Color;
    targetColorName = selected['name'] as String;

    final shuffledColors =
    List<Map<String, dynamic>>.from(colors);

    shuffledColors.shuffle();

    options = shuffledColors.take(4).toList();

    if (!options.any(
          (item) => item['name'] == targetColorName,
    )) {
      options[0] = selected;
      options.shuffle();
    }
  }

  // START GAME

  void startGame() {
    _gameTimer?.cancel();

    setState(() {
      score = 0;
      timeLeft = 30;
      questionNumber = 1;

      // Reset analytics
      attempts = 0;
      correctAnswers = 0;
      wrongAnswers = 0;

      isGameStarted = true;
      isGameOver = false;
      _isAnswerLocked = false;
      _isSaving = false;

      _gameStartedAt = DateTime.now();

      _generateQuestion();
    });

    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted || !isGameStarted) {
          timer.cancel();
          return;
        }

        if (timeLeft <= 1) {
          endGame();
          return;
        }

        setState(() {
          timeLeft--;
        });
      },
    );
  }


  // CHECK ANSWER

  Future<void> _checkAnswer(
      Map<String, dynamic> selectedOption,
      ) async {
    if (_isAnswerLocked ||
        !isGameStarted ||
        isGameOver) {
      return;
    }

    setState(() {
      _isAnswerLocked = true;
      attempts++;
    });

    final bool isCorrect =
        selectedOption['name'] == targetColorName;

    if (isCorrect) {
      setState(() {
        score++;
        correctAnswers++;
      });

      await _playSuccessSound();
    } else {
      setState(() {
        wrongAnswers++;
      });

      await _playTryAgainSound();
    }

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    if (!mounted || isGameOver) return;

    setState(() {
      questionNumber++;
      _isAnswerLocked = false;
      _generateQuestion();
    });
  }

  // CALCULATE ACCURACY


  double _calculateAccuracy() {
    if (attempts == 0) {
      return 0.0;
    }

    return (correctAnswers / attempts) * 100;
  }

  // SAVE RESULT

  Future<void> _saveActivityResult() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      final startedAt =
          _gameStartedAt ?? DateTime.now();

      final duration =
          DateTime.now()
              .difference(startedAt)
              .inSeconds;

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Color Match',
        activityType: 'game',
        emotion: widget.emotion,
        score: score,
        durationSeconds: duration,

        // REQUIRED ANALYTICS
        accuracy: _calculateAccuracy(),
        attempts: attempts,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        totalRounds: questionNumber - 1,

        completed: true,
        completedAt: DateTime.now(),
      );

      await _activityService.saveActivitySession(
        session,
      );

      debugPrint('Color Match result saved');
    } catch (e) {
      debugPrint('Color Match save error: $e');
    } finally {
      _isSaving = false;
    }
  }


  // END GAME

  Future<void> endGame() async {
    if (isGameOver) return;

    _gameTimer?.cancel();

    final bool reachedTarget =
        score >= targetScore;

    setState(() {
      timeLeft = 0;
      isGameStarted = false;
      isGameOver = true;
      _isAnswerLocked = true;
    });

    if (reachedTarget) {
      await _playSuccessSound();
    } else {
      await _playTryAgainSound();
    }

    await _saveActivityResult();

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    _showResultDialog(reachedTarget);
  }

  // RESULT DIALOG


  void _showResultDialog(bool reachedTarget) {
    final String emoji =
    reachedTarget ? '🎉' : '🌟';

    final String title =
    reachedTarget
        ? 'Amazing Job!'
        : 'Good Try!';

    final String message =
    reachedTarget
        ? 'You matched many colors!'
        : 'You can try again and have fun!';

    final double accuracy =
    _calculateAccuracy();

    final int totalRounds =
        questionNumber - 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 70,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B3FA6),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFF4F0FF),
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

                      const SizedBox(height: 5),

                      Text(
                        '$score ⭐',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight:
                          FontWeight.bold,
                          color: Color(0xFF7B61FF),
                        ),
                      ),

                      Text(
                        'Target: $targetScore',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Attempts: $attempts',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      Text(
                        'Correct: $correctAnswers  •  Wrong: $wrongAnswers',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      Text(
                        'Rounds: $totalRounds',
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
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      startGame();
                    },
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

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Exit Game',
                    style: TextStyle(
                      color: Color(0xFF7B61FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // MAIN UI


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F3FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9F7FF),
              Color(0xFFE8E0FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.all(20),
                  child: !isGameStarted &&
                      !isGameOver
                      ? _buildStartScreen()
                      : _buildGameScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // HEADER

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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {
                _gameTimer?.cancel();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF5B3FA6),
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              '🎨 Color Match',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
          ),

          if (isGameStarted)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Text(
                '⏱ $timeLeft',
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: Color(0xFF7B61FF),
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
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎨',
              style: TextStyle(fontSize: 90),
            ),

            const SizedBox(height: 16),

            const Text(
              'Color Match!',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Find and tap the matching color!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: startGame,
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

  // GAME SCREEN

  Widget _buildGameScreen() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.star_rounded,
                'Score',
                '$score',
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                Icons.help_outline_rounded,
                'Round',
                '$questionNumber',
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        const Text(
          'Find this color',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: targetColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                targetColor.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Text(
          targetColorName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 25),

        Expanded(
          child: GridView.builder(
            itemCount: options.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemBuilder: (context, index) {
              final option = options[index];

              return GestureDetector(
                onTap: _isAnswerLocked
                    ? null
                    : () => _checkAnswer(option),
                child: Container(
                  decoration: BoxDecoration(
                    color: option['color'] as Color,
                    borderRadius:
                    BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (option['color']
                        as Color)
                            .withOpacity(0.25),
                        blurRadius: 12,
                        offset:
                        const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // STAT CARD

  Widget _statCard(
      IconData icon,
      String label,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF7B61FF),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.bold,
                  color: Color(0xFF5B3FA6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}