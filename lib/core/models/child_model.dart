class ChildModel {
  final String id;
  final String name;
  final String ageRange;
  final String gender;
  final String diagnosis;
  final String language;

  // SELECTED AI CHARACTER
  final String? selectedCharacter;

  ChildModel({
    required this.id,
    required this.name,
    required this.ageRange,
    required this.gender,
    required this.diagnosis,
    required this.language,
    this.selectedCharacter,
  });

  // FROM FIRESTORE
  factory ChildModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return ChildModel(
      id: id,
      name: data['name'] ?? '',
      ageRange: data['ageRange'] ?? '',
      gender: data['gender'] ?? '',
      diagnosis: data['diagnosis'] ?? 'No Diagnosis Yet',
      language: data['language'] ?? 'en',

      // Selected AI character
      selectedCharacter: data['selectedCharacter'],
    );
  }


  // TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ageRange': ageRange,
      'gender': gender,
      'diagnosis': diagnosis,
      'language': language,

      // Selected AI character
      'selectedCharacter': selectedCharacter,
    };
  }

  // COPY WITH
  ChildModel copyWith({
    String? id,
    String? name,
    String? ageRange,
    String? gender,
    String? diagnosis,
    String? language,
    String? selectedCharacter,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      diagnosis: diagnosis ?? this.diagnosis,
      language: language ?? this.language,
      selectedCharacter:
      selectedCharacter ?? this.selectedCharacter,
    );
  }
}