import 'package:communal/models/backend_response.dart';
import 'package:communal/models/register_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterBackend {
  static Future<BackendResponse> register({required RegisterForm form}) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final Map<String, dynamic>? foundUsername =
          await client.from('profiles').select().eq('username', form.username).maybeSingle();

      if (foundUsername != null) {
        return BackendResponse(
          success: false,
          payload: 'Username already used, please choose another one',
        );
      }

      final AuthResponse signUpResponse = await client.auth.signUp(
        password: form.password,
        email: form.email,
        emailRedirectTo: 'https://app.communal.ar/#/auth',
        data: {
          'username': form.username,
        },
      );

      return BackendResponse(
        success: signUpResponse.user != null,
        payload: signUpResponse.user,
      );
    } on AuthException catch (error) {
      return BackendResponse(
        success: false,
        payload: error.message,
      );
    }
  }

  static Future<BackendResponse> resendEmail({required String email}) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      await client.auth.resend(
        type: OtpType.signup,
        emailRedirectTo: 'https://app.communal.ar/#/auth',
        email: email,
      );

      return BackendResponse(success: true, payload: 'Confirmation email resent. Please check your inbox.');
    } catch (error) {
      print(error);
      return BackendResponse(success: false, payload: 'Server error. Could not resend confirmation email.');
    }
  }
}
