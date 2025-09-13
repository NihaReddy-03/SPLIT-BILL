class GroupMember {
  final String id;
  final String name;
  final String email;
  bool isActive;

  GroupMember({
    required this.id,
    required this.name,
    required this.email,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isActive': isActive,
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isActive: json['isActive'] ?? true,
    );
  }
}