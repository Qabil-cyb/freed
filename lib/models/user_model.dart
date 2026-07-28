class UserModel {
  final String uuid;
  final String email;
  final String fullName;
  final String username;
  final String role;
  final bool isActive;
  final String imageUrl;

  UserModel({
    required this.uuid,
    required this.email,
    required this.fullName,
    this.username = '',
    required this.role,
    required this.isActive,
    this.imageUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = (json['email'] ?? '') as String;
    final username = (json['username'] ?? '') as String;
    return UserModel(
      uuid: json['uuid'] ?? '',
      email: email,
      fullName: json['fullName'] ?? '',
      username: username.isNotEmpty ? username : email,
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'email': email,
      'fullName': fullName,
      'username': username,
      'role': role,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }
}
