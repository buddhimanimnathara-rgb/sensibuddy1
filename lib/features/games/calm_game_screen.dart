import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class CalmGameScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const CalmGameScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<CalmGameScreen> createState() => _CalmGameScreenState();
}

class _CalmGameScreenState extends State<CalmGameScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  DateTime? _startedAt;

  int completedRounds = 0;

  // Analytics
  int attempts = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  static const int totalRounds = 5;

  bool isStarted = false;
  bool isCompleted = false;
  bool isBreathingIn = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathingAnimation = Tween<double>(
      begin: 0.70,
      end: 1.25,
    ).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // SUCCESS SOUND

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource('sounds/success.mp3'),
      );
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  // START GAME

  void startGame() {
    _breathingController.stop();
    _breathingController.reset();

    setState(() {
      completedRounds = 0;

      attempts = 0;
      correctAnswers = 0;
      wrongAnswers = 0;

      isStarted = true;
      isCompleted = false;
      isBreathingIn = true;
      _isSaving = false;

      _startedAt = DateTime.now();
    });

    _startBreathingCycle();
  }

  // BREATHING CYCLE

  void _startBreathingCycle() {
    if (!mounted || isCompleted || !isStarted) {
      return;
    }

    setState(() {
      isBreathingIn = true;
    });

    _breathingController.forward(from: 0);

    Future.delayed(
      const Duration(seconds: 4),
          () {
        if (!mounted || isCompleted || !isStarted) {
          return;
        }

        setState(() {
          isBreathingIn = false;
        });

        _breathingController.reverse();

        Future.delayed(
          const Duration(seconds: 4),
              () {
            if (!mounted || isCompleted || !isStarted) {
              return;
            }

            setState(() {
              completedRounds++;

              // Each completed breathing round
              // counts as one successful attempt.
              attempts++;
              correctAnswers++;
            });

            if (completedRounds >= totalRounds) {
              finishGame();
            } else {
              _startBreathingCycle();
            }
          },
        );
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

  // SAVE RESULT

  Future<void> _saveGameResult() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final startedAt = _startedAt ?? DateTime.now();

      final duration =
          DateTime.now().difference(startedAt).inSeconds;

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Calm Game',
        activityType: 'calming_activity',
        emotion: widget.emotion,
        score: completedRounds,
        durationSeconds: duration,

        // REQUIRED ANALYTICS
        accuracy: _calculateAccuracy(),
        attempts: attempts,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        totalRounds: totalRounds,

        completed: completedRounds >= totalRounds,
        completedAt: DateTime.now(),
      );

      await _activityService.saveActivitySession(
        session,
      );

      debugPrint('Calm Game result saved');
    } catch (e) {
      debugPrint('Calm Game save error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // FINISH GAME

  Future<void> finishGame() async {
    if (isCompleted) {
      return;
    }

    _breathingController.stop();

    setState(() {
      isStarted = false;
      isCompleted = true;
      isBreathingIn = false;
    });

    await _playSuccessSound();

    await _saveGameResult();

    if (!mounted) {
      return;
    }

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) {
      return;
    }

    _showResultDialog();
  }

  // RESULT DIALOG

  void _showResultDialog() {
    final accuracy = _calculateAccuracy();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🌈',
                  style: TextStyle(
                    fontSize: 75,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Wonderful!',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B3FA6),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'You completed all your calm breathing rounds!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Completed Rounds',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '$completedRounds / $totalRounds 🌿',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B61FF),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Attempts: $attempts',
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
                      startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {
                _breathingController.stop();
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
              '🌿 Calm Game',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
          ),

          if (isStarted)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$completedRounds/$totalRounds',
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

  // START SCREEN

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌿',
              style: TextStyle(
                fontSize: 90,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Calm Breathing',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Follow the circle. Breathe in slowly and breathe out gently.',
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
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text(
                  'Start Breathing',
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

  // GAME SCREEN

  Widget _buildGameScreen() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Text(
          isBreathingIn
              ? 'Breathe In 🌬️'
              : 'Breathe Out 😌',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          isBreathingIn
              ? 'Slowly breathe in...'
              : 'Slowly breathe out...',
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black54,
          ),
        ),

        const Spacer(),

        AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB8F2E6),
                  Color(0xFF7B61FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B61FF)
                      .withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                isBreathingIn ? 'IN' : 'OUT',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Text(
                'Breathing Progress',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '$completedRounds / $totalRounds Rounds',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B61FF),
                ),
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completedRounds / totalRounds,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFEDE7F6),
                  color: const Color(0xFF7B61FF),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  // MAIN BUILD

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
              Color(0xFFE6DCF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: !isStarted && !isCompleted
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
}