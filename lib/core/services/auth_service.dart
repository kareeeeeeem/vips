import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Thin wrapper around Firebase Auth + the social provider SDKs.
/// Shared by both the merchant and user apps so the Google/Facebook/Apple/
/// phone sign-in flows aren't duplicated per app. Callers are responsible
/// for exchanging the resulting Firebase credential for a VIPs backend JWT
/// (see LoginController._loginWithBackend / MerchantAuthController).
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  GoogleSignIn? __googleSignIn;
  GoogleSignIn get _googleSignIn => __googleSignIn ??= GoogleSignIn();

  User? getCurrentUser() => _firebaseAuth.currentUser;

  bool isLoggedIn() => _firebaseAuth.currentUser != null;

  Stream<User?> streamUser() => _firebaseAuth.authStateChanges();

  /// Returns null if the user cancels the Google account picker.
  Future<UserCredential?> signInWithGoogle() async {
    debugPrint('[GOOGLE_AUTH] opening account picker...');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('[GOOGLE_AUTH] user canceled the picker');
      return null;
    }
    debugPrint('[GOOGLE_AUTH] picker returned account: ${googleUser.email}');

    debugPrint('[GOOGLE_AUTH] requesting Google auth tokens...');
    final googleAuth = await googleUser.authentication;
    debugPrint('[GOOGLE_AUTH] got tokens (idToken present: ${googleAuth.idToken != null})');
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    debugPrint('[GOOGLE_AUTH] exchanging credential with Firebase...');
    final result = await _firebaseAuth.signInWithCredential(credential);
    debugPrint('[GOOGLE_AUTH] Firebase sign-in complete: ${result.user?.uid}');
    return result;
  }

  /// Returns null if the user cancels the Facebook dialog.
  Future<UserCredential?> signInWithFacebook() async {
    debugPrint('[FACEBOOK_AUTH] opening Facebook dialog...');
    final result = await FacebookAuth.instance.login();
    debugPrint('[FACEBOOK_AUTH] dialog closed, status: ${result.status}');
    if (result.status != LoginStatus.success) return null;

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );
    debugPrint('[FACEBOOK_AUTH] exchanging credential with Firebase...');
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    debugPrint('[FACEBOOK_AUTH] Firebase sign-in complete: ${userCredential.user?.uid}');
    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    debugPrint('[APPLE_AUTH] requesting Apple ID credential...');
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    debugPrint('[APPLE_AUTH] got Apple credential (identityToken present: ${appleCredential.identityToken != null})');

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    debugPrint('[APPLE_AUTH] exchanging credential with Firebase...');
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    debugPrint('[APPLE_AUTH] Firebase sign-in complete: ${userCredential.user?.uid}');
    return userCredential;
  }

  /// Sends an OTP SMS to [phoneNumber] (E.164 format, e.g. "+201234567890")
  /// and resolves with the verification ID to pass into [verifyPhoneOTP].
  ///
  /// Resolves with an empty string if the device auto-verifies the number
  /// (e.g. Android SMS auto-retrieval) — in that case sign-in already
  /// completed here and callers should skip the OTP entry screen.
  Future<String> signInWithPhone(String phoneNumber) {
    debugPrint('[PHONE_AUTH] verifyPhoneNumber($phoneNumber) started');
    final completer = Completer<String>();
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('[PHONE_AUTH] verificationCompleted (auto-verified)');
        try {
          await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete('');
        } catch (e) {
          debugPrint('[PHONE_AUTH] auto-verify signInWithCredential threw: $e');
          if (!completer.isCompleted) completer.completeError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('[PHONE_AUTH] verificationFailed: ${e.code} ${e.message}');
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('[PHONE_AUTH] codeSent, verificationId len=${verificationId.length}');
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      // Fires once the auto-retrieval window closes with no auto-verification —
      // still a valid verificationId for manual OTP entry, so complete with it
      // instead of leaving the caller waiting forever.
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('[PHONE_AUTH] codeAutoRetrievalTimeout, verificationId len=${verificationId.length}');
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );
    return completer.future;
  }

  Future<UserCredential> verifyPhoneOTP(
    String verificationId,
    String smsCode,
  ) {
    debugPrint('[PHONE_AUTH] verifyPhoneOTP() checking code...');
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }

  /// Maps a FirebaseAuthException to a short, user-facing message.
  String mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number entered is invalid.';
      case 'invalid-verification-code':
        return 'The OTP code entered is incorrect.';
      case 'session-expired':
        return 'The OTP code has expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The credential provided is invalid or has expired.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
