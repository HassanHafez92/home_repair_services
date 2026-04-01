// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LaborItem _$LaborItemFromJson(Map<String, dynamic> json) {
  return _LaborItem.fromJson(json);
}

/// @nodoc
mixin _$LaborItem {
  String get itemId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this LaborItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LaborItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaborItemCopyWith<LaborItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaborItemCopyWith<$Res> {
  factory $LaborItemCopyWith(LaborItem value, $Res Function(LaborItem) then) =
      _$LaborItemCopyWithImpl<$Res, LaborItem>;
  @useResult
  $Res call({String itemId, String description, double price});
}

/// @nodoc
class _$LaborItemCopyWithImpl<$Res, $Val extends LaborItem>
    implements $LaborItemCopyWith<$Res> {
  _$LaborItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaborItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? description = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LaborItemImplCopyWith<$Res>
    implements $LaborItemCopyWith<$Res> {
  factory _$$LaborItemImplCopyWith(
          _$LaborItemImpl value, $Res Function(_$LaborItemImpl) then) =
      __$$LaborItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String itemId, String description, double price});
}

/// @nodoc
class __$$LaborItemImplCopyWithImpl<$Res>
    extends _$LaborItemCopyWithImpl<$Res, _$LaborItemImpl>
    implements _$$LaborItemImplCopyWith<$Res> {
  __$$LaborItemImplCopyWithImpl(
      _$LaborItemImpl _value, $Res Function(_$LaborItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of LaborItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? description = null,
    Object? price = null,
  }) {
    return _then(_$LaborItemImpl(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LaborItemImpl implements _LaborItem {
  const _$LaborItemImpl(
      {required this.itemId, required this.description, required this.price});

  factory _$LaborItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaborItemImplFromJson(json);

  @override
  final String itemId;
  @override
  final String description;
  @override
  final double price;

  @override
  String toString() {
    return 'LaborItem(itemId: $itemId, description: $description, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaborItemImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemId, description, price);

  /// Create a copy of LaborItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaborItemImplCopyWith<_$LaborItemImpl> get copyWith =>
      __$$LaborItemImplCopyWithImpl<_$LaborItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaborItemImplToJson(
      this,
    );
  }
}

abstract class _LaborItem implements LaborItem {
  const factory _LaborItem(
      {required final String itemId,
      required final String description,
      required final double price}) = _$LaborItemImpl;

  factory _LaborItem.fromJson(Map<String, dynamic> json) =
      _$LaborItemImpl.fromJson;

  @override
  String get itemId;
  @override
  String get description;
  @override
  double get price;

  /// Create a copy of LaborItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaborItemImplCopyWith<_$LaborItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Job _$JobFromJson(Map<String, dynamic> json) {
  return _Job.fromJson(json);
}

/// @nodoc
mixin _$Job {
  String get jobId => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String? get technicianId => throw _privateConstructorUsedError;
  String get serviceCategory => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  @GeoPointConverter()
  GeoPoint? get location => throw _privateConstructorUsedError;
  String? get addressText => throw _privateConstructorUsedError;
  String? get voiceNoteUrl => throw _privateConstructorUsedError;
  double get inspectionFee => throw _privateConstructorUsedError;
  List<LaborItem> get laborItems => throw _privateConstructorUsedError;
  double get materialsCost => throw _privateConstructorUsedError;
  String? get receiptImageUrl => throw _privateConstructorUsedError;
  double? get totalAmount => throw _privateConstructorUsedError;
  double? get platformFee => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isSurge => throw _privateConstructorUsedError;
  double get surgeMultiplier => throw _privateConstructorUsedError;

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobCopyWith<Job> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) then) =
      _$JobCopyWithImpl<$Res, Job>;
  @useResult
  $Res call(
      {String jobId,
      String customerId,
      String? technicianId,
      String serviceCategory,
      JobStatus status,
      @GeoPointConverter() GeoPoint? location,
      String? addressText,
      String? voiceNoteUrl,
      double inspectionFee,
      List<LaborItem> laborItems,
      double materialsCost,
      String? receiptImageUrl,
      double? totalAmount,
      double? platformFee,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      bool isSurge,
      double surgeMultiplier});
}

/// @nodoc
class _$JobCopyWithImpl<$Res, $Val extends Job> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? customerId = null,
    Object? technicianId = freezed,
    Object? serviceCategory = null,
    Object? status = null,
    Object? location = freezed,
    Object? addressText = freezed,
    Object? voiceNoteUrl = freezed,
    Object? inspectionFee = null,
    Object? laborItems = null,
    Object? materialsCost = null,
    Object? receiptImageUrl = freezed,
    Object? totalAmount = freezed,
    Object? platformFee = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isSurge = null,
    Object? surgeMultiplier = null,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      technicianId: freezed == technicianId
          ? _value.technicianId
          : technicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceCategory: null == serviceCategory
          ? _value.serviceCategory
          : serviceCategory // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      addressText: freezed == addressText
          ? _value.addressText
          : addressText // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceNoteUrl: freezed == voiceNoteUrl
          ? _value.voiceNoteUrl
          : voiceNoteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectionFee: null == inspectionFee
          ? _value.inspectionFee
          : inspectionFee // ignore: cast_nullable_to_non_nullable
              as double,
      laborItems: null == laborItems
          ? _value.laborItems
          : laborItems // ignore: cast_nullable_to_non_nullable
              as List<LaborItem>,
      materialsCost: null == materialsCost
          ? _value.materialsCost
          : materialsCost // ignore: cast_nullable_to_non_nullable
              as double,
      receiptImageUrl: freezed == receiptImageUrl
          ? _value.receiptImageUrl
          : receiptImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      platformFee: freezed == platformFee
          ? _value.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSurge: null == isSurge
          ? _value.isSurge
          : isSurge // ignore: cast_nullable_to_non_nullable
              as bool,
      surgeMultiplier: null == surgeMultiplier
          ? _value.surgeMultiplier
          : surgeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobImplCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$$JobImplCopyWith(_$JobImpl value, $Res Function(_$JobImpl) then) =
      __$$JobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String jobId,
      String customerId,
      String? technicianId,
      String serviceCategory,
      JobStatus status,
      @GeoPointConverter() GeoPoint? location,
      String? addressText,
      String? voiceNoteUrl,
      double inspectionFee,
      List<LaborItem> laborItems,
      double materialsCost,
      String? receiptImageUrl,
      double? totalAmount,
      double? platformFee,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      bool isSurge,
      double surgeMultiplier});
}

