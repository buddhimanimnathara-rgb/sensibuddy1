import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../screens/child/emotion_filtered_stories_screen.dart';
import 'emotion_filtered_games_screen.dart';

class AllActivitiesScreen extends StatelessWidget {
  final ChildModel child;
  final String emotion;

  const AllActivitiesScreen({
    super.key,
    required this.child,
    required this.emotion,
  });


  // EMOTION DETAILS

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

  String get emotionTitle {
    switch (child.language) {
      case 'si':
        return 'ඔයාට ගැලපෙන දේවල්';
      case 'ta':
        return 'உங்களுக்கு ஏற்றவை';
      default:
        return 'Recommended for You';
    }
  }

  String get subtitle {
    switch (child.language) {
      case 'si':
        return '$emotionEmoji ඔයාගේ හැඟීමට ගැලපෙන දේවල් තෝරන්න';
      case 'ta':
        return '$emotionEmoji உங்கள் உணர்வுக்கு ஏற்ற ஒன்றை தேர்வு செய்யுங்கள்';
      default:
        return '$emotionEmoji Choose something that suits how you feel';
    }
  }


  // CATEGORY TEXT
  String get gamesText {
    switch (child.language) {
      case 'si':
        return 'Games';
      case 'ta':
        return 'விளையாட்டுகள்';
      default:
        return 'Games';
    }
  }

  String get songsText {
    switch (child.language) {
      case 'si':
        return 'Songs';
      case 'ta':
        return 'பாடல்கள்';
      default:
        return 'Songs';
    }
  }

  String get storiesText {
    switch (child.language) {
      case 'si':
        return 'Stories';
      case 'ta':
        return 'கதைகள்';
      default:
        return 'Stories';
    }
  }

  String get activitiesText {
    switch (child.language) {
      case 'si':
        return 'Activities';
      case 'ta':
        return 'செயல்பாடுகள்';
      default:
        return 'Activities';
    }
  }

  // EMOTION MESSAGE

  String get emotionMessage {
    switch (child.language) {
      case 'si':
        switch (emotion.toLowerCase()) {
          case 'sadness':
            return 'අපි ඔයාට ටිකක් සතුටු හිතෙන දෙයක් කරමුද? 💜';
          case 'angry':
            return 'අපි ටිකක් සන්සුන් වෙලා හොඳ දෙයක් කරමුද? 🌿';
          case 'fear':
            return 'ඔයා ආරක්ෂිතයි. අපි සන්සුන් දෙයක් කරමු. 🤗';
          case 'joy':
            return 'ඔයා සතුටින් ඉන්නවා! අපි තව විනෝද වෙමු! 🎉';
          case 'surprise':
            return 'අලුත් දෙයක් සොයා බලමුද? ✨';
          case 'neutral':
          default:
            return 'ඔයාට කැමති දෙයක් තෝරන්න! 🌈';
        }

      case 'ta':
        switch (emotion.toLowerCase()) {
          case 'sadness':
            return 'உங்களை மகிழ்ச்சியாக உணரச் செய்யும் ஒன்றை செய்வோமா? 💜';
          case 'angry':
            return 'கொஞ்சம் அமைதியாகி நல்ல ஒன்றை செய்வோமா? 🌿';
          case 'fear':
            return 'நீங்கள் பாதுகாப்பாக இருக்கிறீர்கள். அமைதியான ஒன்றை செய்வோம். 🤗';
          case 'joy':
            return 'நீங்கள் மகிழ்ச்சியாக இருக்கிறீர்கள்! இன்னும் வேடிக்கையாக இருப்போம்! 🎉';
          case 'surprise':
            return 'புதிய ஒன்றை ஆராய்வோமா? ✨';
          case 'neutral':
          default:
            return 'உங்களுக்கு பிடித்த ஒன்றை தேர்வு செய்யுங்கள்! 🌈';
        }

      default:
        switch (emotion.toLowerCase()) {
          case 'sadness':
            return 'Would you like to do something that may help you feel better? 💜';
          case 'angry':
            return 'Let us do something calm and relaxing. 🌿';
          case 'fear':
            return 'You are safe. Let us do something calming. 🤗';
          case 'joy':
            return 'You are feeling happy! Let us have more fun! 🎉';
          case 'surprise':
            return 'Would you like to explore something new? ✨';
          case 'neutral':
          default:
            return 'Choose something you enjoy! 🌈';
        }
    }
  }


