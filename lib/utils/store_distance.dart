import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

/// 권한이 없을 때 거리 계산 기준 (위도·동경)
const double kDefaultReferenceLatitude = 37.5546;
const double kDefaultReferenceLongitude = 126.9706;

/// 한반도 대략 범위 — API 기본값 등 비정상 좌표 제외
bool isPlausibleStoreCoordinate(double lat, double lng) {
  return lat >= 33.0 &&
      lat <= 38.8 &&
      lng >= 124.0 &&
      lng <= 132.5;
}

double haversineMeters(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  const earthRadiusM = 6371000.0;
  final r1 = lat1 * math.pi / 180;
  final r2 = lat2 * math.pi / 180;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = (lng2 - lng1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(r1) * math.cos(r2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  final ac = a.clamp(0.0, 1.0);
  final c = 2 * math.atan2(math.sqrt(ac), math.sqrt(1 - ac));
  return earthRadiusM * c;
}

/// 850m / 1.2km 형식
String formatDistanceLabel(double meters) {
  if (meters < 1000) {
    return '${meters.round()}m';
  }
  return '${(meters / 1000).toStringAsFixed(1)}km';
}

/// 매장 좌표가 없거나 비정상이면 null
String? storeDistanceLabel(
  double refLat,
  double refLng,
  double? storeLat,
  double? storeLng,
) {
  if (storeLat == null || storeLng == null) return null;
  if (!isPlausibleStoreCoordinate(storeLat, storeLng)) return null;
  return formatDistanceLabel(
    haversineMeters(refLat, refLng, storeLat, storeLng),
  );
}

/// 위치 서비스·권한이 있으면 현재 GPS, 없으면 [kDefaultReferenceLatitude], [kDefaultReferenceLongitude]
Future<(double lat, double lng)> resolveDistanceReferencePoint() async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return (kDefaultReferenceLatitude, kDefaultReferenceLongitude);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return (kDefaultReferenceLatitude, kDefaultReferenceLongitude);
    }
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    return (pos.latitude, pos.longitude);
  } catch (_) {
    return (kDefaultReferenceLatitude, kDefaultReferenceLongitude);
  }
}
