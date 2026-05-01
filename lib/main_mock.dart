import 'dart:async';

import 'package:cafeplatform/firebase_options_dev.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'config/flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.mock;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  KakaoSdk.init(
    nativeAppKey: F.kakaoNativeAppKey,
    javaScriptAppKey: F.kakaoJavaScriptAppKey,
  );

  unawaited(() async {
    try {
      await FirebaseAppCheck.instance
          .activate(
            androidProvider: AndroidProvider.debug,
            appleProvider: AppleProvider.debug,
          )
          .timeout(const Duration(seconds: 8));
      debugPrint('✅ Firebase App Check 활성화 완료 (mock)');
    } catch (e) {
      debugPrint('⚠️ Firebase App Check 활성화 실패 (무시 가능): $e');
    }
  }());

  await runner.main();
}
