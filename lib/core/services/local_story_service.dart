import '../models/story_model.dart';

class LocalStoryService {
  // GET STORIES BY LANGUAGE

  List<StoryModel> getStoriesByLanguage(String language) {
    final normalizedLanguage = _normalizeLanguage(language);

    return _allStories
        .where(
          (story) => story.language == normalizedLanguage,
    )
        .toList();
  }

  // GET STORIES BY EMOTION + LANGUAGE


  List<StoryModel> getStoriesByEmotionAndLanguage({
    required String emotion,
    required String language,
  }) {
    final normalizedLanguage =
    _normalizeLanguage(language);

    final normalizedEmotion =
    _normalizeEmotion(emotion);

    return _allStories.where((story) {
      final storyEmotion =
      _normalizeEmotion(story.emotion);

      return story.language == normalizedLanguage &&
          storyEmotion == normalizedEmotion;
    }).toList();
  }

  String _normalizeEmotion(String emotion) {
    switch (emotion.toLowerCase().trim()) {
      case 'natural':
      case 'neutral':
        return 'neutral';

      case 'angry':
      case 'anger':
        return 'angry';

      case 'fear':
        return 'fear';

      case 'joy':
        return 'joy';

      case 'sadness':
        return 'sadness';

      case 'surprise':
        return 'surprise';

      default:
        return emotion.toLowerCase().trim();
    }
  }

  // NORMALIZE LANGUAGE

  String _normalizeLanguage(String language) {
    switch (language.toLowerCase().trim()) {
      case 'si':
      case 'sinhala':
        return 'si';

      case 'ta':
      case 'tamil':
        return 'ta';

      case 'en':
      case 'english':
      default:
        return 'en';
    }
  }

  // ALL LOCAL STORIES


