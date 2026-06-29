
class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  // Combines data from Supabase auth (email) + profiles table (name)
  factory UserModel.fromSupabase({
    required String id,
    required String email,
    required Map<String, dynamic> profile,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: profile['name'] as String? ?? 'Driver',
      createdAt: profile['created_at'] != null
          ? DateTime.parse(profile['created_at'] as String)
          : null,
    );
  }

  // For reading directly from profiles table row
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'Driver',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'created_at': createdAt?.toIso8601String(),
      };
}