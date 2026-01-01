extension DateTimeFormatExtension on DateTime {
  /// 날짜만 반환 (예: 2025-04-01)
  String get toDateString {
    return "${year.toString().padLeft(4, '0')}-"
        "${month.toString().padLeft(2, '0')}-"
        "${day.toString().padLeft(2, '0')}";
  }

  /// 날짜 + 시간 (분 단위) 반환 (예: 2025-04-01 14:30)
  String get toDateTimeStringShort {
    return "$toDateString "
        "${hour.toString().padLeft(2, '0')}:"
        "${minute.toString().padLeft(2, '0')}";
  }

  /// 날짜 + 시간 (초 단위) 반환 (예: 2025-04-01 00:00:00)
  String get toDateTimeString {
    return "$toDateString "
        "${hour.toString().padLeft(2, '0')}:"
        "${minute.toString().padLeft(2, '0')}:"
        "${second.toString().padLeft(2, '0')}";
  }

  /// 날짜 + 시간 + 밀리초 반환 (예: 2025-04-01 00:00:00.000)
  String get toFullDateTimeString {
    return "$toDateTimeString.${millisecond.toString().padLeft(3, '0')}";
  }
}
