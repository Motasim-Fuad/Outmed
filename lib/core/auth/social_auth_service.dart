import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

typedef SocialCredential = ({
  String provider,
  String token,
  String fullName,
  String avatarUrl,
});

class SocialAuthService {
  bool _googleReady = false;

  bool get googleEnabled =>
      !kIsWeb &&
      AppEnv.googleServerClientId.isNotEmpty &&
      (Platform.isAndroid ||
          (Platform.isIOS && AppEnv.googleIosClientId.isNotEmpty));

  bool get appleEnabled =>
      !kIsWeb && Platform.isIOS && AppEnv.appleSignInEnabled;

  Future<SocialCredential?> google() async {
    final signIn = GoogleSignIn.instance;
    if (!_googleReady) {
      await signIn.initialize(
        clientId: Platform.isIOS ? AppEnv.googleIosClientId : null,
        serverClientId: AppEnv.googleServerClientId,
      );
      _googleReady = true;
    }
    try {
      final account = await signIn.authenticate(scopeHint: const ['email']);
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) return null;
      return (
        provider: 'google',
        token: token,
        fullName: account.displayName ?? '',
        avatarUrl: account.photoUrl ?? '',
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<SocialCredential?> apple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final token = credential.identityToken;
      if (token == null || token.isEmpty) return null;
      final name = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
      return (provider: 'apple', token: token, fullName: name, avatarUrl: '');
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