  // CATEGORY SUBTITLES

  String get gamesSubtitle {
    switch (emotion.toLowerCase()) {
      case 'sadness':
        return child.language == 'si'
            ? 'සන්සුන් සහ සතුටුදායක games'
            : child.language == 'ta'
            ? 'அமைதியான மற்றும் மகிழ்ச்சியான விளையாட்டுகள்'
            : 'Calming and uplifting games';

      case 'angry':
        return child.language == 'si'
            ? 'සන්සුන් වීමට games'
            : child.language == 'ta'
            ? 'அமைதியாக உதவும் விளையாட்டுகள்'
            : 'Calming games';

      case 'fear':
        return child.language == 'si'
            ? 'සරල සහ ආරක්ෂිත games'
            : child.language == 'ta'
            ? 'எளிய மற்றும் பாதுகாப்பான விளையாட்டுகள்'
            : 'Simple and comforting games';

      case 'joy':
        return child.language == 'si'
            ? 'විනෝද games'
            : child.language == 'ta'
            ? 'வேடிக்கையான விளையாட்டுகள்'
            : 'Fun games';

      case 'surprise':
        return child.language == 'si'
            ? 'අලුත් දේවල් සොයන games'
            : child.language == 'ta'
            ? 'புதியவற்றை கண்டறியும் விளையாட்டுகள்'
            : 'Discovery games';

      default:
        return child.language == 'si'
            ? 'ඔයාට කැමති games'
            : child.language == 'ta'
            ? 'உங்களுக்கு பிடித்த விளையாட்டுகள்'
            : 'Games you may enjoy';
    }
  }

  String get songsSubtitle {
    switch (emotion.toLowerCase()) {
      case 'sadness':
        return child.language == 'si'
            ? 'සතුටුදායක සහ සන්සුන් songs'
            : child.language == 'ta'
            ? 'மகிழ்ச்சியான மற்றும் அமைதியான பாடல்கள்'
            : 'Comforting and happy songs';

      case 'angry':
        return child.language == 'si'
            ? 'සන්සුන් songs'
            : child.language == 'ta'
            ? 'அமைதியான பாடல்கள்'
            : 'Relaxing songs';

      case 'fear':
        return child.language == 'si'
            ? 'මෘදු සහ සන්සුන් songs'
            : child.language == 'ta'
            ? 'மென்மையான மற்றும் அமைதியான பாடல்கள்'
            : 'Gentle songs';

      case 'joy':
        return child.language == 'si'
            ? 'විනෝද songs'
            : child.language == 'ta'
            ? 'மகிழ்ச்சியான பாடல்கள்'
            : 'Happy songs';

      case 'surprise':
        return child.language == 'si'
            ? 'අලුත් සහ විනෝද songs'
            : child.language == 'ta'
            ? 'புதிய மற்றும் வேடிக்கையான பாடல்கள்'
            : 'Fun songs';

      default:
        return child.language == 'si'
            ? 'ඔයාට කැමති songs'
            : child.language == 'ta'
            ? 'உங்களுக்கு பிடித்த பாடல்கள்'
            : 'Songs you may enjoy';
    }
  }

