import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class SpaceExplorerScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const SpaceExplorerScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<SpaceExplorerScreen> createState() =>
      _SpaceExplorerScreenState();
}

class _SpaceExplorerScreenState
    extends State<SpaceExplorerScreen> {
  final Random _random = Random();
  final AudioPlayer _soundPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  static const int totalRounds = 5;

  final List<SpaceItem> _items = const [
    SpaceItem(id: 'rocket', emoji: '🚀', name: 'Rocket'),
    SpaceItem(id: 'planet', emoji: '🪐', name: 'Planet'),
    SpaceItem(id: 'alien', emoji: '👽', name: 'Alien'),
    SpaceItem(id: 'moon', emoji: '🌙', name: 'Moon'),
    SpaceItem(id: 'star', emoji: '⭐', name: 'Star'),
    SpaceItem(id: 'comet', emoji: '☄️', name: 'Comet'),
    SpaceItem(id: 'satellite', emoji: '🛰️', name: 'Satellite'),
    SpaceItem(id: 'astronaut', emoji: '👨‍🚀', name: 'Astronaut'),
    SpaceItem(id: 'ufo', emoji: '🛸', name: 'UFO'),
  ];

  List<SpaceItem> _questions = [];
  List<SpaceItem> _options = [];

  int _currentRound = 0;
  int _score = 0;

  // Analytics
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


  // SOUND

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


  // START GAME


  void _startGame() {
    final shuffled = List<SpaceItem>.from(_items)
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


  // GENERATE OPTIONS


  void _generateOptions() {
    if (_questions.isEmpty) return;

    final correctItem = _questions[_currentRound];

    final wrongItems = _items
        .where((item) => item.id != correctItem.id)
        .toList()
      ..shuffle(_random);

    _options = [
      correctItem,
      ...wrongItems.take(5),
    ]..shuffle(_random);
  }


  // SELECT OBJECT


  Future<void> _selectItem(SpaceItem selected) async {
    if (_isLocked ||
        _isFinished ||
        _questions.isEmpty) {
      return;
    }

    _isLocked = true;

    // Every click is an attempt
    setState(() {
      _attempts++;
    });

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


  // CALCULATE ACCURACY


  double _calculateAccuracy() {
    if (_attempts == 0) return 0;

    return (_correctAnswers / _attempts) * 100;
  }


  // SAVE RESULT


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

        activityName: 'Space Explorer',

        activityType: 'visual_attention_game',

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

      await _activityService.saveActivitySession(session);

      debugPrint(
        'Space Explorer analytics saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Space Explorer save error: $e',
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


  // RESULT DIALOG


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
                  '🚀🎉',
                  style: TextStyle(fontSize: 75),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Amazing Explorer!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B61FF),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You found $_score out of $totalRounds objects!',
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
                    borderRadius: BorderRadius.circular(20),
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
                          fontSize: 17,
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
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
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
                  child: const Text('Exit Game'),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF5B3FA6),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '🚀 Space Explorer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
          ),
          if (_isStarted)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
              '🚀',
              style: TextStyle(fontSize: 95),
            ),
            const SizedBox(height: 16),
            const Text(
              'Space Explorer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore space and find the correct object!',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start Exploring',
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
    if (_questions.isEmpty) {
      return const SizedBox();
    }

    final target = _questions[_currentRound];

    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Explore and find!',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 125,
          height: 125,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE4FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              target.emoji,
              style: const TextStyle(fontSize: 75),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Find the ${target.name}',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: GridView.builder(
            itemCount: _options.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final item = _options[index];

              return GestureDetector(
                onTap: () => _selectItem(item),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE1D8F5),
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
                      style: const TextStyle(fontSize: 55),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Score: $_score ⭐',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7B61FF),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }


  // MAIN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: !_isStarted && !_isFinished
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


// SPACE ITEM MODEL

class SpaceItem {
  final String id;
  final String emoji;
  final String name;

  const SpaceItem({
    required this.id,
    required this.emoji,
    required this.name,
  });
}