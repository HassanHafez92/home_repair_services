import 'package:dio/dio.dart';

/// Technician Cloud Functions Service — Job operations
class TechFunctionsService {
  final Dio _dio;
  final String _baseUrl;

  TechFunctionsService({
    Dio? dio,
    String region = 'europe-west1',
    String projectId = 'fixawy-app-production',
  })  : _dio = dio ?? Dio(),
        _baseUrl = 'https://$region-$projectId.cloudfunctions.net';

  /// Accept a job
  Future<void> acceptJob({
    required String jobId,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/acceptJob',
      data: {'jobId': jobId},
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }

  /// Update job status (en_route, arrived, diagnosing, working)
  Future<void> updateJobStatus({
    required String jobId,
    required String status,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/updateJobStatus',
      data: {'jobId': jobId, 'status': status},
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }

  /// Submit invoice for a job
  Future<void> submitInvoice({
    required String jobId,
    required double inspectionFee,
    required List<Map<String, dynamic>> laborItems,
    required double materialsAmount,
    required String receiptPhotoUrl,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/submitInvoice',
      data: {
        'jobId': jobId,
        'inspectionFee': inspectionFee,
        'laborItems': laborItems,
        'materialsAmount': materialsAmount,
        'receiptPhotoUrl': receiptPhotoUrl,
      },
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }

  /// Trigger panic / distress button
  Future<void> triggerPanic({
    required String jobId,
    required String reason,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/triggerPanic',
      data: {'jobId': jobId, 'reason': reason},
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }

  /// Submit KYC verification documents
  Future<void> submitKyc({
    required String idDocUrl,
    required String certificateUrl,
    required String criminalRecordUrl,
    required List<String> categories,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/submitKyc',
      data: {
        'idDocUrl': idDocUrl,
        'certificateUrl': certificateUrl,
        'criminalRecordUrl': criminalRecordUrl,
        'categories': categories,
      },
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }

  /// Request wallet withdrawal
  Future<void> requestWithdrawal({
    required double amount,
    required String method,
    required String authToken,
  }) async {
    await _dio.post(
      '$_baseUrl/requestWithdrawal',
      data: {'amount': amount, 'method': method},
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }
}
