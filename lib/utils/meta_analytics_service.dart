import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaAnalyticsService {
  MetaAnalyticsService._();
  static final MetaAnalyticsService instance = MetaAnalyticsService._();

  final _fb = FacebookAppEvents();

  void _log(String name, [Map<String, dynamic>? params]) {
    debugPrint('[MetaAnalytics] $name ${params ?? ''}');
  }

  /// 앱 최초 실행/활성화 (앱 시작 시 1회)
  Future<void> logAppLaunch() async {
    _log('fb_mobile_activate_app');
    await _fb.logEvent(name: 'fb_mobile_activate_app');
  }

  /// 매장/메뉴 검색
  Future<void> logSearch({required String searchString}) async {
    _log('fb_mobile_search', {'fb_search_string': searchString});
    await _fb.logEvent(
      name: 'fb_mobile_search',
      parameters: {'fb_search_string': searchString},
    );
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
    await _fb.logViewContent(
      id: contentId,
      type: contentType,
    );
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
      'totalPrice': value,
    });
    await _fb.logInitiatedCheckout(
      contentId: contentId,
      contentType: contentType,
      totalPrice: value,
      currency: currency,
    );
  }

  /// 회원가입 완료 (StartTrial)
  Future<void> logStartTrial() async {
    _log('StartTrial');
    await _fb.logStartTrial(orderId: 'signup');
  }

  /// 결제 완료
  Future<void> logPurchase({
    required double amount,
    required String currency,
    String? contentId,
    String? contentType,
  }) async {
    _log('fb_mobile_purchase', {
      'amount': amount,
      'currency': currency,
      'fb_content_id': contentId,
      'fb_content_type': contentType,
    });
    await _fb.logPurchase(
      amount: amount,
      currency: currency,
      parameters: {
        if (contentId != null) FacebookAppEvents.paramNameContentId: contentId,
        if (contentType != null) FacebookAppEvents.paramNameContentType: contentType,
      },
    );
  }

  /// 결제수단 등록/선택
  Future<void> logAddPaymentInfo({bool success = true}) async {
    _log('fb_mobile_add_payment_info', {'fb_success': success ? '1' : '0'});
    await _fb.logEvent(
      name: 'fb_mobile_add_payment_info',
      parameters: {
        FacebookAppEvents.paramNamePaymentInfoAvailable:
            success ? FacebookAppEvents.paramValueYes : FacebookAppEvents.paramValueNo,
      },
    );
  }
}
