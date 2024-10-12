class User {
  final int id;
  final String username;
  final String password;
  final int roleId;

  User({required this.id, required this.username, required this.password, required this.roleId});

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      roleId: json['role_id'],
    );
  }
}
