/// Firestore collection and document paths.
/// Centralizes all path strings to prevent typos and enable easy refactoring.
class FirestorePaths {
  FirestorePaths._();

  // ── Collections ───────────────────────────────────────────────────────
  static const String users = 'users';
  static const String technicianProfiles = 'technician_profiles';
  static const String jobs = 'jobs';
  static const String techTelemetry = 'tech_telemetry';
  static const String wallets = 'wallets';
  static const String transactions = 'transactions';
  static const String disputes = 'disputes';
  static const String pricing = 'pricing';
  static const String notifications = 'notifications';
  static const String riskFund = 'risk_fund';
  static const String geofenceZones = 'geofence_zones';
  static const String appConfig = 'app_config';

  // ── Document Helpers ──────────────────────────────────────────────────
  static String userDoc(String uid) => '$users/$uid';
  static String techProfileDoc(String uid) => '$technicianProfiles/$uid';
  static String jobDoc(String jobId) => '$jobs/$jobId';
  static String techTelemetryDoc(String techId) => '$techTelemetry/$techId';
  static String walletDoc(String uid) => '$wallets/$uid';
  static String transactionDoc(String txId) => '$transactions/$txId';
  static String disputeDoc(String disputeId) => '$disputes/$disputeId';
  static String pricingDoc(String category) => '$pricing/$category';
  static String notificationDoc(String notifId) => '$notifications/$notifId';

  // ── Subcollections ────────────────────────────────────────────────────
  static String userNotifications(String uid) => '$users/$uid/notifications';
  static String jobHistory(String uid) => '$users/$uid/job_history';
}
