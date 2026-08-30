import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../core/models/story_model.dart';
import '../../core/services/local_story_service.dart';
import 'story_detail_screen.dart';

class EmotionFilteredStoriesScreen extends StatelessWidget {
  final ChildModel child;
  final String emotion;

  EmotionFilteredStoriesScreen({
    super.key,
    required this.child,
    required this.emotion,
  });

  final LocalStoryService _storyService = LocalStoryService();

  // GET FILTERED STORIES

  List<StoryModel> get stories {
    return _storyService.getStoriesByEmotionAndLanguage(
      emotion: emotion,
      language: child.language,
    );
  }

  // EMOTION EMOJI

  String get emotionEmoji {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return '😡';
      case 'fear':
        return '😨';
      case 'joy':
        return '😊';
      case 'sadness':
        return '😢';
      case 'surprise':
        return '😲';
      case 'neutral':
      default:
        return '😐';
    }
  }

  // TITLE

  String get title {
    switch (child.language) {
      case 'si':
        return 'ඔයාට ගැලපෙන කතා 📚';

      case 'ta':
        return 'உங்களுக்கு ஏற்ற கதைகள் 📚';

      default:
        return 'Stories for You 📚';
    }
  }

  // SUBTITLE

  String get subtitle {
    switch (child.language) {
      case 'si':
        return '$emotionEmoji ඔයාගේ හැඟීමට ගැලපෙන කතාවක්';

      case 'ta':
        return '$emotionEmoji உங்கள் உணர்வுக்கு ஏற்ற கதை';

      default:
        return '$emotionEmoji A story that matches how you feel';
    }
  }

  // EMOTION COLOR

  Color get emotionColor {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return Colors.deepOrange;

      case 'fear':
        return Colors.deepPurple;

      case 'joy':
        return Colors.orange;

      case 'sadness':
        return Colors.blue;

      case 'surprise':
        return Colors.pink;

      case 'neutral':
      default:
        return Colors.lightBlue;
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final filteredStories = stories;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),

      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          // HEADER

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: emotionColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),

            child: Column(
              children: [
                Text(
                  emotionEmoji,
                  style: const TextStyle(
                    fontSize: 55,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: emotionColor,
                  ),
                ),
              ],
            ),
          ),

          // STORIES

          Expanded(
            child: filteredStories.isEmpty
                ? Center(
              child: Text(
                child.language == 'si'
                    ? 'ඔයාට ගැලපෙන කතාවක් තවම නැහැ 📚'
                    : child.language == 'ta'
                    ? 'பொருத்தமான கதை இன்னும் இல்லை 📚'
                    : 'No matching story available yet 📚',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24,
              ),

              itemCount: filteredStories.length,

              itemBuilder: (context, index) {
                final story = filteredStories[index];

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StoryDetailScreen(
                                story: story,
                              ),
                        ),
                      );
                    },

                    child: Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: emotionColor
                                .withOpacity(0.10),
                            blurRadius: 15,
                            offset:
                            const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,

                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                              color: emotionColor
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),

                            child: Text(
                              emotionEmoji,
                              style: const TextStyle(
                                fontSize: 34,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  story.lesson,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color:
                                    Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            Icons.play_circle_fill_rounded,
                            size: 40,
                            color: emotionColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}