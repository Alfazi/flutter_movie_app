class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
