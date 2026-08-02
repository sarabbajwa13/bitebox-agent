import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Login flow ka step.
enum AuthStep { enterPhone, otpSent }

/// Firebase **Phone Number** authentication (real OTP).
/// Flow: phone daalo → OTP SMS → OTP verify → login.
class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;

  AuthStep step = AuthStep.enterPhone;
  String phone = ''; // E.164, e.g. +919876543210
  bool busy = false;
  String? error;

  String? _verificationId;
  int? _resendToken;

  AuthProvider() {
    // Firebase init na ho (e.g. tests) to gracefully ignore.
    try {
      _auth = FirebaseAuth.instance;
      _auth!.authStateChanges().listen((_) => notifyListeners());
    } catch (_) {
      _auth = null;
    }
  }

  bool get isLoggedIn => _auth?.currentUser != null;
  String? get userPhone => _auth?.currentUser?.phoneNumber;

  /// Step 1 — OTP bhejo.
  Future<void> sendOtp(String phoneE164) async {
    if (_auth == null) return;
    busy = true;
    error = null;
    phone = phoneE164;
    notifyListeners();

    await _auth!.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      // Android auto-retrieval: OTP khud detect hoke sign-in ho jata hai.
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth!.signInWithCredential(credential);
        } catch (_) {}
        busy = false;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        busy = false;
        error = _friendly(e);
        notifyListeners();
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        step = AuthStep.otpSent;
        busy = false;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Step 2 — OTP verify karke login.
  Future<void> verifyOtp(String smsCode) async {
    if (_auth == null || _verificationId == null) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _auth!.signInWithCredential(credential);
      // authStateChanges se isLoggedIn true ho jayega.
    } on FirebaseAuthException catch (e) {
      error = _friendly(e);
    } catch (e) {
      error = e.toString();
    }
    busy = false;
    notifyListeners();
  }

  /// Wapas phone step pe (change number / resend).
  void backToPhone() {
    step = AuthStep.enterPhone;
    error = null;
    _verificationId = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth?.signOut();
    step = AuthStep.enterPhone;
    _verificationId = null;
    error = null;
    notifyListeners();
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Galat OTP — dobara try karo';
      case 'invalid-phone-number':
        return 'Phone number sahi nahi hai';
      case 'too-many-requests':
        return 'Bahut zyada attempts — thodi der baad try karo';
      case 'session-expired':
        return 'OTP expire ho gaya — dobara bhejo';
      default:
        return e.message ?? 'Verification failed';
    }
  }
}
