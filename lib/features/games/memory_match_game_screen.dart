import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class MemoryMatchGameScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const MemoryMatchGameScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<MemoryMatchGameScreen> createState() =>
      _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  Timer? _gameTimer;
  DateTime? _gameStartedAt;

  static const int totalRounds = 6;

  int score = 0;
  int timeLeft = 60;

  // ANALYTICS

  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _attempts = 0;

  bool isGameStarted = false;
  bool isGameOver = false;
  bool _isChecking = false;
  bool _isSaving = false;

  int? _firstSelectedIndex;
  int? _secondSelectedIndex;

  final Random _random = Random();

  final List<String> _baseItems = [
    '🐶',
    '🐱',
    '🦁',
    '🐸',
    '🐼',
    '🦄',
  ];

  List<_MemoryCard> cards = [];

  @override
  void initState() {
    super.initState();
    _createCards();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }


  // SOUND

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


  // CREATE CARDS


  void _createCards() {
    final List<String> values = [
      ..._baseItems,
      ..._baseItems,
    ];

    values.shuffle(_random);

    cards = values
        .map(
          (value) => _MemoryCard(
        value: value,
      ),
    )
        .toList();
  }


  // START GAME


  void startGame() {
    _gameTimer?.cancel();

    setState(() {
      score = 0;
      timeLeft = 60;

      // Reset analytics
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _attempts = 0;

      isGameStarted = true;
      isGameOver = false;

      _firstSelectedIndex = null;
      _secondSelectedIndex = null;

      _isChecking = false;

      _createCards();

      _gameStartedAt = DateTime.now();
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


  // CARD TAP


  Future<void> _onCardTap(int index) async {
    if (!isGameStarted ||
        isGameOver ||
        _isChecking ||
        cards[index].isMatched ||
        cards[index].isFlipped) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;

      if (_firstSelectedIndex == null) {
        _firstSelectedIndex = index;
      } else {
        _secondSelectedIndex = index;
      }
    });

    // Two cards selected = one attempt
    if (_firstSelectedIndex != null &&
        _secondSelectedIndex != null) {
      _isChecking = true;

      final firstCard = cards[_firstSelectedIndex!];
      final secondCard = cards[_secondSelectedIndex!];

      // Every pair check = one attempt
      setState(() {
        _attempts++;
      });


      // CORRECT MATCH

      if (firstCard.value == secondCard.value) {
        setState(() {
          firstCard.isMatched = true;
          secondCard.isMatched = true;

          score++;
          _correctAnswers++;
        });

        await _playSuccessSound();

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        if (_allCardsMatched()) {
          await endGame();
          return;
        }
      }


      // WRONG MATCH


      else {
        setState(() {
          _wrongAnswers++;
        });

        await _playTryAgainSound();

        await Future.delayed(
          const Duration(milliseconds: 700),
        );

        if (!mounted || isGameOver) return;

        setState(() {
          firstCard.isFlipped = false;
          secondCard.isFlipped = false;
        });
      }

      if (!mounted || isGameOver) return;

      setState(() {
        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
        _isChecking = false;
      });
    }
  }


  // CHECK ALL MATCHED


  bool _allCardsMatched() {
    return cards.every(
          (card) => card.isMatched,
    );
  }


  // CALCULATE ACCURACY


  double _calculateAccuracy() {
    if (_attempts == 0) {
      return 0;
    }

    return (_correctAnswers / _attempts) * 100;
  }


  // SAVE RESULT

  Future<void> _saveActivityResult() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      final startedAt =
          _gameStartedAt ?? DateTime.now();

      final duration =
          DateTime.now().difference(startedAt).inSeconds;

      final accuracy = _calculateAccuracy();

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Memory Match',
        activityType: 'memory_matching',
        emotion: widget.emotion,

        score: score,

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
        'Memory Match analytics saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Memory Match save error: $e',
      );
    } finally {
      _isSaving = false;
    }
  }


  // END GAME


  Future<void> endGame() async {
    if (isGameOver) return;

    _gameTimer?.cancel();

    final bool completedAll = _allCardsMatched();

    setState(() {
      timeLeft = 0;
      isGameStarted = false;
      isGameOver = true;
    });

    if (completedAll) {
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

    _showResultDialog(completedAll);
  }

  // RESULT DIALOG


  void _showResultDialog(bool completedAll) {
    final emoji = completedAll ? '🎉' : '🌟';

    final title =
    completedAll ? 'Amazing Memory!' : 'Good Try!';

    final message = completedAll
        ? 'You found all the matching pairs!'
        : 'You found $score out of $totalRounds pairs. Try again!';

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
                    color: const Color(0xFFF4F0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Game Summary',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '$score / $totalRounds 🧠',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B61FF),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Correct: $_correctAnswers   '
                            'Wrong: $_wrongAnswers',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Attempts: $_attempts',
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
                  padding: const EdgeInsets.all(20),
                  child: !isGameStarted && !isGameOver
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
              '🧠 Memory Match',
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
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🧠',
              style: TextStyle(fontSize: 90),
            ),

            const SizedBox(height: 16),

            const Text(
              'Memory Match!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Find the matching pairs!',
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

  // GAME SCREEN

  Widget _buildGameScreen() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.psychology_rounded,
                'Pairs',
                '$score / $totalRounds',
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                Icons.timer_rounded,
                'Time',
                '$timeLeft',
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        const Text(
          'Find the matching animals!',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 18),

        Expanded(
          child: GridView.builder(
            itemCount: cards.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];

              return GestureDetector(
                onTap: () => _onCardTap(index),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color:
                    card.isFlipped || card.isMatched
                        ? Colors.white
                        : const Color(0xFF7B61FF),
                    borderRadius:
                    BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      card.isFlipped || card.isMatched
                          ? card.value
                          : '?',
                      style: TextStyle(
                        fontSize:
                        card.isFlipped || card.isMatched
                            ? 42
                            : 34,
                        fontWeight: FontWeight.bold,
                        color:
                        card.isFlipped || card.isMatched
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
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
                  fontSize: 18,
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


// MEMORY CARD MODEL

class _MemoryCard {
  final String value;

  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}