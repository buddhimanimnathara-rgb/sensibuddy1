class GuardianModel {
  final String id;
  final String childId;
  final String name;
  final String email;

  final String phone;
  final String relationship;
  final String createdAt;

  GuardianModel({
    required this.id,
    required this.childId,
    required this.name,
    required this.email,
    required this.phone,
    required this.relationship,
    required this.createdAt,
  });

  factory GuardianModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return GuardianModel(
      id: id,
      childId: data['childId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',

      phone: data['phone'] ?? '',
      relationship: data['relationship'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship,
      'createdAt': createdAt,
    };
  }
}