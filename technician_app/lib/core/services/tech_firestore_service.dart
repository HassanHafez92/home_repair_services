import 'package:cloud_firestore/cloud_firestore.dart';

/// Technician Firestore Service — Jobs, Wallet, and real-time data
class TechFirestoreService {
  final FirebaseFirestore _firestore;

  TechFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Job Alerts ──────────────────────────────────

  /// Stream incoming job alerts for available technicians
  Stream<List<Map<String, dynamic>>> streamJobAlerts({
    required String techId,
    required List<String> categories,
  }) {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'pending')
        .where('serviceCategory', whereIn: categories)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ─── Active Jobs ─────────────────────────────────

  /// Stream active jobs assigned to this technician
  Stream<List<Map<String, dynamic>>> streamActiveJobs(String techId) {
    return _firestore
        .collection('jobs')
        .where('technicianId', isEqualTo: techId)
        .where('status', whereIn: [
          'accepted',
          'en_route',
          'arrived',
          'diagnosing',
          'working',
          'invoice_submitted',
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Stream a specific job
  Stream<Map<String, dynamic>?> streamJob(String jobId) {
    return _firestore
        .collection('jobs')
        .doc(jobId)
        .snapshots()
        .map((doc) => doc.exists ? {'id': doc.id, ...doc.data()!} : null);
  }

  /// Stream completed jobs count for today
  Stream<int> streamTodayCompletedCount(String techId) {
    final todayStart = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0,
    );
    return _firestore
        .collection('jobs')
        .where('technicianId', isEqualTo: techId)
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ─── Wallet ──────────────────────────────────────

  Stream<double> streamWalletBalance(String techId) {
    return _firestore
        .collection('wallets')
        .doc(techId)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['balance'] ?? 0).toDouble() : 0.0);
  }

  Stream<List<Map<String, dynamic>>> streamTransactions(String techId) {
    return _firestore
        .collection('wallets')
        .doc(techId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Get today's earnings
  Stream<double> streamTodayEarnings(String techId) {
    final todayStart = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0,
    );
    return _firestore
        .collection('wallets')
        .doc(techId)
        .collection('transactions')
        .where('type', isEqualTo: 'earning')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .snapshots()
        .map((snap) => snap.docs.fold<double>(
              0,
               (total, doc) => total + (doc.data()['amount'] ?? 0).toDouble(),
            ));
  }
}
