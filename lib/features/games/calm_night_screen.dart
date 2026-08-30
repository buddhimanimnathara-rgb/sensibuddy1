import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/models/activity_session_model.dart';
import '../../core/services/activity_service.dart';

class CalmNightScreen extends StatefulWidget {
  final String childId;
  final String emotion;

  const CalmNightScreen({
    super.key,
    required this.childId,
    required this.emotion,
  });

  @override
  State<CalmNightScreen> createState() => _CalmNightScreenState();
}

class _CalmNightScreenState extends State<CalmNightScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ActivityService _activityService = ActivityService();

  static const int totalStars = 6;

  final Set<int> _selectedStars = {};

  DateTime? _startedAt;

  bool _isStarted = false;
  bool _isCompleted = false;
  bool _isSaving = false;
  bool _isFinishing = false;

  // Analytics
  int _attempts = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // SOUND

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

  // START ACTIVITY


  void _startActivity() {
    setState(() {
      _selectedStars.clear();

      _attempts = 0;
      _correctAnswers = 0;
      _wrongAnswers = 0;

      _isStarted = true;
      _isCompleted = false;
      _isFinishing = false;
      _isSaving = false;

      _startedAt = DateTime.now();
    });
  }


  // SELECT STAR


  Future<void> _selectStar(int index) async {
    if (!_isStarted ||
        _isCompleted ||
        _isFinishing ||
        _selectedStars.contains(index)) {
      return;
    }

    setState(() {
      _selectedStars.add(index);

      // Every selectable star is a correct action
      _attempts++;
      _correctAnswers++;
    });

    await _playSound('success.mp3');

    if (!mounted) return;

    if (_selectedStars.length >= totalStars) {
      await _finishActivity();
    }
  }


  // CALCULATE ACCURACY


  double _calculateAccuracy() {
    if (_attempts == 0) return 0.0;

    return (_correctAnswers / _attempts) * 100;
  }

  // SAVE RESULT

  Future<void> _saveResult() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final startedAt = _startedAt ?? DateTime.now();

      final duration =
          DateTime.now().difference(startedAt).inSeconds;

      final session = ActivitySessionModel(
        childId: widget.childId,
        activityName: 'Calm Night',
        activityType: 'calming_activity',
        emotion: widget.emotion,
        score: _selectedStars.length,
        durationSeconds: duration,

        // REQUIRED ANALYTICS
        accuracy: _calculateAccuracy(),
        attempts: _attempts,
        correctAnswers: _correctAnswers,
        wrongAnswers: _wrongAnswers,
        totalRounds: totalStars,

        completed: true,
        completedAt: DateTime.now(),
      );

      await _activityService.saveActivitySession(session);

      debugPrint('Calm Night result saved');
    } catch (e) {
      debugPrint('Calm Night save error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  // FINISH ACTIVITY


  Future<void> _finishActivity() async {
    if (_isFinishing || _isCompleted) return;

    setState(() {
      _isFinishing = true;
      _isStarted = false;
      _isCompleted = true;
    });

    await _playSound('success.mp3');
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
                  '🌙✨',
                  style: TextStyle(fontSize: 75),
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
                  'You made the night sky bright and peaceful!',
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
                        'Stars Collected',
                        style: TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${_selectedStars.length} / $totalStars ⭐',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B61FF),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),

                      const SizedBox(height: 4),

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

  // MAIN UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B1640),
              Color(0xFF40327A),
              Color(0xFF7B61FF),
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
                  child: !_isStarted && !_isCompleted
                      ? _buildStartScreen()
                      : _buildActivityScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '🌙 Calm Night',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (_isStarted)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_selectedStars.length} / $totalStars',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌙⭐', style: TextStyle(fontSize: 90)),
            const SizedBox(height: 16),
            const Text(
              'Calm Night',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the stars and make your night sky bright and peaceful.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _startActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5B3FA6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start',
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
    const positions = [
      Offset(0.08, 0.10),
      Offset(0.65, 0.08),
      Offset(0.42, 0.27),
      Offset(0.15, 0.48),
      Offset(0.72, 0.55),
      Offset(0.45, 0.75),
    ];

    return Column(
      children: [
        const SizedBox(height: 15),
        const Text(
          'Tap all the stars ⭐',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Take your time and enjoy the calm night 🌙',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        Expanded(
          child: Stack(
            children: List.generate(totalStars, (index) {
              final isSelected = _selectedStars.contains(index);
              final position = positions[index];

              return Align(
                alignment: Alignment(
                  position.dx * 2 - 1,
                  position.dy * 2 - 1,
                ),
                child: GestureDetector(
                  onTap: () => _selectStar(index),
                  child: AnimatedScale(
                    scale: isSelected ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: 75,
                        height: 75,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white.withOpacity(0.18)
                              : Colors.transparent,
                        ),
                        child: const Text(
                          '⭐',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_selectedStars.length} of $totalStars stars collected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}