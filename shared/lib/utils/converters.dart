import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class GeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) {
    if (json == null) return null;
    if (json is GeoPoint) return json;
    // Handle map case if passing through json parsing
    if (json is Map<String, dynamic>) {
      if (json['latitude'] != null && json['longitude'] != null) {
        return GeoPoint(json['latitude'] as double, json['longitude'] as double);
      }
    }
    return null;
  }

  @override
  Object? toJson(GeoPoint? object) {
    if (object == null) return null;
    return {
      'latitude': object.latitude,
      'longitude': object.longitude,
    };
  }
}

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}