/// @nodoc
class __$$JobImplCopyWithImpl<$Res> extends _$JobCopyWithImpl<$Res, _$JobImpl>
    implements _$$JobImplCopyWith<$Res> {
  __$$JobImplCopyWithImpl(_$JobImpl _value, $Res Function(_$JobImpl) _then)
      : super(_value, _then);

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? customerId = null,
    Object? technicianId = freezed,
    Object? serviceCategory = null,
    Object? status = null,
    Object? location = freezed,
    Object? addressText = freezed,
    Object? voiceNoteUrl = freezed,
    Object? inspectionFee = null,
    Object? laborItems = null,
    Object? materialsCost = null,
    Object? receiptImageUrl = freezed,
    Object? totalAmount = freezed,
    Object? platformFee = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isSurge = null,
    Object? surgeMultiplier = null,
  }) {
    return _then(_$JobImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      technicianId: freezed == technicianId
          ? _value.technicianId
          : technicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceCategory: null == serviceCategory
          ? _value.serviceCategory
          : serviceCategory // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as GeoPoint?,
      addressText: freezed == addressText
          ? _value.addressText
          : addressText // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceNoteUrl: freezed == voiceNoteUrl
          ? _value.voiceNoteUrl
          : voiceNoteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectionFee: null == inspectionFee
          ? _value.inspectionFee
          : inspectionFee // ignore: cast_nullable_to_non_nullable
              as double,
      laborItems: null == laborItems
          ? _value._laborItems
          : laborItems // ignore: cast_nullable_to_non_nullable
              as List<LaborItem>,
      materialsCost: null == materialsCost
          ? _value.materialsCost
          : materialsCost // ignore: cast_nullable_to_non_nullable
              as double,
      receiptImageUrl: freezed == receiptImageUrl
          ? _value.receiptImageUrl
          : receiptImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      platformFee: freezed == platformFee
          ? _value.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSurge: null == isSurge
          ? _value.isSurge
          : isSurge // ignore: cast_nullable_to_non_nullable
              as bool,
      surgeMultiplier: null == surgeMultiplier
          ? _value.surgeMultiplier
          : surgeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobImpl implements _Job {
  const _$JobImpl(
      {required this.jobId,
      required this.customerId,
      this.technicianId,
      required this.serviceCategory,
      this.status = JobStatus.searching,
      @GeoPointConverter() this.location,
      this.addressText,
      this.voiceNoteUrl,
      this.inspectionFee = 150.0,
      final List<LaborItem> laborItems = const [],
      this.materialsCost = 0.0,
      this.receiptImageUrl,
      this.totalAmount,
      this.platformFee,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt,
      this.isSurge = false,
      this.surgeMultiplier = 1.0})
      : _laborItems = laborItems;

  factory _$JobImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobImplFromJson(json);

  @override
  final String jobId;
  @override
  final String customerId;
  @override
  final String? technicianId;
  @override
  final String serviceCategory;
  @override
  @JsonKey()
  final JobStatus status;
  @override
  @GeoPointConverter()
  final GeoPoint? location;
  @override
  final String? addressText;
  @override
  final String? voiceNoteUrl;
  @override
  @JsonKey()
  final double inspectionFee;
  final List<LaborItem> _laborItems;
  @override
  @JsonKey()
  List<LaborItem> get laborItems {
    if (_laborItems is EqualUnmodifiableListView) return _laborItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_laborItems);
  }

  @override
  @JsonKey()
  final double materialsCost;
  @override
  final String? receiptImageUrl;
  @override
  final double? totalAmount;
  @override
  final double? platformFee;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isSurge;
  @override
  @JsonKey()
  final double surgeMultiplier;

  @override
  String toString() {
    return 'Job(jobId: $jobId, customerId: $customerId, technicianId: $technicianId, serviceCategory: $serviceCategory, status: $status, location: $location, addressText: $addressText, voiceNoteUrl: $voiceNoteUrl, inspectionFee: $inspectionFee, laborItems: $laborItems, materialsCost: $materialsCost, receiptImageUrl: $receiptImageUrl, totalAmount: $totalAmount, platformFee: $platformFee, createdAt: $createdAt, updatedAt: $updatedAt, isSurge: $isSurge, surgeMultiplier: $surgeMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.technicianId, technicianId) ||
                other.technicianId == technicianId) &&
            (identical(other.serviceCategory, serviceCategory) ||
                other.serviceCategory == serviceCategory) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.addressText, addressText) ||
                other.addressText == addressText) &&
            (identical(other.voiceNoteUrl, voiceNoteUrl) ||
                other.voiceNoteUrl == voiceNoteUrl) &&
            (identical(other.inspectionFee, inspectionFee) ||
                other.inspectionFee == inspectionFee) &&
            const DeepCollectionEquality()
                .equals(other._laborItems, _laborItems) &&
            (identical(other.materialsCost, materialsCost) ||
                other.materialsCost == materialsCost) &&
            (identical(other.receiptImageUrl, receiptImageUrl) ||
                other.receiptImageUrl == receiptImageUrl) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.platformFee, platformFee) ||
                other.platformFee == platformFee) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isSurge, isSurge) || other.isSurge == isSurge) &&
            (identical(other.surgeMultiplier, surgeMultiplier) ||
                other.surgeMultiplier == surgeMultiplier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      jobId,
      customerId,
      technicianId,
      serviceCategory,
      status,
      location,
      addressText,
      voiceNoteUrl,
      inspectionFee,
      const DeepCollectionEquality().hash(_laborItems),
      materialsCost,
      receiptImageUrl,
      totalAmount,
      platformFee,
      createdAt,
      updatedAt,
      isSurge,
      surgeMultiplier);

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      __$$JobImplCopyWithImpl<_$JobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobImplToJson(
      this,
    );
  }
}

