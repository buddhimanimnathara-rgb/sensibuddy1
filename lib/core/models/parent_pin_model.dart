class ParentPinModel {
  final String guardianId;
  final String pin;

  ParentPinModel({
    required this.guardianId,
    required this.pin,
  });

  Map<String, dynamic> toMap() {
    return {
      "guardianId": guardianId,
      "pin": pin,
    };
  }
}