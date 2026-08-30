import '../models/child_interest_model.dart';

class ChildInterestService {
  ChildInterestModel? detectInterest({
    required String childId,
    required String message,
  }) {
    final text = message.toLowerCase().trim();

    String? interest;
    String category = 'general';


    // DINOSAURS


    if (text.contains('dinosaur') ||
        text.contains('dinosaurs') ||
        text.contains('dino') ||
        text.contains('ඩයිනෝ')) {
      interest = 'dinosaurs';
      category = 'education';
    }


    // ANIMALS


    else if (text.contains('animal') ||
        text.contains('animals') ||
        text.contains('dog') ||
        text.contains('cat') ||
        text.contains('lion') ||
        text.contains('elephant') ||
        text.contains('tiger') ||
        text.contains('monkey') ||
        text.contains('horse') ||
        text.contains('සතා') ||
        text.contains('සත්තු')) {
      interest = 'animals';
      category = 'education';
    }


    // SONGS / MUSIC


    else if (text.contains('song') ||
        text.contains('songs') ||
        text.contains('music') ||
        text.contains('sing') ||
        text.contains('sindu') ||
        text.contains('සින්දු') ||
        text.contains('සින්දුව') ||
        text.contains('ගීත') ||
        text.contains('ගීයක්')) {
      interest = 'songs';
      category = 'music';
    }


    // CARTOONS


    else if (text.contains('cartoon') ||
        text.contains('cartoons') ||
        text.contains('animation') ||
        text.contains('animated') ||
        text.contains('කාටූන්')) {
      interest = 'cartoons';
      category = 'entertainment';
    }


    // VEHICLES


    else if (text.contains('car') ||
        text.contains('cars') ||
        text.contains('vehicle') ||
        text.contains('vehicles') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('truck') ||
        text.contains('bike') ||
        text.contains('motorcycle') ||
        text.contains('වාහන') ||
        text.contains('කාර්') ||
        text.contains('බස්') ||
        text.contains('දුම්රිය')) {
      interest = 'vehicles';
      category = 'education';
    }


    // SPACE


    else if (text.contains('space') ||
        text.contains('planet') ||
        text.contains('planets') ||
        text.contains('moon') ||
        text.contains('sun') ||
        text.contains('star') ||
        text.contains('stars') ||
        text.contains('rocket') ||
        text.contains('astronaut') ||
        text.contains('අභ්‍යවකාශ') ||
        text.contains('ග්‍රහලෝක') ||
        text.contains('චන්ද්‍ර')) {
      interest = 'space';
      category = 'education';
    }


    // COLORS


    else if (text.contains('color') ||
        text.contains('colors') ||
        text.contains('colour') ||
        text.contains('colours') ||
        text.contains('red') ||
        text.contains('blue') ||
        text.contains('green') ||
        text.contains('yellow') ||
        text.contains('pink') ||
        text.contains('purple') ||
        text.contains('පාට') ||
        text.contains('වර්ණ')) {
      interest = 'colors';
      category = 'education';
    }


    // NUMBERS / MATH

    else if (text.contains('number') ||
        text.contains('numbers') ||
        text.contains('count') ||
        text.contains('counting') ||
        text.contains('math') ||
        text.contains('mathematics') ||
        text.contains('ගණන්') ||
        text.contains('අංක')) {
      interest = 'numbers';
      category = 'education';
    }


    // SPORTS

    else if (text.contains('sport') ||
        text.contains('sports') ||
        text.contains('football') ||
        text.contains('soccer') ||
        text.contains('cricket') ||
        text.contains('basketball') ||
        text.contains('ball') ||
        text.contains('ක්‍රීඩා') ||
        text.contains('පාපන්දු') ||
        text.contains('ක්‍රිකට්')) {
      interest = 'sports';
      category = 'sports';
    }


    // GAMES


    else if (text.contains('game') ||
        text.contains('games') ||
        text.contains('gaming') ||
        text.contains('play game') ||
        text.contains('සෙල්ලම්') ||
        text.contains('ගේම්')) {
      interest = 'games';
      category = 'entertainment';
    }


    // DRAWING / ART


    else if (text.contains('draw') ||
        text.contains('drawing') ||
        text.contains('paint') ||
        text.contains('painting') ||
        text.contains('art') ||
        text.contains('picture') ||
        text.contains('අඳින්න') ||
        text.contains('චිත්‍ර') ||
        text.contains('පාට කරන්න')) {
      interest = 'drawing';
      category = 'creative';
    }

    // STORIES / BOOKS / READING

    else if (text.contains('story') ||
        text.contains('stories') ||
        text.contains('book') ||
        text.contains('books') ||
        text.contains('read') ||
        text.contains('reading') ||
        text.contains('කතාව') ||
        text.contains('කතා') ||
        text.contains('පොත')) {
      interest = 'stories';
      category = 'education';
    }


    // SUPERHEROES


    else if (text.contains('superhero') ||
        text.contains('superheroes') ||
        text.contains('spiderman') ||
        text.contains('spider-man') ||
        text.contains('batman') ||
        text.contains('superman') ||
        text.contains('iron man') ||
        text.contains('hero')) {
      interest = 'superheroes';
      category = 'entertainment';
    }


    // ROBOTS / TECHNOLOGY


    else if (text.contains('robot') ||
        text.contains('robots') ||
        text.contains('technology') ||
        text.contains('computer') ||
        text.contains('coding') ||
        text.contains('robotics') ||
        text.contains('රොබෝ')) {
      interest = 'robots';
      category = 'technology';
    }


    // COOKING / FOOD


    else if (text.contains('cook') ||
        text.contains('cooking') ||
        text.contains('food') ||
        text.contains('cake') ||
        text.contains('pizza') ||
        text.contains('baking') ||
        text.contains('උයන්න') ||
        text.contains('කෑම') ||
        text.contains('කේක්')) {
      interest = 'cooking';
      category = 'creative';
    }

    // NATURE


    else if (text.contains('nature') ||
        text.contains('tree') ||
        text.contains('trees') ||
        text.contains('flower') ||
        text.contains('flowers') ||
        text.contains('forest') ||
        text.contains('rain') ||
        text.contains('tree') ||
        text.contains('ගස්') ||
        text.contains('මල්') ||
        text.contains('ස්වභාව')) {
      interest = 'nature';
      category = 'education';
    }


    // OCEAN / SEA


    else if (text.contains('ocean') ||
        text.contains('sea') ||
        text.contains('fish') ||
        text.contains('shark') ||
        text.contains('whale') ||
        text.contains('dolphin') ||
        text.contains('මුහුද') ||
        text.contains('මාළු') ||
        text.contains('මෝරා')) {
      interest = 'ocean';
      category = 'education';
    }


    // BIRDS


    else if (text.contains('bird') ||
        text.contains('birds') ||
        text.contains('parrot') ||
        text.contains('eagle') ||
        text.contains('owl') ||
        text.contains('කුරුල්ලා') ||
        text.contains('කුරුල්ලන්')) {
      interest = 'birds';
      category = 'education';
    }


    // SCIENCE


    else if (text.contains('science') ||
        text.contains('experiment') ||
        text.contains('scientist') ||
        text.contains('discovery') ||
        text.contains('විද්‍යා') ||
        text.contains('පරීක්ෂණ')) {
      interest = 'science';
      category = 'education';
    }

    // DANCE


    else if (text.contains('dance') ||
        text.contains('dancing') ||
        text.contains('නාටන්න') ||
        text.contains('නර්තනය')) {
      interest = 'dancing';
      category = 'creative';
    }

    // NO INTEREST DETECTED

    if (interest == null) {
      return null;
    }

    final now = DateTime.now();

    return ChildInterestModel(
      id: '${childId}_${interest}_$category',
      childId: childId,
      interest: interest,
      category: category,
      frequency: 1,
      isAllowed: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}