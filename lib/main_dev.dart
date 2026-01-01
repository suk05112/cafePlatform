import 'dart:io';

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

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug, // iOS도 dev면 debug
    webProvider:
        ReCaptchaV3Provider("6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"),
  );

  sleep(Duration(seconds: 10));

  // 🔥 여기서 처음 실행 시 Debug Token 로그가 찍혀야 정상
  final token = await FirebaseAppCheck.instance.getToken();
  print('🔥 Firebase App Check Token: $token');
  await runner.main();
}
