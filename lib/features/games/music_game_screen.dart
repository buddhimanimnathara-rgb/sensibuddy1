import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class MusicGameScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const MusicGameScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<MusicGameScreen> createState() => _MusicGameScreenState();
}

class _MusicGameScreenState extends State<MusicGameScreen> {
  final AudioPlayer _animalPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  final ActivityService _activityService = ActivityService();
  final Random _random = Random();

  static const int totalRounds = 5;

  final List<AnimalItem> _animals = const [
    AnimalItem(
      id: 'dog',
      emoji: '🐶',
      name: 'Dog',
      sound: 'dog.mp3',
    ),
    AnimalItem(
      id: 'cat',
      emoji: '🐱',
      name: 'Cat',
      sound: 'cat.mp3',
    ),
    AnimalItem(
      id: 'cow',
      emoji: '🐮',
      name: 'Cow',
      sound: 'cow.mp3',
    ),
    AnimalItem(
      id: 'lion',
      emoji: '🦁',
      name: 'Lion',
      sound: 'lion.mp3',
    ),
    AnimalItem(
      id: 'elephant',
      emoji: '🐘',
      name: 'Elephant',
      sound: 'elephant.mp3',
    ),
  ];

  List<AnimalItem> _questions = [];
  List<AnimalItem> _options = [];

  int _currentRound = 0;
  int _score = 0;
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
    _animalPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  // PLAY ANIMAL SOUND

  Future<void> _playAnimalSound() async {
    if (_questions.isEmpty) return;

    try {
      final animal = _questions[_currentRound];

      await _animalPlayer.stop();

      await _animalPlayer.play(
        AssetSource('sounds/${animal.sound}'),
      );
    } catch (e) {
      debugPrint('Animal sound error: $e');
    }
  }


  // PLAY SUCCESS / WRONG SOUND

  Future<void> _playEffect(String fileName) async {
    try {
      await _effectPlayer.stop();

      await _effectPlayer.play(
        AssetSource('sounds/$fileName'),
      );
    } catch (e) {
      debugPrint('Effect sound error: $e');
    }
  }


  // START GAME
  Future<void> _startGame() async {
    final shuffledQuestions = List<AnimalItem>.from(_animals)
      ..shuffle(_random);

    setState(() {
      _questions = shuffledQuestions.take(totalRounds).toList();

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

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    await _playAnimalSound();
  }


  // GENERATE 2 OPTIONS

  void _generateOptions() {
    if (_questions.isEmpty) return;

    final correctAnimal = _questions[_currentRound];

    final wrongAnimals = _animals
        .where(
          (animal) => animal.id != correctAnimal.id,
    )
        .toList()
      ..shuffle(_random);

    final wrongAnimal = wrongAnimals.first;

    _options = [
      correctAnimal,
      wrongAnimal,
    ]..shuffle(_random);
  }

  // SELECT ANIMAL

  Future<void> _selectAnimal(AnimalItem selected) async {
    if (_isLocked || _isFinished || _questions.isEmpty) {
      return;
    }

    _isLocked = true;

    // Every answer click is an attempt.
    setState(() {
      _attempts++;
    });

    final correctAnimal = _questions[_currentRound];

    final bool isCorrect =
        selected.id == correctAnimal.id;

    if (isCorrect) {
      setState(() {
        _score++;
        _correctAnswers++;
      });

      await _playEffect('success.mp3');

      await Future.delayed(
        const Duration(milliseconds: 900),
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

        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        if (!mounted) return;

        await _playAnimalSound();
      }
    } else {
      setState(() {
        _wrongAnswers++;
      });

      await _playEffect('try_again.mp3');

      await Future.delayed(
        const Duration(milliseconds: 700),
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
      return 0;
    }

    return (_correctAnswers / _attempts) * 100;
  }


  // SAVE RESULT

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
        activityName: 'Music Game',
        activityType: 'animal_sound_matching',
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

      debugPrint('Music Game analytics saved successfully');
    } catch (e) {
      debugPrint('Music Game save error: $e');
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

    await _playEffect('success.mp3');

    await _saveResult();

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 500),
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
                  '🐾🎉',
                  style: TextStyle(
                    fontSize: 75,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Amazing!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B61FF),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'You got $_score out of $totalRounds correct!',
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
                  child: const Text('Exit Game'),
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


  // HEADER


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
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
              '🎵 Animal Sounds',
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
              '🐾🎵',
              style: TextStyle(fontSize: 90),
            ),
            const SizedBox(height: 16),
            const Text(
              'Animal Sounds',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Listen carefully and choose the correct animal!',
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
        const SizedBox(height: 20),

        const Text(
          'Listen to the sound!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 20),

        GestureDetector(
          onTap: _isLocked ? null : _playAnimalSound,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFE6DFFF),
              borderRadius: BorderRadius.circular(65),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              size: 65,
              color: Color(0xFF7B61FF),
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Tap to hear again 🔊',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          'Which animal makes this sound?',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 25),

        Row(
          children: _options.map((animal) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: GestureDetector(
                  onTap: () => _selectAnimal(animal),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFE1D8F5),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        animal.emoji,
                        style: const TextStyle(
                          fontSize: 90,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        Text(
          'Score: $_score ⭐',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7B61FF),
          ),
        ),
      ],
    );
  }
}


// ANIMAL MODEL

class AnimalItem {
  final String id;
  final String emoji;
  final String name;
  final String sound;

  const AnimalItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.sound,
  });
}