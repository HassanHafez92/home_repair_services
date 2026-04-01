import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/converters.dart';

part 'job.freezed.dart';
part 'job.g.dart';

enum JobStatus {
  @JsonValue('searching') searching,
  @JsonValue('accepted') accepted,
  @JsonValue('en_route') enRoute,
  @JsonValue('arrived') arrived,
  @JsonValue('in_progress') inProgress,
  @JsonValue('invoiced') invoiced,
  @JsonValue('approved') approved,
  @JsonValue('completed') completed,
  @JsonValue('disputed') disputed,
  @JsonValue('cancelled') cancelled,
}

@freezed
class LaborItem with _$LaborItem {
  const factory LaborItem({
    required String itemId,
    required String description,
    required double price,
  }) = _LaborItem;

  factory LaborItem.fromJson(Map<String, dynamic> json) =>
      _$LaborItemFromJson(json);
}

@freezed
class Job with _$Job {
  const factory Job({
    required String jobId,
    required String customerId,
    String? technicianId,
    required String serviceCategory,
    @Default(JobStatus.searching) JobStatus status,
    @GeoPointConverter() GeoPoint? location,
    String? addressText,
    String? voiceNoteUrl,
    @Default(150.0) double inspectionFee,
    @Default([]) List<LaborItem> laborItems,
    @Default(0.0) double materialsCost,
    String? receiptImageUrl,
    double? totalAmount,
    double? platformFee,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(false) bool isSurge,
    @Default(1.0) double surgeMultiplier,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
