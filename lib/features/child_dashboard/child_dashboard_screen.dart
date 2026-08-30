import 'package:flutter/material.dart';
import '../../screens/child/stories_screen.dart';

import '../../core/models/child_model.dart';
import '../../core/services/firestore_service.dart';
import '../ai_character/ai_character_screen.dart';
import '../ai_character/character_selection_screen.dart';
import '../emotion/emotion_scan_screen.dart';
import '../games/all_games_screen.dart';

class ChildDashboardScreen extends StatefulWidget {
  final String childId;
  final String guardianId;

  const ChildDashboardScreen({
    super.key,
    required this.childId,
    required this.guardianId,
  });

  @override
  State<ChildDashboardScreen> createState() =>
      _ChildDashboardScreenState();
}

class _ChildDashboardScreenState
    extends State<ChildDashboardScreen> {
  bool _isLoading = true;
  ChildModel? _child;

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {
    try {
      final child =
      await firestoreService.getChild(widget.childId);

      if (!mounted) return;

      setState(() {
        _child = child;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading child: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  bool get _isSinhala => _child?.language == "si";
  bool get _isTamil => _child?.language == "ta";

  String getText(
      String english,
      String sinhala,
      String tamil,
      ) {
    if (_isSinhala) return sinhala;
    if (_isTamil) return tamil;
    return english;
  }

  String getGreeting() {
    final name = _child?.name ?? "";

    return getText(
      "Hello $name! 👋",
      "ආයුබෝවන් $name! 👋",
      "வணக்கம் $name! 👋",
    );
  }

  String getSubtitle() {
    return getText(
      "Let's have fun together today! ",
      "අද අපි එකට විනෝද වෙමු! ",
      "இன்று நாம் ஒன்றாக மகிழ்வோம்! ",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),

      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        )
            : _child == null
            ? _buildError()
            : _buildDashboard(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "😔",
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              "Unable to load child information.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                _loadChild();
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final isSmallPhone = screenWidth < 360;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isSmallPhone ? 16 : 20,
            16,
            isSmallPhone ? 16 : 20,
            35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TOP HEADER

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallPhone ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5B3FA6),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          getSubtitle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallPhone ? 12 : 14,
                            color: Colors.black54,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    width: isSmallPhone ? 46 : 54,
                    height: isSmallPhone ? 46 : 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD7E8),
                      borderRadius:
                      BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF5C9A),
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // COLORFUL AI MASCOT HERO

              _MascotHeroCard(
                screenWidth: screenWidth,
                isSmallPhone: isSmallPhone,
                title: getText(
                  "Hi Friend! 🌈",
                  "හෙලෝ යාළුවා! 🌈",
                  "வணக்கம் நண்பா! 🌈",
                ),
                message: getText(
                  "I'm happy to spend time with you today! 💜",
                  "අද ඔයා එක්ක කාලය ගත කරන්න මට සතුටුයි! 💜",
                  "இன்று உங்களுடன் நேரம் செலவிட நான் மகிழ்ச்சியாக இருக்கிறேன்! 💜",
                ),
              ),

              const SizedBox(height: 24),

              // EMOTION CHECK

              _EmotionCard(
                title: getText(
                  "How do you feel?",
                  "ඔයාට කොහොමද දැනෙන්නේ?",
                  "நீங்கள் எப்படி உணர்கிறீர்கள்?",
                ),
                subtitle: getText(
                  "Let's check your emotion!",
                  "අපි ඔයාගේ හැඟීම බලමු!",
                  "உங்கள் உணர்ச்சியை பார்க்கலாம்!",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmotionScanScreen(
                        child: _child!,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ACTIVITIES TITLE

              Text(
                getText(
                  "Let's Have Fun! 🎉",
                  "අපි විනෝද වෙමු! 🎉",
                  "வேடிக்கை பார்க்கலாம்! 🎉",
                ),
                style: TextStyle(
                  fontSize: isSmallPhone ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5B3FA6),
                ),
              ),

              const SizedBox(height: 16),

              // COLORFUL ACTIVITY GRID

              GridView.count(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,

                crossAxisSpacing:
                isSmallPhone ? 12 : 16,

                mainAxisSpacing:
                isSmallPhone ? 12 : 16,

                childAspectRatio:
                isSmallPhone ? 1.0 : 1.05,

                children: [

                  _FeatureCard(
                    title: getText(
                      "Talk",
                      "කතා කරමු",
                      "பேசலாம்",
                    ),
                    subtitle: getText(
                      "Chat with me",
                      "මා එක්ක කතා කරන්න",
                      "என்னுடன் பேசுங்கள்",
                    ),
                    emoji: "💬",
                    color: const Color(0xFFE5DDFF),
                    onTap: () async {
                      if (_child == null) return;

                      if (_child!.selectedCharacter == null ||
                          _child!.selectedCharacter!.isEmpty) {
                        final selectedCharacter = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CharacterSelectionScreen(
                              child: _child!,
                            ),
                          ),
                        );

                        if (selectedCharacter == null) return;

                        setState(() {
                          _child = _child!.copyWith(
                            selectedCharacter: selectedCharacter,
                          );
                        });
                      }

                      if (!mounted || _child == null) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AICharacterScreen(
                            child: _child!,
                          ),
                        ),
                      );
                    },
                  ),

                  _FeatureCard(
                    title: getText(
                      "Games",
                      "ක්‍රීඩා",
                      "விளையாட்டுகள்",
                    ),
                    subtitle: getText(
                      "Let's play",
                      "සෙල්ලම් කරමු",
                      "விளையாடலாம்",
                    ),
                    emoji: "🎮",
                    color: const Color(0xFFFFE2BF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllGamesScreen(
                            child: _child!,
                        ),
                      ),
                      );
                    },
                  ),

                  _FeatureCard(
                    title: getText(
                      "Stories",
                      "කතාන්දර",
                      "கதைகள்",
                    ),
                    subtitle: getText(
                      "Listen & learn",
                      "අසා ඉගෙන ගමු",
                      "கேட்டு கற்போம்",
                    ),
                    emoji: "📚",
                    color: const Color(0xFFCFF2E4),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoriesScreen(
                              language: _child!.language,
                            ),
                          ),
                      );
                    },
                  ),

                  _FeatureCard(
                    title: getText(
                      "Songs",
                      "ගීත",
                      "பாடல்கள்",
                    ),
                    subtitle: getText(
                      "Sing with me",
                      "මා සමඟ ගයමු",
                      "என்னுடன் பாடுங்கள்",
                    ),
                    emoji: "🎵",
                    color: const Color(0xFFFFD8E8),
                    onTap: () {
                      // TODO: Songs
                    },
                  ),

                  _FeatureCard(
                    title: getText(
                      "Speech",
                      "කථන පුහුණුව",
                      "பேச்சுப் பயிற்சி",
                    ),
                    subtitle: getText(
                      "Practice speaking",
                      "කතා කිරීම පුහුණු කරමු",
                      "பேச பயிற்சி செய்வோம்",
                    ),
                    emoji: "🎤",
                    color: const Color(0xFFD7EEFF),
                    onTap: () {
                      // TODO: Speech
                    },
                  ),

                  _FeatureCard(
                    title: getText(
                      "My Progress",
                      "මගේ ප්‍රගතිය",
                      "என் முன்னேற்றம்",
                    ),
                    subtitle: getText(
                      "See your stars",
                      "ඔයාගේ තරු බලන්න",
                      "உங்கள் நட்சத்திரங்களை பாருங்கள்",
                    ),
                    emoji: "⭐",
                    color: const Color(0xFFFFF0B8),
                    onTap: () {
                      // TODO: Progress
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


// =================================================
// AI MASCOT HERO CARD
// =================================================

class _MascotHeroCard extends StatelessWidget {
  final double screenWidth;
  final bool isSmallPhone;
  final String title;
  final String message;

  const _MascotHeroCard({
    required this.screenWidth,
    required this.isSmallPhone,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final heroHeight = isSmallPhone ? 165.0 : 185.0;

    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7454D8),
            Color(0xFF9A85F3),
            Color(0xFFC2B5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x337454D8),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),

        child: Stack(
          children: [

            // Decorative circle - top right
            Positioned(
              right: -35,
              top: -45,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Decorative circle - bottom left
            Positioned(
              left: -35,
              bottom: -55,
              child: Container(
                width: 135,
                height: 135,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Small sparkle
            const Positioned(
              top: 22,
              right: 125,
              child: Text(
                "✨",
                style: TextStyle(fontSize: 20),
              ),
            ),

            // TEXT SECTION
            Positioned(
              left: isSmallPhone ? 18 : 22,
              top: isSmallPhone ? 24 : 28,
              width: screenWidth * 0.48,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                      isSmallPhone ? 19 : 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    message,
                    maxLines: isSmallPhone ? 4 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                      isSmallPhone ? 11 : 13,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ),

            // MASCOT SECTION
            Positioned(
              right: isSmallPhone ? -5 : 0,
              bottom: -2,
              child: Image.asset(
                "assets/images/mascot.png",
                height: isSmallPhone ? 150 : 178,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =================================================
// EMOTION CARD
// =================================================

class _EmotionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EmotionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),

        child: Ink(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),

            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            children: [

              Container(
                width: 64,
                height: 64,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6A8),
                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: const Center(
                  child: Text(
                    "😊",
                    style: TextStyle(fontSize: 35),
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
                      title,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                        color: Color(0xFF5B3FA6),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF7454D8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =================================================
// COLORFUL FEATURE CARD
// =================================================

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),

        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(26),

            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [

                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 42,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B3FA6),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}