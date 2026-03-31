import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic Firestore Service — CRUD + real-time streams
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  // ─── Jobs ────────────────────────────────────────

  /// Create a new job request
  Future<DocumentReference> createJob(Map<String, dynamic> jobData) async {
    return await _firestore.collection('jobs').add({
      ...jobData,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Get a single job by ID
  Future<Map<String, dynamic>?> getJob(String jobId) async {
    final doc = await _firestore.collection('jobs').doc(jobId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  /// Stream a single job (real-time updates)
  Stream<Map<String, dynamic>?> streamJob(String jobId) {
    return _firestore.collection('jobs').doc(jobId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    });
  }

  /// Stream active jobs for a customer
  Stream<List<Map<String, dynamic>>> streamActiveJobs(String customerId) {
    return _firestore
        .collection('jobs')
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: [
          'pending',
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

  /// Stream job history for a customer
  Stream<List<Map<String, dynamic>>> streamJobHistory(String customerId) {
    return _firestore
        .collection('jobs')
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Rate a completed job
  Future<void> rateJob({
    required String jobId,
    required double rating,
    String? comment,
  }) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'rating': rating,
      'ratingComment': comment,
      'ratedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Technician Location ─────────────────────────

  /// Stream technician location for tracking
  Stream<Map<String, dynamic>?> streamTechnicianLocation(String techId) {
    return _firestore
        .collection('technicians')
        .doc(techId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return {
        'lat': data['location']?['lat'],
        'lng': data['location']?['lng'],
        'lastUpdated': data['location']?['updatedAt'],
      };
    });
  }

  // ─── Wallet ──────────────────────────────────────

  /// Stream wallet balance
  Stream<double> streamWalletBalance(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;
      return (doc.data()?['balance'] ?? 0).toDouble();
    });
  }

  /// Stream transaction history
  Stream<List<Map<String, dynamic>>> streamTransactions(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ─── Notifications ───────────────────────────────

  /// Stream notifications for user
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // ─── Pricing ─────────────────────────────────────

  /// Get pricing for a service category
  Future<Map<String, dynamic>?> getPricing(String category) async {
    final doc =
        await _firestore.collection('pricing').doc(category).get();
    return doc.exists ? doc.data() : null;
  }

  /// Stream all service categories
  Stream<List<Map<String, dynamic>>> streamServiceCategories() {
    return _firestore
        .collection('pricing')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }
}
