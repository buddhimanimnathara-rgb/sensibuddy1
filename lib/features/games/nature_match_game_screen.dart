import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class NatureMatchGameScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const NatureMatchGameScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<NatureMatchGameScreen> createState() =>
      _NatureMatchGameScreenState();
}

class _NatureMatchGameScreenState extends State<NatureMatchGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();
  final Random _random = Random();

  final List<NatureItem> _allItems = [
    NatureItem(name: 'Tree', emoji: '🌳'),
    NatureItem(name: 'Flower', emoji: '🌸'),
    NatureItem(name: 'Sun', emoji: '☀️'),
    NatureItem(name: 'Rainbow', emoji: '🌈'),
    NatureItem(name: 'Leaf', emoji: '🍃'),
  ];

  List<NatureItem> _gameItems = [];
  List<NatureItem> _options = [];

  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _attempts = 0;

  bool _isStarted = false;
  bool _isFinished = false;
  bool _isSaving = false;
  bool _isLocked = false;

  DateTime? _startedAt;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource('sounds/$fileName'),
      );
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }


  void _startGame() {
    final items = List<NatureItem>.from(_allItems)
      ..shuffle(_random);

    setState(() {
      _gameItems = items;

      _options = List<NatureItem>.from(items)
        ..shuffle(_random);

      _currentIndex = 0;
      _score = 0;

      // Reset analytics
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _attempts = 0;

      _isStarted = true;
      _isFinished = false;
      _isLocked = false;

      _startedAt = DateTime.now();
    });
  }


  Future<void> _selectAnswer(NatureItem selected) async {
    if (_isLocked || _isFinished || _gameItems.isEmpty) {
      return;
    }

    _isLocked = true;

    // Every click = one attempt
    setState(() {
      _attempts++;
    });

    final correctItem = _gameItems[_currentIndex];

    final bool isCorrect =
        selected.name == correctItem.name;

    if (isCorrect) {
      setState(() {
        _score++;
        _correctAnswers++;
      });

      await _playSound('success.mp3');
    } else {
      setState(() {
        _wrongAnswers++;
      });

      await _playSound('try_again.mp3');
    }

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    if (isCorrect) {
      if (_currentIndex >= _gameItems.length - 1) {
        await _finishGame();
      } else {
        setState(() {
          _currentIndex++;

          _options = List<NatureItem>.from(_allItems)
            ..shuffle(_random);

          _isLocked = false;
        });
      }
    } else {
      setState(() {
        _isLocked = false;
      });
    }
  }



  double _calculateAccuracy() {
    if (_attempts == 0) {
      return 0;
    }

    return (_correctAnswers / _attempts) * 100;
  }


  Future<void> _saveResult() async {
    if (_isSaving) return;

    _isSaving = true;

    try {
      final startedAt = _startedAt ?? DateTime.now();

      final duration =
          DateTime.now().difference(startedAt).inSeconds;

      final accuracy = _calculateAccuracy();

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Nature Match',
        activityType: 'game',
        emotion: widget.emotion,

        score: _score,

        totalRounds: _gameItems.length,

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
        'Nature Match analytics saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Nature Match save error: $e',
      );
    } finally {
      _isSaving = false;
    }
  }

  // ================= FINISH GAME =================

  Future<void> _finishGame() async {
    if (_isFinished) return;

    setState(() {
      _isFinished = true;
      _isStarted = false;
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

  // ================= RESULT DIALOG =================

  void _showResultDialog() {
    final accuracy = _calculateAccuracy();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🌿',
                  style: TextStyle(fontSize: 75),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Great Job!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B3FA6),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'You matched $_score out of '
                      '${_gameItems.length} nature items!',
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
                        'Game Summary',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '$_score / ${_gameItems.length} ⭐',
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
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF7B61FF),
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

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
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

  // ================= HEADER =================

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
              '🌿 Nature Match',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
          ),

          if (_isStarted)
            Text(
              '${_currentIndex + 1}/${_gameItems.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B61FF),
              ),
            ),
        ],
      ),
    );
  }

  // ================= START SCREEN =================

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
              '🌳🌸🌈',
              style: TextStyle(fontSize: 70),
            ),

            const SizedBox(height: 20),

            const Text(
              'Nature Match',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Look at the nature picture and choose the matching one!',
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
                  backgroundColor:
                  const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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

  // ================= GAME SCREEN =================

  Widget _buildGameScreen() {
    if (_gameItems.isEmpty) {
      return const SizedBox();
    }

    final target = _gameItems[_currentIndex];

    return Column(
      children: [
        const SizedBox(height: 20),

        const Text(
          'Find the matching picture',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 30),

        Container(
          width: 180,
          height: 180,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            target.emoji,
            style: const TextStyle(fontSize: 100),
          ),
        ),

        const SizedBox(height: 35),

        Expanded(
          child: GridView.builder(
            itemCount: _options.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final item = _options[index];

              return GestureDetector(
                onTap: () => _selectAnswer(item),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE1D8F5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 58),
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
}

class NatureItem {
  final String name;
  final String emoji;

  NatureItem({
    required this.name,
    required this.emoji,
  });
}