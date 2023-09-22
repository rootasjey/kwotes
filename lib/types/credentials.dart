class Credentials {
  Credentials({
    required this.email,
    required this.password,
  });

  /// User email to authenticate.
  final String email;

  /// User password to authenticate.
  final String password;
}
