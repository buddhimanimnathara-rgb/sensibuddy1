import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';

import 'ballon_pop_game_screen.dart';
import 'calm_game_screen.dart';
import 'calm_night_screen.dart';
import 'color_match_game_screen.dart';
import 'easy_puzzle_screen.dart';
import 'find_it_screen.dart';
import 'memory_match_game_screen.dart';
import 'music_game_screen.dart';
import 'mystery_box_screen.dart';
import 'nature_match_game_screen.dart';
import 'safe_space_screen.dart';
import 'space_explorer_screen.dart';
import 'star_match_screen.dart';
import 'teddy_match_game_screen.dart';

class AllGamesScreen extends StatelessWidget {
  final ChildModel child;

  const AllGamesScreen({
    super.key,
    required this.child,
  });

  List<Map<String, dynamic>> get games => [
    {
      'emoji': '🧩',
      'title': 'Easy Puzzle',
      'subtitle': 'Solve simple and fun puzzles',
      'icon': Icons.extension_rounded,
    },
    {
      'emoji': '🔍',
      'title': 'Find It!',
      'subtitle': 'Find and discover hidden objects',
      'icon': Icons.search_rounded,
    },
    {
      'emoji': '🎨',
      'title': 'Color Match',
      'subtitle': 'Match colors and have fun',
      'icon': Icons.palette_rounded,
    },
    {
      'emoji': '🎈',
      'title': 'Balloon Pop',
      'subtitle': 'Pop balloons and enjoy',
      'icon': Icons.celebration_rounded,
    },
    {
      'emoji': '🧠',
      'title': 'Memory Match',
      'subtitle': 'Improve your memory skills',
      'icon': Icons.psychology_rounded,
    },
    {
      'emoji': '⭐',
      'title': 'Star Match',
      'subtitle': 'Match the stars together',
      'icon': Icons.star_rounded,
    },
    {
      'emoji': '🧸',
      'title': 'Teddy Match',
      'subtitle': 'Play with friendly teddy toys',
      'icon': Icons.toys_rounded,
    },
    {
      'emoji': '🌿',
      'title': 'Nature Match',
      'subtitle': 'Enjoy a relaxing nature activity',
      'icon': Icons.park_rounded,
    },
    {
      'emoji': '🎵',
      'title': 'Music Game',
      'subtitle': 'Play with sounds and music',
      'icon': Icons.music_note_rounded,
    },
    {
      'emoji': '🎁',
      'title': 'Mystery Box',
      'subtitle': 'Discover what is inside',
      'icon': Icons.card_giftcard_rounded,
    },
    {
      'emoji': '🚀',
      'title': 'Space Explorer',
      'subtitle': 'Explore the universe',
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'emoji': '🧘',
      'title': 'Calm Game',
      'subtitle': 'Relax with a peaceful activity',
      'icon': Icons.self_improvement_rounded,
    },
    {
      'emoji': '🌙',
      'title': 'Calm Night',
      'subtitle': 'A soft and relaxing experience',
      'icon': Icons.nightlight_round,
    },
    {
      'emoji': '🤗',
      'title': 'Safe Space',
      'subtitle': 'A gentle and comforting activity',
      'icon': Icons.favorite_rounded,
    },
    {
      'emoji': '🌈',
      'title': 'Happy Colors',
      'subtitle': 'Enjoy a colorful activity',
      'icon': Icons.color_lens_rounded,
    },
  ];

  void _openGame(
      BuildContext context,
      String title,
      ) {
    // Games screen එකෙන් open කරන නිසා
    // neutral default emotion එක pass කරනවා.
    const emotion = 'neutral';

    switch (title) {
      case 'Easy Puzzle':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EasyPuzzleScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Find It!':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FindItScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Color Match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ColorMatchGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Balloon Pop':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BalloonPopGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Memory Match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemoryMatchGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Star Match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StarMatchScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Teddy Match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeddyMatchGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Nature Match':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NatureMatchGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Music Game':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MusicGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Mystery Box':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MysteryBoxScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Space Explorer':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpaceExplorerScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Calm Game':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalmGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Calm Night':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalmNightScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Safe Space':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SafeSpaceScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;

      case 'Happy Colors':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ColorMatchGameScreen(
              childId: child.id,
              emotion: emotion,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  10,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Games',
                        style: TextStyle(
                          fontSize: 24,
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
                'Choose a game, ${child.name}! 🎮',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    24,
                  ),
                  itemCount: games.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.90,
                  ),
                  itemBuilder: (context, index) {
                    final game = games[index];

                    return InkWell(
                      onTap: () {
                        _openGame(
                          context,
                          game['title'] as String,
                        );
                      },
                      borderRadius:
                      BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              game['emoji'] as String,
                              style: const TextStyle(
                                fontSize: 52,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              game['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5B3FA6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              game['subtitle'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
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