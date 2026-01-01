import 'package:cafeplatform/config/flavors.dart';

class AppConfig {
  static const String devBaseUrl = "https://www.502company.com/dev";
  static const String prodBaseUrl = "https://www.502company.com/dev";

  static const String env = String.fromEnvironment('ENV', defaultValue: 'prod');

  // 환경에 따른 baseUrl 반환
  static String get baseUrl {
    print("AppConfig:: $env $prodBaseUrl");
    return F.appFlavor == Flavor.dev ? devBaseUrl : prodBaseUrl;
  }
}
