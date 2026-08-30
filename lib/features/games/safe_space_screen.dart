import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class SafeSpaceScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const SafeSpaceScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<SafeSpaceScreen> createState() => _SafeSpaceScreenState();
}

class _SafeSpaceScreenState extends State<SafeSpaceScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  DateTime? _startedAt;

  int selectedItems = 0;

  // Analytics
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _attempts = 0;

  bool isStarted = false;
  bool isCompleted = false;
  bool isSaving = false;

  final List<SafeItem> safeItems = [
    SafeItem(
      title: 'Teddy',
      emoji: '🧸',
      message: 'A teddy can be your soft friend.',
    ),
    SafeItem(
      title: 'Home',
      emoji: '🏠',
      message: 'Home can be a safe and comfortable place.',
    ),
    SafeItem(
      title: 'Heart',
      emoji: '❤️',
      message: 'You are loved and cared for.',
    ),
    SafeItem(
      title: 'Rainbow',
      emoji: '🌈',
      message: 'After difficult moments, brighter moments can come.',
    ),
  ];

  final Set<int> selectedIndexes = {};

  int get totalRounds => safeItems.length;

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

  void _startActivity() {
    setState(() {
      selectedIndexes.clear();

      selectedItems = 0;

      _correctAnswers = 0;
      _wrongAnswers = 0;
      _attempts = 0;

      isStarted = true;
      isCompleted = false;

      _startedAt = DateTime.now();
    });
  }

  Future<void> _selectItem(int index) async {
    if (!isStarted || isCompleted) return;

    // Already selected items are ignored.
    if (selectedIndexes.contains(index)) {
      return;
    }

    setState(() {
      _attempts++;

      selectedIndexes.add(index);

      selectedItems = selectedIndexes.length;

      _correctAnswers++;
    });

    await _playSound('success.mp3');

    if (!mounted) return;

    _showItemMessage(safeItems[index]);

    if (selectedIndexes.length == safeItems.length) {
      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      if (!mounted) return;

      await _finishActivity();
    }
  }

  double _calculateAccuracy() {
    if (_attempts == 0) {
      return 0;
    }

    return (_correctAnswers / _attempts) * 100;
  }

  void _showItemMessage(SafeItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.emoji} ${item.message}',
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveResult() async {
    if (isSaving) return;

    isSaving = true;

    try {
      final startedAt = _startedAt ?? DateTime.now();

      final duration =
          DateTime.now().difference(startedAt).inSeconds;

      final accuracy = _calculateAccuracy();

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Safe Space',
        activityType: 'calming_activity',
        emotion: widget.emotion,

        score: selectedItems,

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

      debugPrint('Safe Space analytics saved successfully');
    } catch (e) {
      debugPrint('Safe Space save error: $e');
    } finally {
      isSaving = false;
    }
  }

  Future<void> _finishActivity() async {
    if (isCompleted) return;

    setState(() {
      isStarted = false;
      isCompleted = true;
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
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🤗',
                  style: TextStyle(
                    fontSize: 75,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'You Did Great!',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B3FA6),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'You explored your safe and happy space!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                        'Activity Summary',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '$selectedItems / $totalRounds',
                        style: const TextStyle(
                          fontSize: 34,
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
                      _startActivity();
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
                    'Exit',
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF5B3FA6),
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Text(
              '🛡️ Safe Space',
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
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$selectedItems/$totalRounds',
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
              '🤗',
              style: TextStyle(
                fontSize: 95,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Welcome to Your Safe Space',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Tap each special item and discover something comforting.',
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
                onPressed: _startActivity,
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

  Widget _buildActivityScreen() {
    return Column(
      children: [
        const SizedBox(height: 10),

        const Text(
          'Explore your safe space',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B3FA6),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Tap all the things that make you feel safe',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: GridView.builder(
            itemCount: safeItems.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final item = safeItems[index];

              final bool selected =
              selectedIndexes.contains(index);

              return GestureDetector(
                onTap: () => _selectItem(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFE8DFFF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF7B61FF)
                          : const Color(0xFFE1D8F5),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        item.emoji,
                        style: const TextStyle(
                          fontSize: 65,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),

                      if (selected) ...[
                        const SizedBox(height: 6),

                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF7B61FF),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        Text(
          'Explored: $selectedItems / $totalRounds',
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
                child: !isStarted && !isCompleted
                    ? _buildStartScreen()
                    : _buildActivityScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafeItem {
  final String title;
  final String emoji;
  final String message;

  SafeItem({
    required this.title,
    required this.emoji,
    required this.message,
  });
}