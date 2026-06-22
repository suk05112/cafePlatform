import 'package:cafeplatform/config/flavors.dart';

class AppConfig {
  // Base URL (prefix 제외)
  static const String baseDomain = "https://www.502company.com";

  static const String env = String.fromEnvironment('ENV', defaultValue: 'prod');

  // 환경에 따른 baseUrl 반환
  // dev flavor: /dev prefix 추가
  // prod flavor: /prod prefix 추가
  static String get baseUrl {
    final prefix = F.appFlavor == Flavor.dev ? '/dev' : '/prod';
    final url = '$baseDomain$prefix';
    return url;
  }
}
