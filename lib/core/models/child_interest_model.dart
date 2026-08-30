class ChildInterestModel {
  final String id;
  final String childId;

  // Example:
  // animal songs
  // dinosaurs
  // cartoons
  // colors
  final String interest;

  // music / cartoon / education / general
  final String category;

  // How many times this interest was detected
  final int frequency;

  // Whether parent allows this interest/category
  final bool isAllowed;

  // Created date
  final DateTime createdAt;

  // Last detected date
  final DateTime updatedAt;

  const ChildInterestModel({
    required this.id,
    required this.childId,
    required this.interest,
    required this.category,
    required this.frequency,
    required this.isAllowed,
    required this.createdAt,
    required this.updatedAt,
  });

  ChildInterestModel copyWith({
    String? id,
    String? childId,
    String? interest,
    String? category,
    int? frequency,
    bool? isAllowed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildInterestModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      interest: interest ?? this.interest,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      isAllowed: isAllowed ?? this.isAllowed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'interest': interest,
      'category': category,
      'frequency': frequency,
      'isAllowed': isAllowed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChildInterestModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return ChildInterestModel(
      id: data['id'] ?? '',
      childId: data['childId'] ?? '',
      interest: data['interest'] ?? '',
      category: data['category'] ?? 'general',
      frequency: data['frequency'] ?? 1,
      isAllowed: data['isAllowed'] ?? true,
      createdAt: DateTime.tryParse(
        data['createdAt'] ?? '',
      ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
        data['updatedAt'] ?? '',
      ) ??
          DateTime.now(),
    );
  }
}