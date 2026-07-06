import 'dart:async';

import 'package:cafeplatform/firebase_options_prod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'config/flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.prod;
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  // App Check activate는 runApp을 막지 않음 (dev와 동일하게 unawaited 처리)
  unawaited(() async {
    try {
      await FirebaseAppCheck.instance
          .activate(
            androidProvider: AndroidProvider.playIntegrity,
            appleProvider: AppleProvider.appAttest,
            webProvider: ReCaptchaV3Provider(
                "6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('✅ App Check activated');
    } catch (e) {
      debugPrint('❌ Firebase App Check activate 실패: $e');
    }
  }());

  var kakaoNative = '275e555cdb8196634a6aef161abe3f84';
  var javaScriptAppKey = '16dd251b86287783606ea600a98c7131';

  KakaoSdk.init(
    nativeAppKey: kakaoNative,
    javaScriptAppKey: javaScriptAppKey,
  );

  await runner.main();
}
