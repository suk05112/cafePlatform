import 'package:cafeplatform/firebase_options_prod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'config/flavors.dart';

import 'main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.prod;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.appAttest,
        webProvider:
            ReCaptchaV3Provider("6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"));
  } else {
    FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider:
            ReCaptchaV3Provider("6LdLERosAAAAAAeSlEdm2nlXQy2JAwl2ySmIfh3Q"));
  }

  await runner.main();
}
