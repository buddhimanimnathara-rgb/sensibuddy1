class ChildFaceModel {
  final String childId;
  final String imageData;
  final bool registered;
  final int faceCount;
  final List<dynamic>? embedding;
  final String createdAt;

  ChildFaceModel({
    required this.childId,
    required this.imageData,
    required this.registered,
    required this.faceCount,
    required this.embedding,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "childId": childId,
      "imageData": imageData,
      "registered": registered,
      "faceCount": faceCount,
      "embedding": embedding,
      "createdAt": createdAt,
    };
  }

  factory ChildFaceModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ChildFaceModel(
      childId:
      map["childId"] ?? "",

      imageData:
      map["imageData"] ?? "",

      registered:
      map["registered"] ?? false,

      faceCount:
      map["faceCount"] ?? 0,

      embedding: map["embedding"],

      createdAt:
      map["createdAt"] ?? "",
    );
  }
}