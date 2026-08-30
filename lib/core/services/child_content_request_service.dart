class ChildContentRequest {
  final String topic;
  final bool isVideoRequest;
  final bool isKnownTopic;

  ChildContentRequest({
    required this.topic,
    required this.isVideoRequest,
    required this.isKnownTopic,
  });
}

class ChildContentRequestService {
  ChildContentRequest? detectRequest({
    required String message,
  }) {
    final text = message.toLowerCase().trim();


    // CHECK WHETHER USER IS ASKING FOR CONTENT

    final isContentRequest =
    // ENGLISH
    text.contains('video') ||
        text.contains('videos') ||
        text.contains('watch') ||
        text.contains('play') ||
        text.contains('show me') ||

        // SINHALA
        text.contains('බලන්න') ||
        text.contains('බලමු') ||
        text.contains('වීඩියෝ') ||
        text.contains('වීඩියෝවක්') ||
        text.contains('පෙන්වන්න') ||

        // TAMIL
        text.contains('வீடியோ') ||
        text.contains('பார்க்க') ||
        text.contains('பார்') ||
        text.contains('காட்டு') ||
        text.contains('காட்டுங்கள்') ||
        text.contains('இயக்கு');

    if (!isContentRequest) {
      return null;
    }

    // ==========================================
    // DINOSAURS
    // ==========================================

    if (text.contains('dinosaur') ||
        text.contains('dinosaurs') ||
        text.contains('dino') ||
        text.contains('ඩයිනෝ') ||
        text.contains('டைனோசர்') ||
        text.contains('டைனோசர்கள்')) {
      return ChildContentRequest(
        topic: 'dinosaurs',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }

    // ==========================================
    // ANIMALS
    // ==========================================

    if (text.contains('animal') ||
        text.contains('animals') ||
        text.contains('dog') ||
        text.contains('cat') ||
        text.contains('lion') ||
        text.contains('elephant') ||
        text.contains('සතා') ||
        text.contains('සත්තු') ||
        text.contains('விலங்கு') ||
        text.contains('விலங்குகள்') ||
        text.contains('நாய்') ||
        text.contains('பூனை') ||
        text.contains('சிங்கம்') ||
        text.contains('யானை')) {
      return ChildContentRequest(
        topic: 'animals',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }

    // ==========================================
    // VEHICLES
    // ==========================================

    if (text.contains('car') ||
        text.contains('cars') ||
        text.contains('vehicle') ||
        text.contains('vehicles') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('කාර්') ||
        text.contains('වාහන') ||
        text.contains('படகு') ||
        text.contains('கார்') ||
        text.contains('வண்டி') ||
        text.contains('பேருந்து') ||
        text.contains('ரயில்')) {
      return ChildContentRequest(
        topic: 'vehicles',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }

    // ==========================================
    // SONGS / MUSIC
    // ==========================================

    if (text.contains('song') ||
        text.contains('songs') ||
        text.contains('music') ||
        text.contains('sindu') ||
        text.contains('සින්දු') ||
        text.contains('සින්දුව') ||
        text.contains('ගීත') ||
        text.contains('பாடல்') ||
        text.contains('பாடல்கள்') ||
        text.contains('இசை')) {
      return ChildContentRequest(
        topic: 'songs',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }

    // ==========================================
    // STORIES
    // ==========================================

    if (text.contains('story') ||
        text.contains('stories') ||
        text.contains('කතාව') ||
        text.contains('කතා') ||
        text.contains('கதை') ||
        text.contains('கதைகள்')) {
      return ChildContentRequest(
        topic: 'stories',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }

    // ==========================================
    // CARTOONS
    // ==========================================

    if (text.contains('cartoon') ||
        text.contains('cartoons') ||
        text.contains('animation') ||
        text.contains('කාටූන්') ||
        text.contains('கார்ட்டூன்') ||
        text.contains('அனிமேஷன்')) {
      return ChildContentRequest(
        topic: 'cartoons',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }

    // ==========================================
    // SPACE
    // ==========================================

    if (text.contains('space') ||
        text.contains('planet') ||
        text.contains('planets') ||
        text.contains('rocket') ||
        text.contains('අභ්‍යවකාශ') ||
        text.contains('ග්‍රහලෝක') ||
        text.contains('விண்வெளி') ||
        text.contains('கிரகம்') ||
        text.contains('கிரகங்கள்') ||
        text.contains('ராக்கெட்')) {
      return ChildContentRequest(
        topic: 'space',
        isVideoRequest: true,
        isKnownTopic: true,
      );
    }


    // UNKNOWN CONTENT

    final unknownTopic = _extractUnknownTopic(text);

    return ChildContentRequest(
      topic: unknownTopic,
      isVideoRequest: true,
      isKnownTopic: false,
    );
  }


  // EXTRACT UNKNOWN TOPIC

  String _extractUnknownTopic(String text) {
    var topic = text;

    final wordsToRemove = [

      'i want to',
      'want to',
      'please',
      'show me',
      'watch',
      'play',
      'video',
      'videos',
      'a video',
      'the video',
      'can i',
      'can we',


      'මට',
      'මෙයාට',
      'අපිට',
      'බලන්න',
      'බලමු',
      'ඕන',
      'එකක්',
      'වීඩියෝ',
      'වීඩියෝවක්',
      'පෙන්වන්න',
      'කරන්න',
      'දෙන්න',



      'எனக்கு',
      'எனக்குப்',
      'எங்களுக்கு',
      'வேண்டும்',
      'வேணும்',
      'பார்க்க வேண்டும்',
      'பார்க்க',
      'பார்',
      'காட்டு',
      'காட்டுங்கள்',
      'வீடியோவை',
      'வீடியோ',
      'ஒரு',
      'இயக்கு',
      'தயவுசெய்து',
    ];

    // Longer phrases first
    wordsToRemove.sort(
          (a, b) => b.length.compareTo(a.length),
    );

    for (final word in wordsToRemove) {
      topic = topic.replaceAll(word, ' ');
    }

    // Remove extra spaces
    topic = topic
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();

    if (topic.isEmpty) {
      return 'general_content';
    }

    return topic;
  }
}