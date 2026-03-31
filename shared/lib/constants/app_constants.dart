/// Application-wide constants for the Fixawy platform.
class AppConstants {
  AppConstants._();

  // ── App Identity ──────────────────────────────────────────────────────
  static const String appName = 'Fixawy';
  static const String appNameAr = 'فيكساوي';
  static const String customerAppName = 'Fixawy';
  static const String techAppName = 'Fixawy Tech';

  // ── Firebase Project ──────────────────────────────────────────────────
  static const String firebaseProjectId = 'fixawy-app-production';
  static const String storageBucket = 'fixawy-app-production.firebasestorage.app';

  // ── Business Logic Constants ──────────────────────────────────────────
  /// Mandatory inspection fee in EGP
  static const double inspectionFee = 75.0;

  /// Platform commission percentage (15-20%)
  static const double platformCommissionRate = 0.15;

  /// Material cost threshold requiring customer approval (EGP)
  static const double materialApprovalThreshold = 500.0;

  /// Grace period for free cancellation (minutes)
  static const int cancellationGracePeriodMinutes = 5;

  /// Late cancellation penalty (EGP)
  static const double lateCancellationPenalty = 30.0;

  /// Technician wait timeout before marking unresponsive (minutes)
  static const int customerUnresponsiveTimeoutMinutes = 10;

  /// Job ping timeout for technician acceptance (seconds)
  static const int jobPingTimeoutSeconds = 30;

  /// Maximum payment retry attempts before cash fallback
  static const int maxPaymentRetries = 3;

  /// Default surge multiplier (no surge)
  static const double defaultSurgeMultiplier = 1.0;

  /// Default technician search radius in kilometers
  static const double defaultSearchRadiusKm = 10.0;

  // ── Wallet Constants ──────────────────────────────────────────────────
  /// Default credit limit for technicians (EGP)
  static const double defaultTechCreditLimit = 2000.0;

  /// Currency code
  static const String currency = 'EGP';

  // ── Storage Paths ─────────────────────────────────────────────────────
  static const String voiceNotesPath = 'voice_notes';
  static const String receiptImagesPath = 'receipt_images';
  static const String kycDocumentsPath = 'kyc_documents';
  static const String profilePhotosPath = 'profile_photos';

  // ── OTP Settings ──────────────────────────────────────────────────────
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;

  // ── Geolocation ───────────────────────────────────────────────────────
  /// How often to update tech location (milliseconds)
  static const int locationUpdateIntervalMs = 5000;

  /// Minimum distance change to trigger update (meters)
  static const double locationMinDisplacementMeters = 10.0;

  /// Geofence arrival radius (meters)
  static const double arrivalRadiusMeters = 100.0;
}
