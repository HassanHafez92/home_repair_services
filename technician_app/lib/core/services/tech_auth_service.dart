import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Technician Auth Service — Phone auth + KYC status tracking
class TechAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  TechAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  String? _verificationId;

  // ─── Phone Auth ──────────────────────────────────

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        if (onAutoVerify != null) onAutoVerify(credential);
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        onError(e.message ?? 'فشل التحقق');
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<UserCredential> verifyOtp(String smsCode) async {
    if (_verificationId == null) throw Exception('لم يتم إرسال كود التحقق');
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ─── Technician Profile ──────────────────────────

  Future<Map<String, dynamic>?> getTechnicianProfile() async {
    if (uid == null) return null;
    final doc = await _firestore.collection('technicians').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateTechnicianProfile(Map<String, dynamic> data) async {
    if (uid == null) return;
    await _firestore.collection('technicians').doc(uid).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Get KYC verification status
  Future<String> getKycStatus() async {
    final profile = await getTechnicianProfile();
    return profile?['kycStatus'] ?? 'not_started';
  }

  // ─── Online/Offline Toggle ───────────────────────

  Future<void> setOnlineStatus(bool isOnline) async {
    if (uid == null) return;
    await _firestore.collection('technicians').doc(uid).update({
      'isOnline': isOnline,
      'lastStatusChange': FieldValue.serverTimestamp(),
    });
  }

  /// Update real-time location
  Future<void> updateLocation(double lat, double lng) async {
    if (uid == null) return;
    await _firestore.collection('technicians').doc(uid).update({
      'location': {
        'lat': lat,
        'lng': lng,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  Future<void> signOut() async {
    if (uid != null) {
      await setOnlineStatus(false);
    }
    await _auth.signOut();
  }
}
