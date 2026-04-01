// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LaborItemImpl _$$LaborItemImplFromJson(Map<String, dynamic> json) =>
    _$LaborItemImpl(
      itemId: json['itemId'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$$LaborItemImplToJson(_$LaborItemImpl instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'description': instance.description,
      'price': instance.price,
    };

_$JobImpl _$$JobImplFromJson(Map<String, dynamic> json) => _$JobImpl(
      jobId: json['jobId'] as String,
      customerId: json['customerId'] as String,
      technicianId: json['technicianId'] as String?,
      serviceCategory: json['serviceCategory'] as String,
      status: $enumDecodeNullable(_$JobStatusEnumMap, json['status']) ??
          JobStatus.searching,
      location: const GeoPointConverter().fromJson(json['location']),
      addressText: json['addressText'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      inspectionFee: (json['inspectionFee'] as num?)?.toDouble() ?? 150.0,
      laborItems: (json['laborItems'] as List<dynamic>?)
              ?.map((e) => LaborItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      materialsCost: (json['materialsCost'] as num?)?.toDouble() ?? 0.0,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      platformFee: (json['platformFee'] as num?)?.toDouble(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      isSurge: json['isSurge'] as bool? ?? false,
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$JobImplToJson(_$JobImpl instance) => <String, dynamic>{
      'jobId': instance.jobId,
      'customerId': instance.customerId,
      'technicianId': instance.technicianId,
      'serviceCategory': instance.serviceCategory,
      'status': _$JobStatusEnumMap[instance.status]!,
      'location': const GeoPointConverter().toJson(instance.location),
      'addressText': instance.addressText,
      'voiceNoteUrl': instance.voiceNoteUrl,
      'inspectionFee': instance.inspectionFee,
      'laborItems': instance.laborItems,
      'materialsCost': instance.materialsCost,
      'receiptImageUrl': instance.receiptImageUrl,
      'totalAmount': instance.totalAmount,
      'platformFee': instance.platformFee,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isSurge': instance.isSurge,
      'surgeMultiplier': instance.surgeMultiplier,
    };

const _$JobStatusEnumMap = {
  JobStatus.searching: 'searching',
  JobStatus.accepted: 'accepted',
  JobStatus.enRoute: 'en_route',
  JobStatus.arrived: 'arrived',
  JobStatus.inProgress: 'in_progress',
  JobStatus.invoiced: 'invoiced',
  JobStatus.approved: 'approved',
  JobStatus.completed: 'completed',
  JobStatus.disputed: 'disputed',
  JobStatus.cancelled: 'cancelled',
};
