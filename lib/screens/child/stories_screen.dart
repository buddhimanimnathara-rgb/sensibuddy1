import 'package:flutter/material.dart';

import '../../core/models/story_model.dart';
import '../../core/services/local_story_service.dart';
import 'story_detail_screen.dart';

class StoriesScreen extends StatefulWidget {
  final String language;

  const StoriesScreen({
    super.key,
    required this.language,
  });

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final LocalStoryService _storyService = LocalStoryService();

  late List<StoryModel> _stories;

  @override
  void initState() {
    super.initState();

    _stories = _storyService.getStoriesByLanguage(
      widget.language,
    );
  }

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

  // STORY CHARACTER

  String _getCharacter(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return '🐻';

      case 'fear':
        return '🐦';

      case 'joy':
        return '🐰';

      case 'neutral':
        return '🌤️';

      case 'sadness':
        return '🐘';

      case 'surprise':
        return '🐱';

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

  // UI

  @override
  Widget build(BuildContext context) {
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

      body: _stories.isEmpty
          ? const Center(
        child: Text(
          'No stories available yet 📚',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];

          final color = _getColor(story.emotion);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),

            child: InkWell(
              borderRadius: BorderRadius.circular(24),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryDetailScreen(
                      story: story,
                    ),
                  ),
                );
              },

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // CHARACTER
                    Container(
                      width: 70,
                      height: 70,

                      alignment: Alignment.center,

                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),

                      child: Text(
                        _getCharacter(story.emotion),
                        style: const TextStyle(
                          fontSize: 38,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // STORY DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getEmoji(story.emotion)} '
                                '${story.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            story.lesson,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.play_circle_fill,
                      size: 38,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}