  String get storiesSubtitle {
    switch (emotion.toLowerCase()) {
      case 'sadness':
        return child.language == 'si'
            ? 'සතුටුදායක සහ ආදරණීය stories'
            : child.language == 'ta'
            ? 'ஆறுதல் தரும் கதைகள்'
            : 'Comforting stories';

      case 'angry':
        return child.language == 'si'
            ? 'සන්සුන් වීමට උපකාරී stories'
            : child.language == 'ta'
            ? 'அமைதியாக உதவும் கதைகள்'
            : 'Calming stories';

      case 'fear':
        return child.language == 'si'
            ? 'ආරක්ෂාව ගැන stories'
            : child.language == 'ta'
            ? 'பாதுகாப்பை உணர்த்தும் கதைகள்'
            : 'Reassuring stories';

      case 'joy':
        return child.language == 'si'
            ? 'විනෝද stories'
            : child.language == 'ta'
            ? 'வேடிக்கையான கதைகள்'
            : 'Fun stories';

      case 'surprise':
        return child.language == 'si'
            ? 'අලුත් දේවල් ගැන stories'
            : child.language == 'ta'
            ? 'புதிய விஷயங்களைப் பற்றிய கதைகள்'
            : 'Interesting stories';

      default:
        return child.language == 'si'
            ? 'ඔයාට කැමති stories'
            : child.language == 'ta'
            ? 'உங்களுக்கு பிடித்த கதைகள்'
            : 'Stories you may enjoy';
    }
  }

  String get activitiesSubtitle {
    switch (emotion.toLowerCase()) {
      case 'sadness':
        return child.language == 'si'
            ? 'හිත සතුටු කරන activities'
            : child.language == 'ta'
            ? 'மனதை மகிழ்விக்கும் செயல்பாடுகள்'
            : 'Activities to lift your mood';

      case 'angry':
        return child.language == 'si'
            ? 'සන්සුන් වීමට activities'
            : child.language == 'ta'
            ? 'அமைதியாக உதவும் செயல்பாடுகள்'
            : 'Calming activities';

      case 'fear':
        return child.language == 'si'
            ? 'සුවපහසු activities'
            : child.language == 'ta'
            ? 'ஆறுதல் தரும் செயல்பாடுகள்'
            : 'Comforting activities';

      case 'joy':
        return child.language == 'si'
            ? 'විනෝද activities'
            : child.language == 'ta'
            ? 'வேடிக்கையான செயல்பாடுகள்'
            : 'Fun activities';

      case 'surprise':
        return child.language == 'si'
            ? 'සොයා බැලීමේ activities'
            : child.language == 'ta'
            ? 'புதியவற்றை ஆராயும் செயல்பாடுகள்'
            : 'Exploration activities';

      default:
        return child.language == 'si'
            ? 'ඔයාට කැමති activities'
            : child.language == 'ta'
            ? 'உங்களுக்கு பிடித்த செயல்பாடுகள்'
            : 'Activities you may enjoy';
    }
  }


  // BUILD

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
                        emotionTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(22, 10, 22, 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  emotionMessage,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF5B3FA6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  // Slightly taller cards
                  childAspectRatio: 0.85,

                  children: [
                    _ActivityCard(
                      icon: Icons.sports_esports_rounded,
                      title: gamesText,
                      subtitle: gamesSubtitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmotionFilteredGamesScreen(
                              child: child,
                              emotion: emotion,
                            ),
                          ),
                        );
                      },
                    ),

                    _ActivityCard(
                      icon: Icons.music_note_rounded,
                      title: songsText,
                      subtitle: songsSubtitle,
                      onTap: () {
                        // Next: EmotionFilteredSongsScreen
                      },
                    ),

                    _ActivityCard(
                      icon: Icons.menu_book_rounded,
                      title: storiesText,
                      subtitle: storiesSubtitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmotionFilteredStoriesScreen(
                              child: child,
                              emotion: emotion,
                            ),
                          ),
                        );
                      },
                    ),

                    _ActivityCard(
                      icon: Icons.auto_awesome_rounded,
                      title: activitiesText,
                      subtitle: activitiesSubtitle,
                      onTap: () {
                        // Next: EmotionFilteredActivitiesScreen
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ACTIVITY CARD

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFECE7FF),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                icon,
                size: 30,
                color: const Color(0xFF7B61FF),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B3FA6),
              ),
            ),

            const SizedBox(height: 4),

            Flexible(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}