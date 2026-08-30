class ContentPermissionModel {
  final String id;

  final String childId;

  final String topic;

  final bool isAllowed;

  final DateTime createdAt;

  final DateTime updatedAt;

  ContentPermissionModel({
    required this.id,
    required this.childId,
    required this.topic,
    required this.isAllowed,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'topic': topic,
      'isAllowed': isAllowed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ContentPermissionModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return ContentPermissionModel(
      id: data['id'] ?? '',
      childId: data['childId'] ?? '',
      topic: data['topic'] ?? '',
      isAllowed: data['isAllowed'] ?? false,
      createdAt:
      DateTime.tryParse(
        data['createdAt'] ?? '',
      ) ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(
        data['updatedAt'] ?? '',
      ) ??
          DateTime.now(),
    );
  }
}