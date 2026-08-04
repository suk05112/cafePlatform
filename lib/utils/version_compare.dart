/// Returns true if [serverVersion] is a newer version than [currentVersion].
/// Compares major.minor.patch numerically (e.g. 1.0.10 > 1.0.9).
bool isNewerVersion(String serverVersion, String currentVersion) {
  List<int> parse(String v) =>
      v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  final serverParts = parse(serverVersion);
  final currentParts = parse(currentVersion);
  final length = serverParts.length > currentParts.length
      ? serverParts.length
      : currentParts.length;

  for (var i = 0; i < length; i++) {
    final s = i < serverParts.length ? serverParts[i] : 0;
    final c = i < currentParts.length ? currentParts[i] : 0;
    if (s != c) return s > c;
  }
  return false;
}
