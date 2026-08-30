import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class BalloonPopGameScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const BalloonPopGameScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<BalloonPopGameScreen> createState() =>
      _BalloonPopGameScreenState();
}

class _BalloonPopGameScreenState extends State<BalloonPopGameScreen> {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  Timer? _gameTimer;
  DateTime? _gameStartedAt;

  final List<_BalloonData> balloons = [];

  final List<Color> balloonColors = [
    const Color(0xFFFF8FAB),
    const Color(0xFFFFC857),
    const Color(0xFF7BDFF2),
    const Color(0xFFA0E7A0),
    const Color(0xFFCDB4DB),
    const Color(0xFFBDE0FE),
  ];

  int score = 0;
  int timeLeft = 30;

  // ANALYTICS

  int attempts = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  static const int targetScore = 10;

  bool isGameStarted = false;
  bool isGameOver = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // SOUND METHODS

  Future<void> _playPopSound() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource('sounds/pop.mp3'),
      );
    } catch (e) {
      debugPrint('Pop sound error: $e');
    }
  }

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

  // START GAME

  void startGame() {
    _gameTimer?.cancel();

    setState(() {
      score = 0;
      timeLeft = 30;

      attempts = 0;
      correctAnswers = 0;
      wrongAnswers = 0;

      isGameStarted = true;
      isGameOver = false;
      _isSaving = false;

      balloons.clear();

      _gameStartedAt = DateTime.now();
    });

    // Initial balloons
    for (int i = 0; i < 4; i++) {
      _spawnBalloon();
    }

    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted || !isGameStarted || isGameOver) {
          timer.cancel();
          return;
        }

        if (timeLeft <= 1) {
          endGame();
          return;
        }

        setState(() {
          timeLeft--;

          if (_random.nextBool()) {
            _spawnBalloon();
          }
        });
      },
    );
  }

  // SPAWN BALLOON

  void _spawnBalloon() {
    if (balloons.length >= 10) return;

    final size = 55 + (_random.nextDouble() * 35);

    balloons.add(
      _BalloonData(
        id:
        '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(99999)}',
        left: 0.03 + (_random.nextDouble() * 0.78),
        top: 0.03 + (_random.nextDouble() * 0.70),
        size: size,
        color: balloonColors[
        _random.nextInt(balloonColors.length)],
      ),
    );
  }

  // POP BALLOON

  void popBalloon(String id) {
    if (!isGameStarted || isGameOver) return;

    final balloonIndex = balloons.indexWhere(
          (balloon) => balloon.id == id,
    );

    if (balloonIndex == -1) return;

    final balloon = balloons[balloonIndex];

    if (balloon.isPopping) return;

    _playPopSound();

    setState(() {
      balloon.isPopping = true;

      score++;

      // Analytics
      attempts++;
      correctAnswers++;
    });

    Future.delayed(
      const Duration(milliseconds: 180),
          () {
        if (!mounted || isGameOver) return;

        setState(() {
          balloons.removeWhere(
                (balloon) => balloon.id == id,
          );

          if (_random.nextBool()) {
            _spawnBalloon();
          }
        });
      },
    );
  }

  // CALCULATE ACCURACY

  double _calculateAccuracy() {
    if (attempts == 0) {
      return 0.0;
    }

    return (correctAnswers / attempts) * 100;
  }

  // SAVE GAME RESULT

  Future<void> _saveActivityResult() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      final startedAt =
          _gameStartedAt ?? DateTime.now();

      final duration =
          DateTime.now().difference(startedAt).inSeconds;

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Balloon Pop',
        activityType: 'game',
        emotion: widget.emotion,
        score: score,
        durationSeconds: duration,

        // Required analytics fields
        accuracy: _calculateAccuracy(),
        attempts: attempts,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        totalRounds: targetScore,

        completed: true,
        completedAt: DateTime.now(),
      );

      await _activityService.saveActivitySession(
        session,
      );

      debugPrint(
        'Balloon Pop result saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Activity save error: $e',
      );
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
      balloons.clear();
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
    final String title =
    reachedTarget ? 'Wow! Great Job!' : 'Good Try!';

    final String emoji =
    reachedTarget ? '🎉' : '🌟';

    final String message = reachedTarget
        ? 'Amazing! You reached the target!'
        : 'You can try again and pop even more balloons!';

    final accuracy = _calculateAccuracy();

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
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
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
                    fontSize: 27,
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
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$score 🎈',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B61FF),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Target: $targetScore balloons',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
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
                    style: TextStyle(
                      color: Color(0xFF7B61FF),
                      fontWeight: FontWeight.w600,
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
      backgroundColor: const Color(0xFFF7F3FF),
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
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    20,
                  ),
                  child: !isGameStarted && !isGameOver
                      ? _buildStartScreen()
                      : _buildGameArea(),
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
      padding:
      const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
              '🎈 Balloon Pop',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
          ),

          if (isGameStarted)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '⏱ $timeLeft',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎈',
              style: TextStyle(fontSize: 100),
            ),

            const SizedBox(height: 14),

            const Text(
              'Balloon Pop!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Tap as many balloons as you can before time runs out!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 28,
                ),
                label: const Text(
                  'Start Playing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // GAME AREA

  Widget _buildGameArea() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.star_rounded,
                label: 'Score',
                value: '$score',
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                icon: Icons.timer_rounded,
                label: 'Time',
                value: '$timeLeft',
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE0D7FF),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      for (final balloon in balloons)
                        Positioned(
                          left: balloon.left *
                              constraints.maxWidth,
                          top: balloon.top *
                              constraints.maxHeight,
                          child: GestureDetector(
                            onTap: () =>
                                popBalloon(balloon.id),
                            child: AnimatedScale(
                              scale: balloon.isPopping
                                  ? 1.45
                                  : 1.0,
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              curve: Curves.easeOutBack,
                              child: AnimatedOpacity(
                                opacity: balloon.isPopping
                                    ? 0.0
                                    : 1.0,
                                duration: const Duration(
                                  milliseconds: 180,
                                ),
                                child: _Balloon(
                                  size: balloon.size,
                                  color: balloon.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // STAT CARD


  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  fontWeight: FontWeight.bold,
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

// BALLOON DATA

class _BalloonData {
  final String id;
  final double left;
  final double top;
  final double size;
  final Color color;

  bool isPopping;

  _BalloonData({
    required this.id,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    this.isPopping = false,
  });
}

// BALLOON WIDGET

class _Balloon extends StatelessWidget {
  final double size;
  final Color color;

  const _Balloon({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.38,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size),
                topRight: Radius.circular(size),
                bottomLeft:
                Radius.circular(size * 0.72),
                bottomRight:
                Radius.circular(size * 0.72),
              ),
            ),
          ),

          Positioned(
            top: size * 0.90,
            child: Transform.rotate(
              angle: pi / 4,
              child: Container(
                width: size * 0.18,
                height: size * 0.18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                  BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          Positioned(
            top: size,
            child: Container(
              width: 2,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}