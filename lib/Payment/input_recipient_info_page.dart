import 'package:flutter/material.dart';
import 'package:my_app/Payment/success_payment_page.dart';
import 'package:my_app/home.dart';
import 'package:my_app/Payment/CommonPaymentWidget.dart';

class InputRecipientInfoPage extends StatefulWidget {
  const InputRecipientInfoPage({Key? key}) : super(key: key);

  @override
  State<InputRecipientInfoPage> createState() => _InputRecipientInfoPagetate();
}

class _InputRecipientInfoPagetate extends State<InputRecipientInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Text("선물하기"),
        Text("받을 분의 전화번호를 입력해주세요"),
        Text("기프티콘은 카카오톡(문자)로 전달됩니다."),
        Text("메시지를 입력해주세요(생략가능)"),
        CommonPaymentWidget.getGiftInfo(),
        PaymentMehtod(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('다음'),

          // 클릭 이벤트
          onPressed: () {
            // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuccessPaymentPage()),
              );
            });
          },
        ),
      ],
    )));
  }

  Widget PaymentMehtod() {
    return Column(children: [
      Text("결제 수단"),
      Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('신용/체크카드'),

          // 클릭 이벤트
          onPressed: () {
            // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuccessPaymentPage()),
              );
            });
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('카카오페이'),

          // 클릭 이벤트
          onPressed: () {
            // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuccessPaymentPage()),
              );
            });
          },
        ),
      ]),
      Row(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('네이버페이'),

          // 클릭 이벤트
          onPressed: () {
            // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuccessPaymentPage()),
              );
            });
          },
        ),
      ]),
    ]);
  }
}
