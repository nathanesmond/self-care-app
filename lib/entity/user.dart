class User {
  final int idUser;
  final String email;
  final int idRole;
  final String? gender;
  final String? gymMembership;

  User({
    required this.idUser,
    required this.email,
    required this.idRole,
    this.gender,
    this.gymMembership,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: (json['id_user'] ?? json['id'] ?? 0) as int,
      email: (json['email'] ?? '') as String,
      idRole: (json['id_role'] ?? 2) as int,
      gender: json['gender'] as String?,
      gymMembership: json['gym_membership'] as String?,
    );
  }

  User copyWith({
    int? idUser,
    String? email,
    int? idRole,
    String? gender,
    String? gymMembership,
  }) {
    return User(
      idUser: idUser ?? this.idUser,
      email: email ?? this.email,
      idRole: idRole ?? this.idRole,
      gender: gender ?? this.gender,
      gymMembership: gymMembership ?? this.gymMembership,
    );
  }
}
