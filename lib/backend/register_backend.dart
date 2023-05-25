import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/register_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterBackend {
  static Future<BackendReponse> register({required RegisterForm form}) async {
    final AuthResponse response = await Supabase.instance.client.auth.signUp(
      password: form.password,
      email: form.email,
    );

    final BackendReponse parsedResponse = BackendReponse(
      success: response.user != null,
      payload: response.user,
    );

    return parsedResponse;
  }
}
