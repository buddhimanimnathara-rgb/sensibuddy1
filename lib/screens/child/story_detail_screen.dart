import 'package:flutter/material.dart';

import '../../core/models/story_model.dart';
import '../../core/services/story_audio_service.dart';

class StoryDetailScreen extends StatefulWidget {
  final StoryModel story;

  const StoryDetailScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryDetailScreen> createState() =>
      _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final StoryAudioService _audioService = StoryAudioService();

  bool _isPlaying = false;
  bool _hasStarted = false;

  // EMOTION EMOJI

  String _getEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return '😡';
      case 'fear':
        return '😨';
      case 'joy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sadness':
        return '😢';
      case 'surprise':
        return '😲';
      default:
        return '📖';
    }
  }

  // EMOTION COLOR

  Color _getColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return Colors.deepOrange;
      case 'fear':
        return Colors.deepPurple;
      case 'joy':
        return Colors.orange;
      case 'neutral':
        return Colors.lightBlue;
      case 'sadness':
        return Colors.blue;
      case 'surprise':
        return Colors.pink;
      default:
        return Colors.indigo;
    }
  }

  // PLAY / RESUME STORY

  Future<void> _playStory() async {
    try {
      if (_hasStarted) {
        await _audioService.resumeStory();
      } else {
        await _audioService.playStory(
          emotion: widget.story.emotion,
          language: widget.story.language,
        );

        _hasStarted = true;
      }

      if (!mounted) return;

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Story audio error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play audio: $e'),
        ),
      );
    }
  }

  // PAUSE STORY

  Future<void> _pauseStory() async {
    await _audioService.pauseStory();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  // STOP STORY

  Future<void> _stopStory() async {
    await _audioService.stopStory();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _hasStarted = false;
    });
  }

  // DISPOSE

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }


  // UI


  @override
  Widget build(BuildContext context) {
    final color = _getColor(widget.story.emotion);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      appBar: AppBar(
        title: const Text(
          'Story Time 📚',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // EMOTION HEADER

              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                ),

                child: Column(
                  children: [
                    Text(
                      _getEmoji(widget.story.emotion),
                      style: const TextStyle(
                        fontSize: 60,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.story.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // STORY CONTENT

              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Text(
                  widget.story.content.trim(),
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.7,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LESSON

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.25),
                  ),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 28),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What we learned',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            widget.story.lesson,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // AUDIO CONTROLS

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  // PLAY / RESUME
                  FloatingActionButton(
                    heroTag: 'play',
                    backgroundColor: color,
                    onPressed: _isPlaying
                        ? null
                        : _playStory,
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),

                  // PAUSE
                  FloatingActionButton(
                    heroTag: 'pause',
                    backgroundColor: Colors.orange,
                    onPressed: _isPlaying
                        ? _pauseStory
                        : null,
                    child: const Icon(
                      Icons.pause,
                      color: Colors.white,
                    ),
                  ),

                  // STOP
                  FloatingActionButton(
                    heroTag: 'stop',
                    backgroundColor: Colors.red,
                    onPressed: _hasStarted
                        ? _stopStory
                        : null,
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}