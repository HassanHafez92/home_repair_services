/// All enums used across the Fixawy platform.
/// Shared between customer app, technician app, and backend.

/// User role in the system.
enum UserRole {
  customer,
  technician,
  admin;

  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// Job lifecycle status.
enum JobStatus {
  /// Searching for a nearby technician
  searching,

  /// Technician accepted, heading to customer
  accepted,

  /// Technician is en route
  enRoute,

  /// Technician has arrived at location
  arrived,

  /// Work is in progress
  inProgress,

  /// Invoice sent, waiting for customer approval
  invoiced,

  /// Customer approved the invoice
  approved,

  /// Job completed and payment processed
  completed,

  /// Job is under dispute
  disputed,

  /// Job was cancelled
  cancelled;

  String get value => name;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => JobStatus.searching,
    );
  }
}

/// Service categories available on the platform.
enum ServiceCategory {
  plumbing,
  electrical,
  ac,
  carpentry,
  painting,
  general;

  String get displayNameEn {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.ac:
        return 'AC / HVAC';
      case ServiceCategory.carpentry:
        return 'Carpentry';
      case ServiceCategory.painting:
        return 'Painting';
      case ServiceCategory.general:
        return 'General Maintenance';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ServiceCategory.plumbing:
        return 'سباكة';
      case ServiceCategory.electrical:
        return 'كهرباء';
      case ServiceCategory.ac:
        return 'تكييف';
      case ServiceCategory.carpentry:
        return 'نجارة';
      case ServiceCategory.painting:
        return 'دهانات';
      case ServiceCategory.general:
        return 'صيانة عامة';
    }
  }

  String get icon {
    switch (this) {
      case ServiceCategory.plumbing:
        return '🔧';
      case ServiceCategory.electrical:
        return '⚡';
      case ServiceCategory.ac:
        return '❄️';
      case ServiceCategory.carpentry:
        return '🪚';
      case ServiceCategory.painting:
        return '🎨';
      case ServiceCategory.general:
        return '🔨';
    }
  }

  String get value => name;

  static ServiceCategory fromString(String value) {
    return ServiceCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ServiceCategory.general,
    );
  }
}

/// Technician verification / KYC status.
enum VerificationStatus {
  pending,
  underReview,
  approved,
  rejected;

  String get value => name;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

/// Transaction types in the wallet system.
enum TransactionType {
  /// Technician earned money from a job
  earning,

  /// Platform commission deducted
  commissionDeduction,

  /// Cancellation penalty charged
  penalty,

  /// Refund issued
  refund,

  /// Payout to technician bank
  payout,

  /// Risk fund compensation
  riskFundPayout,

  /// Risk fund contribution (from commissions)
  riskFundContribution,

  /// Cash collection by technician (creates negative balance)
  cashCollection,

  /// Inspection fee
  inspectionFee;

  String get value => name;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.earning,
    );
  }
}

/// Payment method for checkout.
enum PaymentMethod {
  cash,
  creditCard,
  vodafoneCash,
  fawry;

  String get displayNameEn {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.vodafoneCash:
        return 'Vodafone Cash';
      case PaymentMethod.fawry:
        return 'Fawry';
    }
  }

  String get displayNameAr {
    switch (this) {
      case PaymentMethod.cash:
        return 'كاش';
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمان';
      case PaymentMethod.vodafoneCash:
        return 'فودافون كاش';
      case PaymentMethod.fawry:
        return 'فوري';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Dispute status in the resolution pipeline.
enum DisputeStatus {
  open,
  investigating,
  resolved,
  dismissed;

  String get value => name;

  static DisputeStatus fromString(String value) {
    return DisputeStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DisputeStatus.open,
    );
  }
}

/// Dispute reason presets.
enum DisputeReason {
  customerRefusedToPay,
  customerUnresponsive,
  hostileCustomer,
  damagedProperty,
  fakeMaterials,
  priceDispute,
  other;

  String get displayNameEn {
    switch (this) {
      case DisputeReason.customerRefusedToPay:
        return 'Customer Refused to Pay';
      case DisputeReason.customerUnresponsive:
        return 'Customer Unresponsive';
      case DisputeReason.hostileCustomer:
        return 'Hostile Customer';
      case DisputeReason.damagedProperty:
        return 'Damaged Property';
      case DisputeReason.fakeMaterials:
        return 'Fake Materials Reported';
      case DisputeReason.priceDispute:
        return 'Price Dispute';
      case DisputeReason.other:
        return 'Other';
    }
  }

  String get displayNameAr {
    switch (this) {
      case DisputeReason.customerRefusedToPay:
        return 'العميل رفض الدفع';
      case DisputeReason.customerUnresponsive:
        return 'العميل غير متجاوب';
      case DisputeReason.hostileCustomer:
        return 'عميل عدائي';
      case DisputeReason.damagedProperty:
        return 'تلف في الممتلكات';
      case DisputeReason.fakeMaterials:
        return 'مواد مغشوشة';
      case DisputeReason.priceDispute:
        return 'خلاف على السعر';
      case DisputeReason.other:
        return 'أخرى';
    }
  }

  static DisputeReason fromString(String value) {
    return DisputeReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DisputeReason.other,
    );
  }
}

/// Notification type for push notifications.
enum NotificationType {
  jobAssigned,
  jobAccepted,
  techEnRoute,
  techArrived,
  invoiceSent,
  invoiceApproved,
  invoiceRejected,
  jobCompleted,
  disputeOpened,
  disputeResolved,
  paymentReceived,
  paymentFailed,
  materialApprovalRequired,
  cancellationNotice,
  accountBlocked,
  general;

  String get value => name;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.general,
    );
  }
}
