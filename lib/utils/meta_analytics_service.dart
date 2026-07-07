import 'package:cafeplatform/config/flavors.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaAnalyticsService {
  MetaAnalyticsService._();
  static final MetaAnalyticsService instance = MetaAnalyticsService._();

  final _fb = FacebookAppEvents();

  bool get _isProd => F.appFlavor == Flavor.prod;

  void _log(String name, [Map<String, dynamic>? params]) {
    if (!_isProd) {
      debugPrint('[MetaAnalytics] $name ${params ?? ''}');
    }
  }

  /// 매장/메뉴 검색
  Future<void> logSearch({required String searchString}) async {
    _log('fb_mobile_search', {'fb_search_string': searchString});
    if (_isProd) {
      await _fb.logEvent(
        name: 'fb_mobile_search',
        parameters: {'fb_search_string': searchString},
      );
    }
  }

  /// 매장 상세 페이지 진입
  Future<void> logViewContent({
    required String contentId,
    required String contentType,
  }) async {
    _log('fb_mobile_content_view', {
      'fb_content_id': contentId,
      'fb_content_type': contentType,
    });
    if (_isProd) {
      await _fb.logEvent(
        name: 'fb_mobile_content_view',
        parameters: {
          'fb_content_id': contentId,
          'fb_content_type': contentType,
        },
      );
    }
  }

  /// 결제 시작 (결제하기 버튼 탭)
  Future<void> logInitiateCheckout({
    required String contentId,
    required String contentType,
    required double value,
    String currency = 'KRW',
  }) async {
    _log('fb_mobile_initiated_checkout', {
      'fb_content_id': contentId,
      'fb_content_type': contentType,
      'fb_currency': currency,
      'fb_purchase_value': value,
    });
    if (_isProd) {
      await _fb.logEvent(
        name: 'fb_mobile_initiated_checkout',
        parameters: {
          'fb_content_id': contentId,
          'fb_content_type': contentType,
          'fb_currency': currency,
          'fb_purchase_value': value,
        },
      );
    }
  }

  /// 회원가입 완료 (StartTrial)
  Future<void> logStartTrial() async {
    _log('StartTrial');
    if (_isProd) {
      await _fb.logEvent(name: 'StartTrial');
    }
  }

  /// 결제 완료
  Future<void> logPurchase({
    required double amount,
    required String currency,
    String? contentId,
    String? contentType,
  }) async {
    _log('fb_mobile_purchase', {
      'fb_content_id': contentId,
      'fb_content_type': contentType,
      'fb_currency': currency,
      '_valueToSum': amount,
    });
    if (_isProd) {
      await _fb.logPurchase(amount: amount, currency: currency);
    }
  }

  /// 결제수단 등록/선택
  Future<void> logAddPaymentInfo({bool success = true}) async {
    _log('fb_mobile_add_payment_info', {'fb_success': success ? 1 : 0});
    if (_isProd) {
      await _fb.logEvent(
        name: 'fb_mobile_add_payment_info',
        parameters: {'fb_success': success ? 1 : 0},
      );
    }
  }
}
