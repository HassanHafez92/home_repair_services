import 'package:equatable/equatable.dart';

/// Job States
abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {
  const JobInitial();
}

class JobLoading extends JobState {
  const JobLoading();
}

/// Active jobs loaded
class JobsLoaded extends JobState {
  final List<Map<String, dynamic>> activeJobs;
  final List<Map<String, dynamic>> history;

  const JobsLoaded({
    required this.activeJobs,
    this.history = const [],
  });

  @override
  List<Object?> get props => [activeJobs, history];
}

/// Booking is being created
class JobBookingInProgress extends JobState {
  const JobBookingInProgress();
}

/// Booking created, searching for technician
class JobSearchingTechnician extends JobState {
  final String jobId;

  const JobSearchingTechnician(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Tracking a specific job in real-time
class JobTracking extends JobState {
  final String jobId;
  final String status;
  final String? technicianName;
  final String? technicianPhone;
  final double? techLat;
  final double? techLng;
  final double? eta;

  const JobTracking({
    required this.jobId,
    required this.status,
    this.technicianName,
    this.technicianPhone,
    this.techLat,
    this.techLng,
    this.eta,
  });

  @override
  List<Object?> get props => [jobId, status, techLat, techLng];
}

/// Invoice submitted — waiting for customer approval
class JobInvoiceReceived extends JobState {
  final String jobId;
  final double inspectionFee;
  final List<Map<String, dynamic>> laborItems;
  final double materialsAmount;
  final double total;
  final String? receiptPhotoUrl;

  const JobInvoiceReceived({
    required this.jobId,
    required this.inspectionFee,
    required this.laborItems,
    required this.materialsAmount,
    required this.total,
    this.receiptPhotoUrl,
  });

  @override
  List<Object?> get props => [jobId, total];
}

/// Job completed — prompt for rating
class JobCompleted extends JobState {
  final String jobId;
  final double total;

  const JobCompleted({required this.jobId, required this.total});

  @override
  List<Object?> get props => [jobId, total];
}

/// Job cancelled
class JobCancelled extends JobState {
  final String jobId;

  const JobCancelled(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Rating submitted
class JobRated extends JobState {
  const JobRated();
}

/// Error
class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
