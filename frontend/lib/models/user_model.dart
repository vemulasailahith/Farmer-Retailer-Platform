class UserProfile {
  final String id;
  final String fullName;
  final String role;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: (map['role'] as String? ?? 'farmer').toLowerCase().trim(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
