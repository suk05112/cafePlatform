import 'dart:convert';

import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/business_info_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사업자 정보(고객센터 번호 등) 조회 공용 헬퍼.
/// 하루 단위 캐시 → API 호출 → 캐시/기본값 fallback 순으로 조회한다.
class BusinessInfoHelper {
  static const String _cacheKey = 'business_info_cache';
  static const String _lastUpdateKey = 'business_info_last_update';

  static Future<BusinessInfoResponse> getBusinessInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final lastUpdateTimeStr = prefs.getString(_lastUpdateKey);

      // 캐시가 있고 오늘 날짜면 캐시된 데이터 반환
      if (cachedJson != null && lastUpdateTimeStr != null) {
        try {
          final lastUpdateTime = DateTime.parse(lastUpdateTimeStr);
          final now = DateTime.now();
          if (lastUpdateTime.year == now.year &&
              lastUpdateTime.month == now.month &&
              lastUpdateTime.day == now.day) {
            final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
            return BusinessInfoResponse.fromJson(jsonMap);
          }
        } catch (_) {}
      }

      // 캐시가 없거나 오래되었으면 API 호출
      await Api().setBaseClient(Api.BASE_URL);
      final response = await Api().client.getBusinessInfo();

      // 캐시에 저장
      final now = DateTime.now();
      await prefs.setString(_lastUpdateKey, now.toIso8601String());
      await prefs.setString(_cacheKey, jsonEncode(response.toJson()));

      return response;
    } catch (_) {
      // 에러 발생 시 캐시된 데이터가 있으면 사용
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString(_cacheKey);
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
          return BusinessInfoResponse.fromJson(jsonMap);
        }
      } catch (_) {}

      // 캐시도 없으면 기본값 반환
      return BusinessInfoResponse(
        business_number: '479-03-03427',
        online_sales_number: '2025-서울강서-3226',
        address: '서울특별시 강서구 공항대로 543',
        telephone: '02-1111-1111',
      );
    }
  }
}
