class RegisterForm {
  String username;
  String password;
  String email;

  RegisterForm({
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, String> toMap() {
    return {
      "username": username,
      "password": password,
      "email": email,
    };
  }
}
