import 'package:flutter/material.dart';

import '../../core/models/child_model.dart';
import '../../core/services/firestore_service.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final ChildModel child;

  const CharacterSelectionScreen({
    super.key,
    required this.child,
  });

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState
    extends State<CharacterSelectionScreen> {
  final FirestoreService _firestoreService =
  FirestoreService();

  String? selectedCharacter;

  final List<Map<String, String>> characters = [
    {
      'id': 'girl',
      'name': 'Girl',
      'image': 'assets/images/characters/girl.png',
    },
    {
      'id': 'robot',
      'name': 'Robot',
      'image': 'assets/images/characters/robot.png',
    },
    {
      'id': 'teddy',
      'name': 'Teddy',
      'image': 'assets/images/characters/teddy.png',
    },
    {
      'id': 'bunny',
      'name': 'Bunny',
      'image': 'assets/images/characters/bunny.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    selectedCharacter = widget.child.selectedCharacter;
  }


  // LANGUAGE

  String get language => widget.child.language.toLowerCase();


  // TITLE


  String get title {
    switch (language) {
      case 'si':
        return 'ඔයාගේ යාළුවා තෝරන්න 💜';

      case 'ta':
        return 'உங்கள் நண்பரை தேர்வு செய்யுங்கள் 💜';

      default:
        return 'Choose Your Friend 💜';
    }
  }


  // SUBTITLE

  String get subtitle {
    switch (language) {
      case 'si':
        return 'ඔයා සමඟ කතා කරන SensiBuddy යාළුවා තෝරන්න';

      case 'ta':
        return 'உங்களுடன் பேசும் SensiBuddy நண்பரை தேர்வு செய்யுங்கள்';

      default:
        return 'Choose the SensiBuddy friend who will talk with you';
    }
  }


  // CONTINUE TEXT


  String get continueText {
    switch (language) {
      case 'si':
        return 'ඉදිරියට යමු';

      case 'ta':
        return 'தொடரவும்';

      default:
        return 'Continue';
    }
  }


  // CHARACTER NAME


  String getCharacterName(String id) {
    switch (language) {
      case 'si':
        switch (id) {
          case 'girl':
            return 'ගැහැණු යාළුවා';

          case 'robot':
            return 'රොබෝ';

          case 'teddy':
            return 'ටෙඩි';

          case 'bunny':
            return 'බනී';

          default:
            return id;
        }

      case 'ta':
        switch (id) {
          case 'girl':
            return 'நண்பி';

          case 'robot':
            return 'ரோபோ';

          case 'teddy':
            return 'டெடி';

          case 'bunny':
            return 'முயல்';

          default:
            return id;
        }

      default:
        switch (id) {
          case 'girl':
            return 'Girl';

          case 'robot':
            return 'Robot';

          case 'teddy':
            return 'Teddy';

          case 'bunny':
            return 'Bunny';

          default:
            return id;
        }
    }
  }


  // SELECT CHARACTER


  void _selectCharacter(String characterId) {
    setState(() {
      selectedCharacter = characterId;
    });
  }


  // CONTINUE + SAVE TO FIRESTORE

  Future<void> _continue() async {
    if (selectedCharacter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language == 'si'
                ? 'කරුණාකර යාළුවෙක් තෝරන්න 💜'
                : language == 'ta'
                ? 'தயவுசெய்து ஒரு நண்பரை தேர்வு செய்யுங்கள் 💜'
                : 'Please choose a friend 💜',
          ),
        ),
      );

      return;
    }

    try {
      // Loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Save selected character
      await _firestoreService.updateChild(
        widget.child.id,
        {
          'selectedCharacter': selectedCharacter,
        },
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language == 'si'
                ? 'ඔයාගේ යාළුවා සාර්ථකව තෝරාගත්තා! 💜'
                : language == 'ta'
                ? 'உங்கள் நண்பர் தேர்வு செய்யப்பட்டார்! 💜'
                : 'Your AI friend has been selected! 💜',
          ),
        ),
      );

      // Return selected character
      Navigator.of(context).pop(selectedCharacter);
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog safely
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving character: $e',
          ),
        ),
      );
    }
  }


  // BUILD


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SensiBuddy ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            24,
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D315B),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),


              // CHARACTER GRID


              Expanded(
                child: GridView.builder(
                  itemCount: characters.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final character = characters[index];

                    final characterId = character['id']!;
                    final isSelected =
                        selectedCharacter == characterId;

                    return GestureDetector(
                      onTap: () {
                        _selectCharacter(characterId);
                      },
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(28),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7B61FF)
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFF7B61FF)
                                  .withOpacity(0.25)
                                  : Colors.black
                                  .withOpacity(0.08),
                              blurRadius:
                              isSelected ? 20 : 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: AnimatedScale(
                                duration: const Duration(
                                  milliseconds: 250,
                                ),
                                scale:
                                isSelected ? 1.08 : 1.0,
                                child: Image.asset(
                                  character['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              getCharacterName(characterId),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF7B61FF)
                                    : Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            SizedBox(
                              height: 25,
                              child: AnimatedOpacity(
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                opacity:
                                isSelected ? 1 : 0,
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF7B61FF),
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),


              // CONTINUE BUTTON

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF7B61FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    continueText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}