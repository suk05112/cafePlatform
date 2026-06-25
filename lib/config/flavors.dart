enum Flavor {
  dev,
  prod,
  mock,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return '502 Dev';
      case Flavor.prod:
        return '502';
      case Flavor.mock:
        return '502 Mock';
      default:
        return 'title';
    }
  }

  static String get kakaoNativeAppKey {
    switch (appFlavor) {
      case Flavor.dev:
      case Flavor.mock:
        return 'c1428635d1b36023f66bba9374fda4e8';
      case Flavor.prod:
        return '275e555cdb8196634a6aef161abe3f84';
      default:
        return '';
    }
  }

  static const String kakaoJavaScriptAppKey = '16dd251b86287783606ea600a98c7131';
}
