import 'package:equatable/equatable.dart';

/// Job Events
abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

/// Load active jobs for current user
class JobsLoadRequested extends JobEvent {
  const JobsLoadRequested();
}

/// Create a new booking
class JobBookingRequested extends JobEvent {
  final String serviceCategory;
  final double lat;
  final double lng;
  final String address;
  final String? description;
  final String? voiceNoteUrl;
  final bool isEmergency;

  const JobBookingRequested({
    required this.serviceCategory,
    required this.lat,
    required this.lng,
    required this.address,
    this.description,
    this.voiceNoteUrl,
    this.isEmergency = false,
  });

  @override
  List<Object?> get props => [serviceCategory, lat, lng, address, isEmergency];
}

/// Start tracking a specific job
class JobTrackingStarted extends JobEvent {
  final String jobId;

  const JobTrackingStarted(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Cancel a job
class JobCancelRequested extends JobEvent {
  final String jobId;
  final String reason;

  const JobCancelRequested({required this.jobId, required this.reason});

  @override
  List<Object?> get props => [jobId, reason];
}

/// Approve or dispute invoice
class JobInvoiceResponse extends JobEvent {
  final String jobId;
  final bool approved;
  final String? disputeReason;

  const JobInvoiceResponse({
    required this.jobId,
    required this.approved,
    this.disputeReason,
  });

  @override
  List<Object?> get props => [jobId, approved];
}

/// Submit rating for completed job
class JobRatingSubmitted extends JobEvent {
  final String jobId;
  final double rating;
  final String? comment;

  const JobRatingSubmitted({
    required this.jobId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [jobId, rating];
}

/// Real-time job update received
class JobUpdated extends JobEvent {
  final Map<String, dynamic> jobData;

  const JobUpdated(this.jobData);

  @override
  List<Object?> get props => [jobData];
}
