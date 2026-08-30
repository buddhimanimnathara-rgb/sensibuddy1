import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../activities/all_activities_screen.dart';
import '../ai_character/ai_character_screen.dart';

class EmotionChoiceScreen extends StatelessWidget {
  final ChildModel child;
  final String emotion;
  final double confidence;

  const EmotionChoiceScreen({
    super.key,
    required this.child,
    required this.emotion,
    required this.confidence,
  });

  // EMOTION EMOJI

  String getEmotionEmoji() {
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

  // EMOTION NAME

  String getEmotionName() {
    switch (emotion.toLowerCase()) {
      case 'angry':
        if (child.language == 'si') return 'කේන්තියෙන්';
        if (child.language == 'ta') return 'கோபமாக';
        return 'Angry';

      case 'fear':
        if (child.language == 'si') return 'බියෙන්';
        if (child.language == 'ta') return 'பயமாக';
        return 'Scared';

      case 'joy':
        if (child.language == 'si') return 'සතුටින්';
        if (child.language == 'ta') return 'மகிழ்ச்சியாக';
        return 'Happy';

      case 'sadness':
        if (child.language == 'si') return 'දුකෙන්';
        if (child.language == 'ta') return 'சோகமாக';
        return 'Sad';

      case 'surprise':
        if (child.language == 'si') return 'පුදුමයෙන්';
        if (child.language == 'ta') return 'ஆச்சரியமாக';
        return 'Surprised';

      case 'neutral':
      default:
        if (child.language == 'si') return 'සන්සුන්ව';
        if (child.language == 'ta') return 'அமைதியாக';
        return 'Calm';
    }
  }


  // SCREEN TITLE


  String getTitle() {
    switch (child.language) {
      case 'si':
        return 'ඔයාට කොහොමද?';

      case 'ta':
        return 'நீங்கள் எப்படி உணர்கிறீர்கள்?';

      default:
        return 'How do you feel?';
    }
  }


  // AI MESSAGE


  String getMessage() {
    final name = child.name;

    switch (child.language) {
      case 'si':
        switch (emotion.toLowerCase()) {
          case 'angry':
            return '$name, ඔයා ටිකක් කේන්තියෙන් වගේ පේනවා. '
                'අපි ටිකක් සන්සුන් වෙමුද?';

          case 'fear':
            return '$name, ඔයා ටිකක් බය වෙලා වගේ පේනවා. '
                'මම ඔයා එක්ක ඉන්නවා.';

          case 'joy':
            return '$name, ඔයා සතුටින් වගේ පේනවා! '
                'අපි එකට මොනවාහරි විනෝද වෙමුද?';

          case 'sadness':
            return '$name, ඔයා ටිකක් දුකෙන් වගේ පේනවා. '
                'ඔයාට කැමති නම් මට කතා කරන්න පුළුවන්.';

          case 'surprise':
            return '$name, ඔයා ටිකක් පුදුම වෙලා වගේ පේනවා! '
                'අපි එකට බලමුද මොකද වෙලා තියෙන්නේ කියලා?';

          case 'neutral':
          default:
            return '$name, ඔයා සන්සුන්ව ඉන්නවා වගේ පේනවා. '
                'ඔයාට කැමති දෙයක් කරමුද?';
        }

      case 'ta':
        switch (emotion.toLowerCase()) {
          case 'angry':
            return '$name, நீங்கள் கொஞ்சம் கோபமாக இருப்பது போல் தெரிகிறது. '
                'நாம் கொஞ்சம் அமைதியாக இருப்போமா?';

          case 'fear':
            return '$name, நீங்கள் கொஞ்சம் பயமாக இருப்பது போல் தெரிகிறது. '
                'நான் உங்களுடன் இருக்கிறேன்.';

          case 'joy':
            return '$name, நீங்கள் மகிழ்ச்சியாக இருக்கிறீர்கள்! '
                'நாம் சேர்ந்து ஏதாவது வேடிக்கையாக செய்வோமா?';

          case 'sadness':
            return '$name, நீங்கள் கொஞ்சம் சோகமாக இருப்பது போல் தெரிகிறது. '
                'நீங்கள் விரும்பினால் என்னுடன் பேசலாம்.';

          case 'surprise':
            return '$name, நீங்கள் ஆச்சரியமாக இருப்பது போல் தெரிகிறது! '
                'என்ன நடந்தது என்று பார்ப்போமா?';

          case 'neutral':
          default:
            return '$name, நீங்கள் அமைதியாக இருப்பது போல் தெரிகிறது. '
                'உங்களுக்கு பிடித்த ஏதாவது செய்வோமா?';
        }

      default:
        switch (emotion.toLowerCase()) {
          case 'angry':
            return '$name, you look a little angry. '
                'Would you like to calm down together?';

          case 'fear':
            return '$name, you look a little scared. '
                'I am here with you.';

          case 'joy':
            return '$name, you look happy! '
                'Would you like to do something fun together?';

          case 'sadness':
            return '$name, you look a little sad. '
                'You can talk with me if you want.';

          case 'surprise':
            return '$name, you look surprised! '
                'Shall we see what happened?';

          case 'neutral':
          default:
            return '$name, you look calm. '
                'Would you like to choose something you enjoy?';
        }
    }
  }


  // TALK BUTTON TEXT

  String getTalkText() {
    switch (child.language) {
      case 'si':
        return 'Buddy එක්ක කතා කරන්න';

      case 'ta':
        return 'Buddy உடன் பேசுங்கள்';

      default:
        return 'Talk with Buddy';
    }
  }

  // ACTIVITY BUTTON TEXT

  String getActivityText() {
    switch (child.language) {
      case 'si':
        return 'මට කැමති දෙයක් කරන්න';

      case 'ta':
        return 'எனக்கு பிடித்ததை செய்யுங்கள்';

      default:
        return 'Do Something I Like';
    }
  }

  // BACK BUTTON

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }


