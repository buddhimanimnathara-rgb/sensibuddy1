import 'child_model.dart';
import 'guardian_model.dart';
import 'assessment_model.dart';
import 'ai_character_model.dart';


// AI CONVERSATION MODE
enum AIConversationMode {
  child,
  guardian,
  guest,
}

// AI CONVERSATION CONTEXT
class AIConversationContext {
  final AIConversationMode mode;

  // CHILD DATA
  final ChildModel child;

  // GUARDIAN DATA
  final GuardianModel? guardian;

  // CHILD ASSESSMENT DATA
  final AssessmentModel? assessment;

  // CURRENT EMOTION
  final String emotion;

  final AICharacterModel character;

  // PERSON NAME
  // Used for recognized child / guardian / guest
  final String? personName;

  AIConversationContext({
    required this.mode,
    required this.child,
    this.guardian,
    this.assessment,
    required this.emotion,
    this.personName,
    required this.character,
  });

  // HELPERS
  bool get isChildMode {
    return mode == AIConversationMode.child;
  }

  bool get isGuardianMode {
    return mode == AIConversationMode.guardian;
  }

  bool get isGuestMode {
    return mode == AIConversationMode.guest;
  }

  bool get isRecognizedUser {
    return isChildMode || isGuardianMode;
  }
}