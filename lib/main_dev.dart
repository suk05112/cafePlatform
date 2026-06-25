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
  F.appFlavor = Flavor.dev;
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  var kakaoNative = 'c1428635d1b36023f66bba9374fda4e8';
  var javaScriptAppKey = '16dd251b86287783606ea600a98c7131';

  KakaoSdk.init(
    nativeAppKey: kakaoNative,
    javaScriptAppKey: javaScriptAppKey,
  );

  // App Check는 runApp을 막지 않음 (activate 대기로 스플래시/흰 화면이 길어지는 것 방지)
  unawaited(() async {
    try {
      await FirebaseAppCheck.instance
          .activate(
            androidProvider: AndroidProvider.debug,
            appleProvider: AppleProvider.debug,
            webProvider: ReCaptchaV3Provider(
                "6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"),
          )
          .timeout(const Duration(seconds: 8));
      debugPrint('✅ Firebase App Check 활성화 완료');
    } catch (e) {
      debugPrint('⚠️ Firebase App Check 활성화 실패 (무시 가능): $e');
    }

    await Future<void>.delayed(const Duration(seconds: 3));
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null) {
        debugPrint('🔥 Firebase App Check Token 획득 성공');
      }
    } catch (e) {
      debugPrint('⚠️ Firebase App Check Token 획득 실패 (무시 가능): $e');
    }
  }());

  await runner.main();
}
