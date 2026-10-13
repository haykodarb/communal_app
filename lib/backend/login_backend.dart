import 'dart:io';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/login_form.dart';
import 'package:communal/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class LoginBackend {
  static const String _webClientId = '77347798204-2mtvb57qeb4gmmks3ep7ikth565i9vca.apps.googleusercontent.com';

  // google_sign_in must be initialized exactly once before any other call.
  static Future<void>? _googleSignInInit;

  static Future<void> _initGoogleSignIn() {
    return _googleSignInInit ??= GoogleSignIn.instance.initialize(serverClientId: _webClientId);
  }

  static Future<BackendResponse> login({required LoginForm form}) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        password: form.password,
        email: form.email,
      );

      return BackendResponse(
        success: response.session != null,
        payload: response.user,
      );
    } on AuthException catch (exception) {
      return BackendResponse(
        success: false,
        payload: exception.message,
      );
    }
  }

  static Future<BackendResponse> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: RouteNames.appRoot + RouteNames.startPage,
          authScreenLaunchMode: LaunchMode.platformDefault,
        );

        return BackendResponse(success: true);
      }

      if (Platform.isAndroid) {
        await _initGoogleSignIn();

        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

        final String? idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          throw 'No ID Token found.';
        }

        const List<String> scopes = ['email', 'profile'];
        final GoogleSignInClientAuthorization authorization =
            await googleUser.authorizationClient.authorizationForScopes(scopes) ??
                await googleUser.authorizationClient.authorizeScopes(scopes);

        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: authorization.accessToken,
        );

        return BackendResponse(success: true);
      }

      return BackendResponse(success: false);
    } on GoogleSignInException catch (err) {
      // Closed the account picker.
      if (err.code == GoogleSignInExceptionCode.canceled) return BackendResponse(success: false);

      return BackendResponse(success: false, error: err.toString());
    } catch (err) {
      return BackendResponse(success: false, error: err.toString());
    }
  }

  static Future<BackendResponse> sendRecoveryEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://app.communal.ar/#/auth/reset',
      );

      return BackendResponse(success: true, payload: 'Recovery email succesfully sent to $email.');
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static Future<BackendResponse> updateUserPassword(String password) async {
    try {
      final UserResponse response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      final bool success = response.user != null;

      return BackendResponse(
        success: success,
        payload: success
            ? 'Password updated succesfully, you can now login with your new password.'
            : 'Error in updating password, please try again.',
      );
    } catch (e) {
      return BackendResponse(
        success: false,
        payload: 'Please request a new password reset and follow the link in your email.',
      );
    }
  }

  static Future<void> logout() async {
    // The web signs in through Supabase's OAuth redirect, not google_sign_in.
    if (!kIsWeb && Platform.isAndroid) {
      await _initGoogleSignIn();
      await GoogleSignIn.instance.signOut();
    }

    await Supabase.instance.client.auth.signOut();
  }
}