  final List<StoryModel> _allStories = [

    // ENGLISH STORIES

    StoryModel(
      id: 'angry_001_en',
      emotion: 'angry',
      language: 'en',
      title: 'The Little Bear Calms Down 🐻',
      content: '''
Little Bear could not find his favorite toy.

He felt very angry.

He stopped for a moment and took slow breaths.

Soon, Little Bear felt calm again.
''',
      lesson: 'When you feel angry, stop and take slow breaths.',
    ),

    StoryModel(
      id: 'fear_001_en',
      emotion: 'fear',
      language: 'en',
      title: 'The Brave Little Bird 🐦',
      content: '''
Little Bird was afraid to enter a dark room.

He held his mother's hand and slowly walked inside.

After a little while, he felt safer.
''',
      lesson: 'When you feel afraid, ask someone you trust for help.',
    ),

    StoryModel(
      id: 'joy_001_en',
      emotion: 'joy',
      language: 'en',
      title: "Bunny's Happy Day 🐰",
      content: '''
One bright morning, Little Bunny woke up feeling very happy.

The sun was shining, and the birds were singing outside.

Little Bunny hopped into the garden and saw all his friends playing together.

“Come and play with us!” they happily called.

Little Bunny jumped, laughed, and played many fun games with his friends.

Soon, it was time for a little snack.

Little Bunny had some delicious carrots, so he decided to share them with everyone.

His friends smiled and said, “Thank you!”

Little Bunny felt even happier.

He learned that happiness can grow when we share it with others.

At the end of the day, Little Bunny went home with a big smile.

It had been a wonderful and happy day.
''',
      lesson: 'Sharing happiness and kindness can make everyone smile.',
    ),

    StoryModel(
      id: 'neutral_001_en',
      emotion: 'neutral',
      language: 'en',
      title: 'A Calm Day 🌤️',
      content: '''
A little child woke up in the morning.

They slowly completed their daily activities.

It was a calm and peaceful day.
''',
      lesson: 'Feeling calm is a good feeling too.',
    ),

    StoryModel(
      id: 'sadness_001_en',
      emotion: 'sadness',
      language: 'en',
      title: 'The Little Elephant Feels Sad 🐘',
      content: '''
Little Elephant's favorite toy broke.

He felt very sad.

He told his friend how he felt.

His friend stayed with him and helped him.
''',
      lesson: 'When you feel sad, talk to someone you trust.',
    ),

    StoryModel(
      id: 'surprise_001_en',
      emotion: 'surprise',
      language: 'en',
      title: 'The Surprise Gift 🎁',
      content: '''
Little Cat walked into the room.

There was a beautiful surprise waiting inside.

Little Cat was very surprised and happy.
''',
      lesson: 'New things can sometimes surprise us.',
    ),

    // ==========================================================
    // SINHALA STORIES
    // ==========================================================

    StoryModel(
      id: 'angry_001_si',
      emotion: 'angry',
      language: 'si',
      title: 'පුංචි වලසා සන්සුන් වුණා 🐻',
      content: '''
පුංචි වලසා තමන්ගේ ප්‍රියතම සෙල්ලම් බඩුව හොයාගන්න බැරි නිසා ගොඩක් කේන්ති ගත්තා.

ඔහු ටිකක් නතර වී හෙමින් හුස්ම ගත්තා.

ටික වෙලාවකට පස්සේ ඔහු සන්සුන් වුණා.
''',
      lesson: 'කේන්ති ගිය විට ටිකක් නතර වී හෙමින් හුස්ම ගන්න.',
    ),

    StoryModel(
      id: 'fear_001_si',
      emotion: 'fear',
      language: 'si',
      title: 'පුංචි කුරුල්ලාගේ ධෛර්යය 🐦',
      content: '''
පුංචි කුරුල්ලා අඳුරු කාමරයකට යන්න බය වුණා.

ඔහු අම්මාගේ අත අල්ලාගෙන හෙමින් ඇතුළට ගියා.

ටික වෙලාවකට පස්සේ ඔහුට බය අඩු වුණා.
''',
      lesson: 'බය දැනෙන විට විශ්වාස කරන කෙනෙකුගෙන් උදව් ඉල්ලන්න.',
    ),

    StoryModel(
      id: 'joy_001_si',
      emotion: 'joy',
      language: 'si',
      title: 'පුංචි හාවාගේ සතුටු දවස 🐰',
      content: '''
එක් ලස්සන උදෑසනක පුංචි හාවා සතුටින් අවදි වුණා.

එළියෙන් හිරු පායමින් තිබුණා.
කුරුල්ලෝ ලස්සනට ගී ගයමින් සිටියා.

පුංචි හාවා සතුටින් තමන්ගේ ගෙදරින් එළියට පැනලා උයනට ගියා.

එහිදී ඔහු දැක්කා තමන්ගේ යාළුවෝ හැමෝම එකට සෙල්ලම් කරනවා.

“එන්න! අපිත් එක්ක සෙල්ලම් කරන්න!” කියලා යාළුවෝ සතුටින් කතා කළා.

පුංචි හාවාත් ඔවුන් සමඟ දුවලා, පැනලා, හිනා වෙලා ගොඩක් සතුටින් සෙල්ලම් කළා.

ටික වෙලාවකට පස්සේ හැමෝටම බඩගිනි වුණා.

පුංචි හාවා ළඟ රසවත් කැරට් තිබුණා.

ඔහු තමන්ගේ කැරට් යාළුවෝ හැමෝම සමඟ බෙදා ගත්තා.

යාළුවෝ හැමෝම සතුටින් හිනා වෙලා,
“ස්තුතියි!” කියලා කිව්වා.

ඒ දැකපු පුංචි හාවාට තවත් සතුටු හිතුණා.

එදා ඔහු ලස්සන පාඩමක් ඉගෙන ගත්තා.

අපේ සතුට සහ ආදරය
අනිත් අය සමඟ බෙදා ගත්තොත්,
හැමෝගේම මුහුණට ලස්සන සිනහවක් ගේන්න පුළුවන්.

එදා පුංචි හාවාට
ඉතාම සතුටු දවසක් වුණා.
''',
      lesson:
      'අපේ සතුට සහ ආදරය අනිත් අය සමඟ බෙදා ගත් විට, හැමෝම සතුටු වෙනවා.',
    ),

    StoryModel(
      id: 'neutral_001_si',
      emotion: 'neutral',
      language: 'si',
      title: 'සන්සුන් දවසක් 🌤️',
      content: '''
පුංචි දරුවා උදෑසන අවදි වුණා.

ඔහු තමන්ගේ දෛනික වැඩ හෙමින් සහ සතුටින් කළා.

එය සන්සුන් සහ ලස්සන දවසක් වුණා.
''',
      lesson: 'සන්සුන්ව සිටීමත් හොඳ හැඟීමක්.',
    ),

    StoryModel(
      id: 'sadness_001_si',
      emotion: 'sadness',
      language: 'si',
      title: 'පුංචි අලියාට දුක හිතුණා 🐘',
      content: '''
පුංචි අලියාගේ සෙල්ලම් බඩුව කැඩුණා.

ඔහුට ගොඩක් දුක හිතුණා.

ඔහු තමන්ගේ යාළුවාට ඒ ගැන කිව්වා.

යාළුවා ඔහුට උදව් කළා.
''',
      lesson:
      'දුක දැනෙන විට අපගේ හැඟීම් විශ්වාස කරන කෙනෙකුට කියන්න.',
    ),

    StoryModel(
      id: 'surprise_001_si',
      emotion: 'surprise',
      language: 'si',
      title: 'පුදුම තෑග්ග 🎁',
      content: '''
පුංචි පූසා කාමරයට ඇතුළු වුණා.

එහි ලස්සන පුදුම තෑග්ගක් තිබුණා.

පුංචි පූසා ගොඩක් පුදුම වුණා සහ සතුටු වුණා.
''',
      lesson: 'අලුත් දේවල් සමහර වෙලාවට අපිව පුදුමයට පත් කරයි.',
    ),

    // ==========================================================
    // TAMIL STORIES
    // ==========================================================

    StoryModel(
      id: 'angry_001_ta',
      emotion: 'angry',
      language: 'ta',
      title: 'சிறிய கரடி அமைதியானது 🐻',
      content: '''
சிறிய கரடிக்கு தனது பிடித்த பொம்மை கிடைக்கவில்லை.

அதனால் அது மிகவும் கோபமடைந்தது.

அது சிறிது நேரம் நின்று மெதுவாக மூச்சை எடுத்தது.

பின்னர் அது அமைதியானது.
''',
      lesson: 'கோபம் வந்தால் சிறிது நேரம் நின்று மெதுவாக மூச்சு விடுங்கள்.',
    ),

    StoryModel(
      id: 'fear_001_ta',
      emotion: 'fear',
      language: 'ta',
      title: 'தைரியமான சிறிய பறவை 🐦',
      content: '''
சிறிய பறவை இருண்ட அறைக்குள் செல்ல பயந்தது.

அது தனது அம்மாவின் கையை பிடித்துக்கொண்டு மெதுவாக உள்ளே சென்றது.

சிறிது நேரத்தில் அது பாதுகாப்பாக உணர்ந்தது.
''',
      lesson: 'பயம் வந்தால் நம்பிக்கையான ஒருவரிடம் உதவி கேளுங்கள்.',
    ),

    StoryModel(
      id: 'joy_001_ta',
      emotion: 'joy',
      language: 'ta',
      title: 'முயலின் மகிழ்ச்சியான நாள் 🐰',
      content: '''
ஒரு அழகான காலையில், சின்ன முயல் மிகவும் மகிழ்ச்சியாக விழித்தது.

வெளியில் சூரியன் பிரகாசித்துக் கொண்டிருந்தது.
பறவைகள் இனிமையாக பாடிக் கொண்டிருந்தன.

சின்ன முயல் மகிழ்ச்சியுடன் தோட்டத்திற்குத் துள்ளிச் சென்றது.

அங்கே அதன் நண்பர்கள் அனைவரும் சேர்ந்து விளையாடிக் கொண்டிருந்தார்கள்.

“வா! எங்களுடன் விளையாடு!” என்று நண்பர்கள் மகிழ்ச்சியுடன் அழைத்தார்கள்.

சின்ன முயலும் அவர்களுடன் சேர்ந்து ஓடியது, துள்ளியது, சிரித்தது.

சிறிது நேரம் கழித்து, அனைவருக்கும் பசி எடுத்தது.

சின்ன முயலிடம் சுவையான கேரட்டுகள் இருந்தன.

அது தனது கேரட்டுகளை நண்பர்களுடன் பகிர்ந்து கொண்டது.

அதன் நண்பர்கள் அனைவரும் மகிழ்ச்சியுடன் சிரித்து, “நன்றி!” என்று சொன்னார்கள்.

அதைப் பார்த்த சின்ன முயலுக்கு இன்னும் அதிக மகிழ்ச்சி ஏற்பட்டது.

அன்று அது ஒரு அழகான விஷயத்தை கற்றுக்கொண்டது.

நமது மகிழ்ச்சியையும் அன்பையும் மற்றவர்களுடன் பகிர்ந்தால்,
அது அனைவரின் முகத்திலும் ஒரு அழகான புன்னகையை உருவாக்கும்.

அந்த நாள் சின்ன முயலுக்கு மிகவும் மகிழ்ச்சியான நாளாக இருந்தது.
''',
      lesson:
      'மகிழ்ச்சியையும் அன்பையும் மற்றவர்களுடன் பகிர்ந்தால் அனைவரும் மகிழ்ச்சியாக இருப்பார்கள்.',
    ),

    StoryModel(
      id: 'neutral_001_ta',
      emotion: 'neutral',
      language: 'ta',
      title: 'அமைதியான ஒரு நாள் 🌤️',
      content: '''
ஒரு சிறிய குழந்தை காலையில் எழுந்தது.

அது தனது தினசரி செயல்களை மெதுவாக செய்தது.

அது ஒரு அமைதியான நாள்.
''',
      lesson: 'அமைதியாக இருப்பதும் ஒரு நல்ல உணர்வு.',
    ),

    StoryModel(
      id: 'sadness_001_ta',
      emotion: 'sadness',
      language: 'ta',
      title: 'சிறிய யானைக்கு சோகம் வந்தது 🐘',
      content: '''
சிறிய யானையின் பிடித்த பொம்மை உடைந்தது.

அதற்கு மிகவும் சோகம் வந்தது.

அது தனது நண்பரிடம் தனது உணர்வை கூறியது.

நண்பர் அதற்கு உதவி செய்தார்.
''',
      lesson: 'சோகம் வந்தால் நம்பிக்கையான ஒருவரிடம் பேசுங்கள்.',
    ),

    StoryModel(
      id: 'surprise_001_ta',
      emotion: 'surprise',
      language: 'ta',
      title: 'ஆச்சரியமான பரிசு 🎁',
      content: '''
சிறிய பூனை அறைக்குள் சென்றது.

அங்கே ஒரு அழகான ஆச்சரியமான பரிசு இருந்தது.

அது மிகவும் ஆச்சரியப்பட்டு மகிழ்ந்தது.
''',
      lesson: 'புதிய விஷயங்கள் சில நேரங்களில் நம்மை ஆச்சரியப்படுத்தும்.',
    ),
  ];
}