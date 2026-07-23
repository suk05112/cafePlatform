import 'package:flutter/services.dart';

// 은행 코드 → 하이픈 구간 정의 (자릿수 → 구간 리스트)
// 구간 합산 == 최대 자릿수가 되어야 함
// 규칙이 불명확한 은행(하나, 우리, IBK, KDB, 농협 등)은 null → 하이픈 없이 숫자만
const Map<String, Map<int, List<int>>> _bankHyphenRules = {
  '004': { // KB국민: 12자리 AAA-BB-CCCC-DDD, 14자리 AAAAAA-BB-CCCCCC
    12: [3, 2, 4, 3],
    14: [6, 2, 6],
  },
  '088': { // 신한: 11자리 AAA-BB-CCCCCC, 12자리 AAA-BBB-CCCCCC
    11: [3, 2, 6],
    12: [3, 3, 6],
  },
  '020': { // 우리: 13자리 AAAA-BBB-CCCCCC
    13: [4, 3, 6],
  },
  '081': { // 하나: 14자리 AAA-BBBBBB-CCCCC
    14: [3, 6, 5],
  },
  '011': { // NH농협: 13자리 AAA-BBBB-CCCC-DD
    13: [3, 4, 4, 2],
  },
  '003': { // IBK기업: 14자리 AAA-BBBBBB-CC-DDD
    14: [3, 6, 2, 3],
  },
  '090': { // 카카오뱅크: 13자리 3333-BB-CCCCCCC
    13: [4, 2, 7],
  },
  '092': { // 토스뱅크: 12자리 YYYY-ZZZZ-ZZZC
    12: [4, 4, 4],
  },
  '089': { // 케이뱅크: 11자리 100-XXX-XXXXXX
    11: [3, 3, 6] ,
  },
  '071': { // 우체국: 14자리 XXXXXX-XX-XXXXXX
    14: [6, 2, 6],
  },
  '023': { // SC제일: 11자리 XXX-XX-XXXXXX
    11: [3, 2, 6],
  },
  '034': { // 광주: 12자리 XXX-XXX-XXXXXX
    12: [3, 3, 6],
  },
  '039': { // 경남: 12자리 XXX-XX-XXXXXXX
    12: [3, 2, 7],
  },
  '035': { // 제주: 10자리 XX-XX-XXXXXX
    10: [2, 2, 6],
  },
};

/// 은행 코드와 현재 입력 자릿수를 받아 하이픈 구간을 반환.
/// 해당 은행 규칙이 없거나 자릿수가 맞지 않으면 null 반환 → 하이픈 없음.
List<int>? getHyphenSegments(String bankCode, int digitCount) {
  final rules = _bankHyphenRules[bankCode];
  if (rules == null) return null;

  // 정확히 일치하는 자릿수 규칙 우선
  if (rules.containsKey(digitCount)) return rules[digitCount];

  // 입력 중인 경우: 가장 가까운 규칙 적용 (누적 구간 내에서 하이픈 삽입)
  // 가장 큰 자릿수 규칙을 기본으로 사용
  final maxDigits = rules.keys.reduce((a, b) => a > b ? a : b);
  return rules[maxDigits];
}

/// 숫자 문자열에 하이픈 구간을 적용해 포맷된 문자열 반환.
String applyHyphens(String digits, List<int> segments) {
  final buf = StringBuffer();
  int pos = 0;
  for (int i = 0; i < segments.length; i++) {
    final end = pos + segments[i];
    if (pos >= digits.length) break;
    if (i > 0) buf.write('-');
    buf.write(digits.substring(pos, end.clamp(0, digits.length)));
    pos = end;
    if (pos >= digits.length) break;
  }
  return buf.toString();
}

class AccountNumberFormatter extends TextInputFormatter {
  final String bankCode;

  AccountNumberFormatter({required this.bankCode});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final segments = getHyphenSegments(bankCode, digits.length);
    final formatted = segments != null ? applyHyphens(digits, segments) : digits;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
