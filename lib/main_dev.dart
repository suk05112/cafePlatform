import 'package:cafeplatform/firebase_options_dev.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.dev;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug, // iOS도 dev면 debug
      webProvider:
          ReCaptchaV3Provider("6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"),
    );

    // App Check 활성화 후 토큰 가져오기 시도 (에러 처리 포함)
    try {
      // 짧은 대기 시간 (10초는 너무 김)
      await Future.delayed(Duration(seconds: 2));
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null) {
        print('🔥 Firebase App Check Token: $token');
      } else {
        print('⚠️ Firebase App Check Token이 null입니다.');
      }
    } catch (e) {
      // App Check 토큰 가져오기 실패 시에도 앱은 계속 실행
      print('⚠️ Firebase App Check Token 가져오기 실패: $e');
      print('⚠️ 개발 모드에서는 이 에러를 무시해도 됩니다.');
    }
  } catch (e) {
    // App Check 활성화 자체가 실패해도 앱은 계속 실행
    print('⚠️ Firebase App Check 활성화 실패: $e');
    print('⚠️ 개발 모드에서는 이 에러를 무시해도 됩니다.');
  }

  await runner.main();
}
