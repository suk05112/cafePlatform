import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class CommonDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed, // onPressed 매개변수 추가
    bool cancel = false,
    bool barrierDismissible = false,
    bool preventPop = false, // true면 뒤로가기/확인 클릭으로 다이얼로그가 닫히지 않음
    bool filledButton = false, // true면 확인 버튼을 mainColor 필박스 스타일로 표시
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        final dialog = AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Column(
            children: <Widget>[
              Text(title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(content),
            ],
          ),
          actionsPadding: filledButton
              ? const EdgeInsets.fromLTRB(24, 0, 24, 20)
              : null,
          actions: <Widget>[
            if (cancel)
              WithCancelBtn(context, onPressed)
            else if (filledButton)
              FilledOKBtn(context, onPressed, preventPop)
            else
              OKBtn(context, onPressed, preventPop)
          ],
        );

        if (preventPop) {
          return PopScope(canPop: false, child: dialog);
        }
        return dialog;
      },
    );
  }

  static Widget OKBtn(context, onPressed, [bool preventPop = false]) {
    return TextButton(
      child: Text('확인'),
      onPressed: () {
        onPressed();
        if (!preventPop) {
          Navigator.pop(context);
        }
      },
    );
  }

  static Widget FilledOKBtn(context, onPressed, [bool preventPop = false]) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorAssset.mainColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () {
          onPressed();
          if (!preventPop) {
            Navigator.pop(context);
          }
        },
        child: const Text('확인'),
      ),
    );
  }

  static Widget WithCancelBtn(context, onPressed) {
    return Row(
      children: [
        TextButton(
          child: Text('취소'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('확인'), // cancel이 true일 때 "확인", false일 때 buttonText
          onPressed: () {
            onPressed(); // 전달받은 onPressed 함수 호출
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
