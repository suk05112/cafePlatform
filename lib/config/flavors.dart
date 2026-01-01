enum Flavor {
  dev,
  prod,
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
      default:
        return 'title';
    }
  }

}
