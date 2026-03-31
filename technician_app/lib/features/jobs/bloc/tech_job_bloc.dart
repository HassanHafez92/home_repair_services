import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/tech_auth_service.dart';
import '../../../core/services/tech_firestore_service.dart';
import '../../../core/services/tech_functions_service.dart';

// ─── Events ──────────────────────────────────────────

abstract class TechJobEvent extends Equatable {
  const TechJobEvent();
  @override
  List<Object?> get props => [];
}

/// Load incoming job alerts
class TechJobAlertsRequested extends TechJobEvent {
  final List<String> categories;
  const TechJobAlertsRequested(this.categories);
  @override
  List<Object?> get props => [categories];
}

/// Accept a job from alerts
class TechJobAccepted extends TechJobEvent {
  final String jobId;
  const TechJobAccepted(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

/// Update job status (en_route → arrived → diagnosing → working)
class TechJobStatusUpdated extends TechJobEvent {
  final String jobId;
  final String newStatus;
  const TechJobStatusUpdated({required this.jobId, required this.newStatus});
  @override
  List<Object?> get props => [jobId, newStatus];
}

/// Submit invoice
class TechJobInvoiceSubmitted extends TechJobEvent {
  final String jobId;
  final double inspectionFee;
  final List<Map<String, dynamic>> laborItems;
  final double materialsAmount;
  final String receiptPhotoUrl;

  const TechJobInvoiceSubmitted({
    required this.jobId,
    required this.inspectionFee,
    required this.laborItems,
    required this.materialsAmount,
    required this.receiptPhotoUrl,
  });

  @override
  List<Object?> get props => [jobId, inspectionFee];
}

/// Trigger panic/distress
class TechJobPanicTriggered extends TechJobEvent {
  final String jobId;
  final String reason;
  const TechJobPanicTriggered({required this.jobId, required this.reason});
  @override
  List<Object?> get props => [jobId, reason];
}

/// Track a specific active job
class TechJobTrackingStarted extends TechJobEvent {
  final String jobId;
  const TechJobTrackingStarted(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

/// Real-time update received
class TechJobUpdated extends TechJobEvent {
  final Map<String, dynamic> jobData;
  const TechJobUpdated(this.jobData);
  @override
  List<Object?> get props => [jobData];
}

// ─── States ──────────────────────────────────────────

abstract class TechJobState extends Equatable {
  const TechJobState();
  @override
  List<Object?> get props => [];
}

class TechJobInitial extends TechJobState {
  const TechJobInitial();
}

class TechJobLoading extends TechJobState {
  const TechJobLoading();
}

/// Incoming job alerts
class TechJobAlertsLoaded extends TechJobState {
  final List<Map<String, dynamic>> alerts;
  const TechJobAlertsLoaded(this.alerts);
  @override
  List<Object?> get props => [alerts];
}

/// Actively working on a job
class TechJobActive extends TechJobState {
  final String jobId;
  final String status;
  final Map<String, dynamic> jobData;
  const TechJobActive({required this.jobId, required this.status, required this.jobData});
  @override
  List<Object?> get props => [jobId, status];
}

/// Invoice submitted, waiting for customer
class TechJobInvoicePending extends TechJobState {
  final String jobId;
  const TechJobInvoicePending(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

/// Job completed
class TechJobCompleted extends TechJobState {
  final String jobId;
  final double earning;
  const TechJobCompleted({required this.jobId, required this.earning});
  @override
  List<Object?> get props => [jobId, earning];
}

class TechJobError extends TechJobState {
  final String message;
  const TechJobError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────

/// Technician Job BLoC — Manages incoming alerts, job execution, and invoicing
class TechJobBloc extends Bloc<TechJobEvent, TechJobState> {
  final TechAuthService _authService;
  final TechFirestoreService _firestoreService;
  final TechFunctionsService _functionsService;
  StreamSubscription? _alertsSub;
  StreamSubscription? _jobSub;

  TechJobBloc({
    required TechAuthService authService,
    required TechFirestoreService firestoreService,
    required TechFunctionsService functionsService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _functionsService = functionsService,
        super(const TechJobInitial()) {
    on<TechJobAlertsRequested>(_onAlertsRequested);
    on<TechJobAccepted>(_onJobAccepted);
    on<TechJobStatusUpdated>(_onStatusUpdated);
    on<TechJobInvoiceSubmitted>(_onInvoiceSubmitted);
    on<TechJobPanicTriggered>(_onPanicTriggered);
    on<TechJobTrackingStarted>(_onTrackingStarted);
    on<TechJobUpdated>(_onJobUpdated);
  }

  Future<void> _onAlertsRequested(
    TechJobAlertsRequested event,
    Emitter<TechJobState> emit,
  ) async {
    emit(const TechJobLoading());

    final uid = _authService.uid;
    if (uid == null) return;

    await _alertsSub?.cancel();
    _alertsSub = _firestoreService
        .streamJobAlerts(techId: uid, categories: event.categories)
        .listen((alerts) {
      if (!isClosed) emit(TechJobAlertsLoaded(alerts));
    });
  }

  Future<void> _onJobAccepted(
    TechJobAccepted event,
    Emitter<TechJobState> emit,
  ) async {
    emit(const TechJobLoading());

    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.acceptJob(
        jobId: event.jobId,
        authToken: token,
      );

      // Start tracking the accepted job
      _trackJob(event.jobId);
    } catch (e) {
      emit(TechJobError('فشل قبول الطلب: ${e.toString()}'));
    }
  }

  Future<void> _onStatusUpdated(
    TechJobStatusUpdated event,
    Emitter<TechJobState> emit,
  ) async {
    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.updateJobStatus(
        jobId: event.jobId,
        status: event.newStatus,
        authToken: token,
      );
      // Firestore stream will emit the updated state
    } catch (e) {
      emit(TechJobError('فشل تحديث الحالة: ${e.toString()}'));
    }
  }

  Future<void> _onInvoiceSubmitted(
    TechJobInvoiceSubmitted event,
    Emitter<TechJobState> emit,
  ) async {
    emit(const TechJobLoading());

    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.submitInvoice(
        jobId: event.jobId,
        inspectionFee: event.inspectionFee,
        laborItems: event.laborItems,
        materialsAmount: event.materialsAmount,
        receiptPhotoUrl: event.receiptPhotoUrl,
        authToken: token,
      );

      emit(TechJobInvoicePending(event.jobId));
    } catch (e) {
      emit(TechJobError('فشل إرسال الفاتورة: ${e.toString()}'));
    }
  }

  Future<void> _onPanicTriggered(
    TechJobPanicTriggered event,
    Emitter<TechJobState> emit,
  ) async {
    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.triggerPanic(
        jobId: event.jobId,
        reason: event.reason,
        authToken: token,
      );
    } catch (e) {
      emit(TechJobError('فشل إرسال إشارة الاستغاثة: ${e.toString()}'));
    }
  }

  Future<void> _onTrackingStarted(
    TechJobTrackingStarted event,
    Emitter<TechJobState> emit,
  ) async {
    _trackJob(event.jobId);
  }

  void _trackJob(String jobId) {
    _jobSub?.cancel();
    _jobSub = _firestoreService.streamJob(jobId).listen((data) {
      if (data != null && !isClosed) {
        add(TechJobUpdated(data));
      }
    });
  }

  Future<void> _onJobUpdated(
    TechJobUpdated event,
    Emitter<TechJobState> emit,
  ) async {
    final job = event.jobData;
    final status = job['status'] as String? ?? 'pending';
    final jobId = job['id'] as String;

    switch (status) {
      case 'completed':
        final earning = (job['technicianEarning'] ?? 0).toDouble();
        emit(TechJobCompleted(jobId: jobId, earning: earning));
        break;
      case 'invoice_submitted':
        emit(TechJobInvoicePending(jobId));
        break;
      default:
        emit(TechJobActive(jobId: jobId, status: status, jobData: job));
    }
  }

  @override
  Future<void> close() {
    _alertsSub?.cancel();
    _jobSub?.cancel();
    return super.close();
  }
}
