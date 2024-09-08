class myUser {
  final String name;
  final String email;
  final String initial;
  final String password;
  final String username;
  final String? profilePicture;
  final String? id;

  myUser(  {required this.username,
    required this.id,
    required this.password,
    required this.name,
    required this.email,
    required this.initial,
    required this.profilePicture,
  });
}