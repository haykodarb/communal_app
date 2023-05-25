class LoginForm {
  String email;
  String password;

  LoginForm({
    required this.email,
    required this.password,
  });

  Map<String, String> toMap() {
    return {
      "email": email,
      "password": password,
    };
  }
}
