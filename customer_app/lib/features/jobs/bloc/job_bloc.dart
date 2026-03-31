import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/cloud_functions_service.dart';
import 'job_event.dart';
import 'job_state.dart';

/// Job BLoC — Manages the complete job lifecycle from booking to rating
class JobBloc extends Bloc<JobEvent, JobState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final CloudFunctionsService _functionsService;

  StreamSubscription? _activeJobsSub;
  StreamSubscription? _trackingJobSub;
  StreamSubscription? _techLocationSub;

  JobBloc({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required CloudFunctionsService functionsService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _functionsService = functionsService,
        super(const JobInitial()) {
    on<JobsLoadRequested>(_onLoadJobs);
    on<JobBookingRequested>(_onBooking);
    on<JobTrackingStarted>(_onTrackingStarted);
    on<JobCancelRequested>(_onCancel);
    on<JobInvoiceResponse>(_onInvoiceResponse);
    on<JobRatingSubmitted>(_onRatingSubmitted);
    on<JobUpdated>(_onJobUpdated);
  }

  /// Load active jobs from Firestore
  Future<void> _onLoadJobs(
    JobsLoadRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobLoading());

    final uid = _authService.uid;
    if (uid == null) {
      emit(const JobError('يجب تسجيل الدخول أولاً'));
      return;
    }

    try {
      // Listen to active jobs stream
      await _activeJobsSub?.cancel();
      _activeJobsSub = _firestoreService
          .streamActiveJobs(uid)
          .listen((jobs) {
        if (!isClosed) {
          emit(JobsLoaded(activeJobs: jobs));
        }
      });
    } catch (e) {
      emit(JobError('فشل تحميل الطلبات: ${e.toString()}'));
    }
  }

  /// Create a new booking via Cloud Function
  Future<void> _onBooking(
    JobBookingRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobBookingInProgress());

    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) {
        emit(const JobError('يجب تسجيل الدخول أولاً'));
        return;
      }

      final result = await _functionsService.createBooking(
        serviceCategory: event.serviceCategory,
        lat: event.lat,
        lng: event.lng,
        address: event.address,
        description: event.description,
        voiceNoteUrl: event.voiceNoteUrl,
        isEmergency: event.isEmergency,
        authToken: token,
      );

      final jobId = result['jobId'] as String;
      emit(JobSearchingTechnician(jobId));

      // Start listening to the job for status updates
      _trackJob(jobId);
    } catch (e) {
      emit(JobError('فشل إنشاء الطلب: ${e.toString()}'));
    }
  }

  /// Start real-time tracking
  Future<void> _onTrackingStarted(
    JobTrackingStarted event,
    Emitter<JobState> emit,
  ) async {
    _trackJob(event.jobId);
  }

  void _trackJob(String jobId) {
    _trackingJobSub?.cancel();
    _trackingJobSub = _firestoreService.streamJob(jobId).listen((jobData) {
      if (jobData != null && !isClosed) {
        add(JobUpdated(jobData));
      }
    });
  }

  /// Handle real-time job updates
  Future<void> _onJobUpdated(
    JobUpdated event,
    Emitter<JobState> emit,
  ) async {
    final job = event.jobData;
    final status = job['status'] as String? ?? 'pending';
    final jobId = job['id'] as String;

    switch (status) {
      case 'pending':
        emit(JobSearchingTechnician(jobId));
        break;

      case 'accepted':
      case 'en_route':
      case 'arrived':
      case 'diagnosing':
      case 'working':
        // Start listening to technician location
        final techId = job['technicianId'] as String?;
        if (techId != null) {
          _techLocationSub?.cancel();
          _techLocationSub = _firestoreService
              .streamTechnicianLocation(techId)
              .listen((loc) {
            if (!isClosed) {
              emit(JobTracking(
                jobId: jobId,
                status: status,
                technicianName: job['technicianName'],
                technicianPhone: job['technicianPhone'],
                techLat: loc?['lat']?.toDouble(),
                techLng: loc?['lng']?.toDouble(),
              ));
            }
          });
        } else {
          emit(JobTracking(
            jobId: jobId,
            status: status,
            technicianName: job['technicianName'],
            technicianPhone: job['technicianPhone'],
          ));
        }
        break;

      case 'invoice_submitted':
        final items = (job['laborItems'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        emit(JobInvoiceReceived(
          jobId: jobId,
          inspectionFee: (job['inspectionFee'] ?? 75).toDouble(),
          laborItems: items,
          materialsAmount: (job['materialsAmount'] ?? 0).toDouble(),
          total: (job['total'] ?? 0).toDouble(),
          receiptPhotoUrl: job['receiptPhotoUrl'],
        ));
        break;

      case 'completed':
        emit(JobCompleted(
          jobId: jobId,
          total: (job['total'] ?? 0).toDouble(),
        ));
        break;

      case 'cancelled':
        emit(JobCancelled(jobId));
        break;
    }
  }

  /// Cancel a job
  Future<void> _onCancel(
    JobCancelRequested event,
    Emitter<JobState> emit,
  ) async {
    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.cancelJob(
        jobId: event.jobId,
        reason: event.reason,
        authToken: token,
      );

      emit(JobCancelled(event.jobId));
    } catch (e) {
      emit(JobError('فشل إلغاء الطلب: ${e.toString()}'));
    }
  }

  /// Approve or dispute invoice
  Future<void> _onInvoiceResponse(
    JobInvoiceResponse event,
    Emitter<JobState> emit,
  ) async {
    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.respondToInvoice(
        jobId: event.jobId,
        approved: event.approved,
        disputeReason: event.disputeReason,
        authToken: token,
      );

      // Job stream will automatically emit updated state
    } catch (e) {
      emit(JobError('فشل الرد على الفاتورة: ${e.toString()}'));
    }
  }

  /// Submit rating
  Future<void> _onRatingSubmitted(
    JobRatingSubmitted event,
    Emitter<JobState> emit,
  ) async {
    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.submitRating(
        jobId: event.jobId,
        rating: event.rating,
        comment: event.comment,
        authToken: token,
      );

      emit(const JobRated());
    } catch (e) {
      emit(JobError('فشل إرسال التقييم: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _activeJobsSub?.cancel();
    _trackingJobSub?.cancel();
    _techLocationSub?.cancel();
    return super.close();
  }
}
