import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class MysteryBoxScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const MysteryBoxScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<MysteryBoxScreen> createState() => _MysteryBoxScreenState();
}

class _MysteryBoxScreenState extends State<MysteryBoxScreen> {
  final Random _random = Random();
  final AudioPlayer _soundPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  static const int totalRounds = 5;

  final List<MysteryItem> _items = const [
    MysteryItem(id: 'apple', emoji: '🍎', name: 'Apple'),
    MysteryItem(id: 'star', emoji: '⭐', name: 'Star'),
    MysteryItem(id: 'car', emoji: '🚗', name: 'Car'),
    MysteryItem(id: 'cat', emoji: '🐱', name: 'Cat'),
    MysteryItem(id: 'ball', emoji: '⚽', name: 'Ball'),
    MysteryItem(id: 'banana', emoji: '🍌', name: 'Banana'),
    MysteryItem(id: 'dog', emoji: '🐶', name: 'Dog'),
    MysteryItem(id: 'rocket', emoji: '🚀', name: 'Rocket'),
    MysteryItem(id: 'flower', emoji: '🌸', name: 'Flower'),
  ];

  List<MysteryItem> _questions = [];
  List<MysteryItem> _options = [];

  int _currentRound = 0;
  int _score = 0;


  // ANALYTICS


  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _attempts = 0;

  bool _isStarted = false;
  bool _isFinished = false;
  bool _isLocked = false;
  bool _showItem = false;
  bool _showOptions = false;
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
    final shuffled = List<MysteryItem>.from(_items)
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
      _showItem = false;
      _showOptions = false;

