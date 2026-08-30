class GuardianFaceModel {
  final String guardianId;
  final String childId;
  final String imageData;
  final bool registered;
  final int faceCount;
  final String createdAt;

  final List<dynamic>? embeddings;

  GuardianFaceModel({
    required this.guardianId,
    required this.childId,
    required this.imageData,
    required this.registered,
    required this.faceCount,
    required this.embeddings,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "guardianId": guardianId,
      "childId": childId,
      "imageData": imageData,
      "registered": registered,
      "faceCount": faceCount,
      "embedding": embeddings,
      "createdAt": createdAt,
    };
  }

  factory GuardianFaceModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return GuardianFaceModel(
      guardianId:
      map["guardianId"] ?? "",
      childId:
      map["childId"] ?? "",
      imageData:
      map["imageData"] ?? "",
      registered:
      map["registered"] ?? false,
      faceCount:
      map["faceCount"] ?? 0,
      embeddings: map["embeddings"],
      createdAt:
      map["createdAt"] ?? "",
    );
  }
}