  // TALK WITH BUDDY

  void talkWithBuddy(BuildContext context) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          child.language == 'si'
              ? 'Buddy සමඟ කතා කිරීම ඉක්මනින් සූදානම් කරමු 🤖'
              : child.language == 'ta'
              ? 'Buddy உடன் பேசும் வசதி விரைவில் தயாராகும் 🤖'
              : 'Talking with Buddy will be ready soon 🤖',
        ),
      ),
    );
  }


  // ALL ACTIVITIES

  void openActivities(BuildContext context) {
    // NEXT STEP:
    // Navigate to AllActivitiesScreen

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          child.language == 'si'
              ? 'Games, Songs, Stories සහ Activities ඉක්මනින් මෙතනට එනවා ✨'
              : child.language == 'ta'
              ? 'Games, Songs, Stories மற்றும் Activities விரைவில் வரும் ✨'
              : 'Games, Songs, Stories and Activities will appear here ✨',
        ),
      ),
    );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),

            child: Column(
              children: [
                // TOP BAR

                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: IconButton(
                        onPressed: () => goBack(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        getTitle(),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B3FA6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // EMOTION RESULT CARD

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7B61FF),
                        Color(0xFFA18CFF),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B61FF).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      const Text(
                        'Your Emotion',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        getEmotionEmoji(),
                        style: const TextStyle(
                          fontSize: 100,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        getEmotionName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${(confidence * 100).toStringAsFixed(0)}% detected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // BUDDY MESSAGE

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,

                        decoration: BoxDecoration(
                          color: const Color(0xFFECE7FF),
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Color(0xFF7B61FF),
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        getMessage(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // TALK WITH BUDDY BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AICharacterScreen(
                            child: child,
                            emotion: emotion,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.smart_toy_rounded,
                      size: 28,
                    ),
                    label: Text(
                      getTalkText(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // CHOOSE ANY ACTIVITY BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllActivitiesScreen(
                            child: child,
                            emotion: emotion,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7B61FF),
                      elevation: 2,
                      side: const BorderSide(
                        color: Color(0xFF7B61FF),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 26,
                    ),
                    label: Text(
                      getActivityText(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}