      _startedAt = DateTime.now();
    });
  }


  // OPEN BOX

  Future<void> _openBox() async {
    if (_isLocked || _showItem || _showOptions) {
      return;
    }

    setState(() {
      _isLocked = true;
      _showItem = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    _generateOptions();

    setState(() {
      _showItem = false;
      _showOptions = true;
      _isLocked = false;
    });
  }

  // GENERATE OPTIONS


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

  // SELECT ANSWER


  Future<void> _selectItem(
      MysteryItem selected,
      ) async {
    if (_isLocked ||
        !_showOptions ||
        _isFinished ||
        _questions.isEmpty) {
      return;
    }

    _isLocked = true;

    // Every click = one attempt
    setState(() {
      _attempts++;
    });

    final correctItem =
    _questions[_currentRound];

    final bool isCorrect =
        selected.id == correctItem.id;


    // CORRECT ANSWER


    if (isCorrect) {
      setState(() {
        _score++;
        _correctAnswers++;
      });

      await _playSound('success.mp3');

      await Future.delayed(
        const Duration(
          milliseconds: 800,
        ),
      );

      if (!mounted) return;

      if (_currentRound >= totalRounds - 1) {
        await _finishGame();
      } else {
        setState(() {
          _currentRound++;

          _showOptions = false;
          _showItem = false;
          _isLocked = false;
        });
      }
    }


    // WRONG ANSWER

    else {
      setState(() {
        _wrongAnswers++;
      });

      await _playSound('try_again.mp3');

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
      return 0;
    }

    return (
        _correctAnswers /
            _attempts
    ) *
        100;
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

      final accuracy =
      _calculateAccuracy();

      final session =
      ActivitySessionModel(
        childId: widget.childId,

        activityName: 'Mystery Box',

        activityType:
        'visual_memory_game',

        emotion: widget.emotion,

        score: _score,

        totalRounds: totalRounds,

        correctAnswers:
        _correctAnswers,

        wrongAnswers:
        _wrongAnswers,

        attempts: _attempts,

        accuracy: accuracy,

        durationSeconds: duration,

        completed: true,

        completedAt:
        DateTime.now(),
      );

      await _activityService
          .saveActivitySession(
        session,
      );

      debugPrint(
        'Mystery Box analytics saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Mystery Box save error: $e',
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
          shape:
          RoundedRectangleBorder(
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
                  '🎁🎉',
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
                  'You got $_score out of '
                      '$totalRounds!',
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    fontSize: 16,
                    color:
                    Colors.black54,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(18),
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
                        'Game Summary',
                        style: TextStyle(
                          color:
                          Colors.black54,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        '$_score / '
                            '$totalRounds ⭐',
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
                        height: 14,
                      ),

                      Text(
                        'Accuracy: '
                            '${accuracy.toStringAsFixed(1)}%',
                        style:
                        const TextStyle(
                          fontSize: 17,
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
                        'Correct: '
                            '$_correctAnswers   '
                            'Wrong: '
                            '$_wrongAnswers',
                        style:
                        const TextStyle(
                          fontSize: 14,
                          color:
                          Colors.black54,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Attempts: '
                            '$_attempts',
                        style:
                        const TextStyle(
                          fontSize: 14,
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
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Play Again',
                    ),
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
            onPressed: () =>
                Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          const Expanded(
            child: Text(
              '🎁 Mystery Box',
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
            Text(
              '${_currentRound + 1}/'
                  '$totalRounds',
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
                color: Color(
                  0xFF7B61FF,
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
              '🎁',
              style: TextStyle(
                fontSize: 95,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Mystery Box',
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
              'Open the box, remember what '
                  'you see, and choose it!',
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
                onPressed: _startGame,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text(
                  'Start Playing',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF7B61FF,
                  ),
                  foregroundColor:
                  Colors.white,
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

    final currentItem =
    _questions[_currentRound];

    return Column(
      children: [
        const SizedBox(
          height: 25,
        ),

        if (!_showItem &&
            !_showOptions) ...[
          const Text(
            'What is inside the box?',
            style: TextStyle(
              fontSize: 23,
              fontWeight:
              FontWeight.bold,
              color: Color(
                0xFF5B3FA6,
              ),
            ),
          ),

          const SizedBox(
            height: 35,
          ),

          GestureDetector(
            onTap: _openBox,
            child: const Text(
              '🎁',
              style: TextStyle(
                fontSize: 150,
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          ElevatedButton(
            onPressed: _openBox,
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              const Color(
                0xFF7B61FF,
              ),
              foregroundColor:
              Colors.white,
            ),
            child: const Text(
              'Open the Box!',
            ),
          ),
        ],

        if (_showItem) ...[
          const Text(
            'Remember this!',
            style: TextStyle(
              fontSize: 23,
              fontWeight:
              FontWeight.bold,
              color: Color(
                0xFF5B3FA6,
              ),
            ),
          ),

          const SizedBox(
            height: 35,
          ),

          Text(
            currentItem.emoji,
            style: const TextStyle(
              fontSize: 130,
            ),
          ),
        ],

        if (_showOptions) ...[
          const Text(
            'What did you see?',
            style: TextStyle(
              fontSize: 23,
              fontWeight:
              FontWeight.bold,
              color: Color(
                0xFF5B3FA6,
              ),
            ),
          ),

          const SizedBox(
            height: 35,
          ),

          Row(
            children:
            _options.map((item) {
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      _selectItem(item),
                  child: Container(
                    margin:
                    const EdgeInsets.all(
                      6,
                    ),
                    height: 140,
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        25,
                      ),
                      border: Border.all(
                        color:
                        const Color(
                          0xFFE1D8F5,
                        ),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style:
                        const TextStyle(
                          fontSize: 65,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        const Spacer(),

        Text(
          'Score: $_score ⭐',
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
            color: Color(
              0xFF7B61FF,
            ),
          ),
        ),

        const SizedBox(
          height: 20,
        ),
      ],
    );
  }


  // MAIN


  @override
  Widget build(
      BuildContext context,
      ) {
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

// MYSTERY ITEM MODEL


class MysteryItem {
  final String id;
  final String emoji;
  final String name;

  const MysteryItem({
    required this.id,
    required this.emoji,
    required this.name,
  });
}