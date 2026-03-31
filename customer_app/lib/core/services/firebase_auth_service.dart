import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Authentication Service — handles phone, Google, and session management
class FirebaseAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Current UID
  String? get uid => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ─── Phone Auth ──────────────────────────────────
  String? _verificationId;

  /// Send OTP to phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        if (onAutoVerify != null) {
          onAutoVerify(credential);
        }
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'فشل التحقق من رقم الهاتف');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Verify OTP code
  Future<UserCredential> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('لم يتم إرسال كود التحقق بعد');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  // ─── Google Sign-In ──────────────────────────────
  Future<UserCredential> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    googleProvider.setCustomParameters({'prompt': 'select_account'});

    return await _auth.signInWithProvider(googleProvider);
  }

  // ─── User Profile ────────────────────────────────

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Check if user completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final profile = await getUserProfile();
    return profile?['onboardingCompleted'] == true;
  }

  // ─── Session ─────────────────────────────────────

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    if (uid == null) return;

    // Delete Firestore profile
    await _firestore.collection('users').doc(uid).delete();

    // Delete auth account
    await _auth.currentUser?.delete();
  }

  /// Get custom claims (role, etc.)
  Future<Map<String, dynamic>?> getCustomClaims() async {
    final idTokenResult = await _auth.currentUser?.getIdTokenResult(true);
    return idTokenResult?.claims;
  }
}
