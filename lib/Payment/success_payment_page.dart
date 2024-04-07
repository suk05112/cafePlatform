import 'package:flutter/material.dart';
import 'package:my_app/home.dart';

class SuccessPaymentPage extends StatefulWidget {
  const SuccessPaymentPage({Key? key}) : super(key: key);

  @override
  State<SuccessPaymentPage> createState() => _SuccessPaymentPageState();
}

class _SuccessPaymentPageState extends State<SuccessPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Text("결제가 완료되었어요!"),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('홈으로 돌아가기'),

          // 클릭 이벤트
          onPressed: () {
            // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            });
          },
        ),
      ],
    )));
  }
}
