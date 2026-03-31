import 'package:dio/dio.dart';

/// Cloud Functions Service — Calls HTTPS callable functions
class CloudFunctionsService {
  final Dio _dio;
  final String _baseUrl;

  CloudFunctionsService({
    Dio? dio,
    String region = 'europe-west1',
    String projectId = 'fixawy-app-production',
  })  : _dio = dio ?? Dio(),
        _baseUrl =
            'https://$region-$projectId.cloudfunctions.net';

  // TODO: Replace with Firebase Functions SDK callable when available
  // For now using Dio HTTP calls to Cloud Functions endpoints

  /// Create a new job booking
  Future<Map<String, dynamic>> createBooking({
    required String serviceCategory,
    required double lat,
    required double lng,
    required String address,
    String? description,
    String? voiceNoteUrl,
    bool isEmergency = false,
    required String authToken,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/createJob',
      data: {
        'serviceCategory': serviceCategory,
        'location': {'lat': lat, 'lng': lng},
        'address': address,
        'description': description,
        'voiceNoteUrl': voiceNoteUrl,
        'isEmergency': isEmergency,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Cancel a job
  Future<void> cancelJob({
    required String jobId,
    required String reason,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/cancelJob',
      data: {
        'jobId': jobId,
        'reason': reason,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
  }

  /// Approve or dispute an invoice
  Future<void> respondToInvoice({
    required String jobId,
    required bool approved,
    String? disputeReason,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/respondToInvoice',
      data: {
        'jobId': jobId,
        'approved': approved,
        'disputeReason': disputeReason,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
  }

  /// Submit a job rating
  Future<void> submitRating({
    required String jobId,
    required double rating,
    String? comment,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/rateJob',
      data: {
        'jobId': jobId,
        'rating': rating,
        'comment': comment,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
  }

  /// Trigger panic button
  Future<void> triggerPanic({
    required String jobId,
    required String reason,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/triggerPanic',
      data: {
        'jobId': jobId,
        'reason': reason,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );
  }

  /// Initiate Paymob payment
  Future<Map<String, dynamic>> initiatePayment({
    required String jobId,
    required double amount,
    required String authToken,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/initiatePayment',
      data: {
        'jobId': jobId,
        'amount': amount,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }
}
