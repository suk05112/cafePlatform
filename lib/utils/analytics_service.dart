import 'package:cafeplatform/config/flavors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  bool get _isProd => F.appFlavor == Flavor.prod;

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (_isProd) {
      await _analytics.logEvent(name: name, parameters: params);
    } else {
      debugPrint('[Analytics] $name ${params ?? ''}');
    }
  }

  // ── 화면 트래킹 ──────────────────────────────────────────

  Future<void> logScreenView(String screenName) async {
    if (_isProd) {
      await _analytics.logScreenView(screenName: screenName);
    } else {
      debugPrint('[Analytics] screen_view: $screenName');
    }
  }

  // ── 인증 이벤트 ──────────────────────────────────────────

  /// method: kakao / google / apple / email / phone
  Future<void> logLogin(String method) async {
    await _log('login', {'method': method});
  }

  Future<void> logSignUp() async {
    await _log('sign_up');
  }

  // ── 결제 이벤트 ──────────────────────────────────────────

  Future<void> logPurchase() async {
    await _log('purchase');
  }

  // ── 탐색 이벤트 ──────────────────────────────────────────

  Future<void> logSearch(String searchTerm) async {
    await _log('search', {'search_term': searchTerm});
  }
}
