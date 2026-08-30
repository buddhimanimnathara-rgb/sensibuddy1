import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../games/ballon_pop_game_screen.dart';
import '../games/calm_game_screen.dart';
import '../games/calm_night_screen.dart';
import '../games/color_match_game_screen.dart';
import '../games/easy_puzzle_screen.dart';
import '../games/find_it_screen.dart';
import '../games/memory_match_game_screen.dart';
import '../games/music_game_screen.dart';
import '../games/mystery_box_screen.dart';
import '../games/nature_match_game_screen.dart';
import '../games/safe_space_screen.dart';
import '../games/space_explorer_screen.dart';
import '../games/star_match_screen.dart';
import '../games/teddy_match_game_screen.dart';

class EmotionFilteredGamesScreen extends StatelessWidget {
  final ChildModel child;
  final String emotion;

  const EmotionFilteredGamesScreen({
    super.key,
    required this.child,
    required this.emotion,
  });

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
      default:
        return '😐';
    }
  }

  String get title {
    switch (child.language) {
      case 'si':
        return 'ඔයාට ගැලපෙන Games';
      case 'ta':
        return 'உங்களுக்கு ஏற்ற விளையாட்டுகள்';
      default:
        return 'Games for You';
    }
  }

  List<Map<String, dynamic>> getGames() {
    switch (emotion.toLowerCase()) {
      case 'sadness':
        return [
          {
            'emoji': '🌈',
            'title': 'Happy Colors',
            'subtitle': 'A fun and colorful game',
            'icon': Icons.palette_rounded,
          },
          {
            'emoji': '🧩',
            'title': 'Easy Puzzle',
            'subtitle': 'Relax and solve puzzles',
            'icon': Icons.extension_rounded,
          },
          {
            'emoji': '⭐',
            'title': 'Star Match',
            'subtitle': 'Match the stars together',
            'icon': Icons.star_rounded,
          },
        ];

      case 'angry':
        return [
          {
            'emoji': '🫧',
            'title': 'Bubble Pop',
            'subtitle': 'Pop bubbles and relax',
            'icon': Icons.bubble_chart_rounded,
          },
          {
            'emoji': '🧘',
            'title': 'Calm Game',
            'subtitle': 'A peaceful activity',
            'icon': Icons.self_improvement_rounded,
          },
          {
            'emoji': '🌿',
            'title': 'Nature Match',
            'subtitle': 'Relax with nature',
            'icon': Icons.park_rounded,
          },
        ];

      case 'fear':
        return [
          {
            'emoji': '🤗',
            'title': 'Safe Space',
            'subtitle': 'A gentle and comforting game',
            'icon': Icons.favorite_rounded,
          },
          {
            'emoji': '🧸',
            'title': 'Teddy Match',
            'subtitle': 'Play with friendly toys',
            'icon': Icons.toys_rounded,
          },
          {
            'emoji': '🌙',
            'title': 'Calm Night',
            'subtitle': 'A soft and relaxing game',
            'icon': Icons.nightlight_round,
          },
        ];

      case 'joy':
        return [
          {
            'emoji': '🎈',
            'title': 'Balloon Pop',
            'subtitle': 'Pop balloons and have fun',
            'icon': Icons.celebration_rounded,
          },
          {
            'emoji': '🎨',
            'title': 'Color Fun',
            'subtitle': 'Create something colorful',
            'icon': Icons.brush_rounded,
          },
          {
            'emoji': '🎵',
            'title': 'Music Game',
            'subtitle': 'Play with sounds and music',
            'icon': Icons.music_note_rounded,
          },
        ];

      case 'surprise':
        return [
          {
            'emoji': '🔍',
            'title': 'Find It!',
            'subtitle': 'Discover hidden objects',
            'icon': Icons.search_rounded,
          },
          {
            'emoji': '🎁',
            'title': 'Mystery Box',
            'subtitle': 'What is inside?',
            'icon': Icons.card_giftcard_rounded,
          },
          {
            'emoji': '🚀',
            'title': 'Space Explorer',
            'subtitle': 'Explore something new',
            'icon': Icons.rocket_launch_rounded,
          },
        ];

      default:
        return [
          {
            'emoji': '🧩',
            'title': 'Easy Puzzle',
            'subtitle': 'A simple and fun game',
            'icon': Icons.extension_rounded,
          },
          {
            'emoji': '🎨',
            'title': 'Color Fun',
            'subtitle': 'Play with colors',
            'icon': Icons.palette_rounded,
          },
          {
            'emoji': '⭐',
            'title': 'Star Match',
            'subtitle': 'A fun matching game',
            'icon': Icons.star_rounded,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = getGames();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F5FF),
              Color(0xFFE8E0FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '$emotionEmoji ${child.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];

                    return _GameCard(
                      emoji: game['emoji'],
                      title: game['title'],
                      subtitle: game['subtitle'],
                      icon: game['icon'],
                      onTap: () {
                        if (game['title'] == 'Balloon Pop') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BalloonPopGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Color Fun' ||
                            game['title'] == 'Happy Colors') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ColorMatchGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Memory Fun') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemoryMatchGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Calm Game') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalmGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Nature Match') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NatureMatchGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Safe Space') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SafeSpaceScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Teddy Match') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeddyMatchGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Calm Night') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalmNightScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Happy Colors') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ColorMatchGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Easy Puzzle') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EasyPuzzleScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Star Match') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StarMatchScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Music Game') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MusicGameScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Find It!') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FindItScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Mystery Box') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MysteryBoxScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        if (game['title'] == 'Space Explorer') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpaceExplorerScreen(
                                childId: child.id,
                                emotion: emotion,
                              ),
                            ),
                          );
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${game['title']} will be available soon 🎮',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B3FA6),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF7B61FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}