abstract class _Job implements Job {
  const factory _Job(
      {required final String jobId,
      required final String customerId,
      final String? technicianId,
      required final String serviceCategory,
      final JobStatus status,
      @GeoPointConverter() final GeoPoint? location,
      final String? addressText,
      final String? voiceNoteUrl,
      final double inspectionFee,
      final List<LaborItem> laborItems,
      final double materialsCost,
      final String? receiptImageUrl,
      final double? totalAmount,
      final double? platformFee,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt,
      final bool isSurge,
      final double surgeMultiplier}) = _$JobImpl;

  factory _Job.fromJson(Map<String, dynamic> json) = _$JobImpl.fromJson;

  @override
  String get jobId;
  @override
  String get customerId;
  @override
  String? get technicianId;
  @override
  String get serviceCategory;
  @override
  JobStatus get status;
  @override
  @GeoPointConverter()
  GeoPoint? get location;
  @override
  String? get addressText;
  @override
  String? get voiceNoteUrl;
  @override
  double get inspectionFee;
  @override
  List<LaborItem> get laborItems;
  @override
  double get materialsCost;
  @override
  String? get receiptImageUrl;
  @override
  double? get totalAmount;
  @override
  double? get platformFee;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  bool get isSurge;
  @override
  double get surgeMultiplier;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
