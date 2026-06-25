import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// iOS는 APNs 디바이스 토큰이 오기 전에 [FirebaseMessaging.getToken]이
/// 오래 막히는 경우가 있어, [개발노트](https://joominl.tistory.com/36) 및
/// Firebase 권장 흐름에 맞춰 APNs 준비를 기다린 뒤 FCM 토큰을 요청한다.
Future<String?> fetchFcmTokenRespectingIosApns({
  Duration apnsWaitBudget = const Duration(seconds: 5),
  Duration getTokenTimeout = const Duration(seconds: 10),
}) async {
  final messaging = FirebaseMessaging.instance;

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final deadline = DateTime.now().add(apnsWaitBudget);
    while (DateTime.now().isBefore(deadline)) {
      final apns = await messaging.getAPNSToken();
      if (apns != null && apns.isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  try {
    return await messaging.getToken().timeout(getTokenTimeout);
  } on TimeoutException {
    debugPrint('FCM getToken 타임아웃');
    return null;
  }
}
