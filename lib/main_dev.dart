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

  // 개발 모드에서 App Check 설정 (선택적)
  try {
    // Debug 모드에서는 App Check를 선택적으로 활성화
    // Firebase Console에서 Debug 토큰이 등록되지 않은 경우 실패할 수 있음
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider:
          ReCaptchaV3Provider("6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"),
    );
    print('✅ Firebase App Check 활성화 완료');

    // 토큰 가져오기는 백그라운드에서 시도 (실패해도 계속 진행)
    // 실제로 토큰이 필요할 때만 가져오도록 API 호출 시점에 처리
    Future.delayed(Duration(seconds: 3), () async {
      try {
        final token = await FirebaseAppCheck.instance.getToken();
        if (token != null) {
          print('🔥 Firebase App Check Token 획득 성공');
        }
      } catch (e) {
        // 개발 모드에서는 토큰 획득 실패를 무시
        // Firebase Console에 Debug 토큰이 등록되어 있지 않으면 실패할 수 있음
        print('⚠️ Firebase App Check Token 획득 실패 (무시 가능): $e');
      }
    });
  } catch (e) {
    // App Check 활성화 실패 시에도 앱은 계속 실행
    // 개발 모드에서는 이 에러를 무시해도 됩니다
    print('⚠️ Firebase App Check 활성화 실패 (무시 가능): $e');
    print('💡 개발 모드에서는 App Check 없이도 정상 동작합니다.');
  }

  await runner.main();
}
