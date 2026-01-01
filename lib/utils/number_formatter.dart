//전화번호 입력시 자동 하이픈(-) 3-4-4 형식
import 'package:flutter/services.dart';

class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 숫자만 추출
    var text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isEmpty) {
      return newValue;
    }

    // 최대 11자리까지만 허용
    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      // 3-4-4 형식: 3번째(인덱스 2)와 7번째(인덱스 6) 글자 뒤에 하이픈 추가
      if (i == 2 || i == 6) {
        if (i < text.length - 1) {
          buffer.write('-');
        }
      }
    }

    var formattedText = buffer.toString();

    // 커서 위치 계산: 새로 입력된 숫자 개수에 따라 조정
    int cursorOffset = formattedText.length;
    final oldTextWithoutHyphen = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final newTextWithoutHyphen = formattedText.replaceAll(RegExp(r'[^\d]'), '');

    if (newTextWithoutHyphen.length > oldTextWithoutHyphen.length) {
      // 숫자가 추가된 경우: 커서를 끝으로
      cursorOffset = formattedText.length;
    } else if (newTextWithoutHyphen.length < oldTextWithoutHyphen.length) {
      // 숫자가 삭제된 경우: 삭제된 위치에 맞춰 조정
      final deletedCount =
          oldTextWithoutHyphen.length - newTextWithoutHyphen.length;
      int digitCount = 0;
      for (int i = 0; i < formattedText.length; i++) {
        if (RegExp(r'\d').hasMatch(formattedText[i])) {
          digitCount++;
          if (digitCount == newTextWithoutHyphen.length) {
            cursorOffset = i + 1;
            break;
          }
        }
      }
    } else {
      // 길이가 같은 경우 (하이픈만 변경): 기존 커서 위치 유지
      cursorOffset = oldValue.selection.baseOffset;
      if (cursorOffset > formattedText.length) {
        cursorOffset = formattedText.length;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
