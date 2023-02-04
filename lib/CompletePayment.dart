import 'package:flutter/material.dart';
import 'package:my_app/home.dart';

class CompletePayment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [Text('결제가 완료되었습니다'), goHomeBtn()],
      ),
    );
  }
}

class goHomeBtn extends StatefulWidget {
  @override
  _goHomeBtn createState() =>
      _goHomeBtn(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

// int _cnt = 0;

class _goHomeBtn extends State<goHomeBtn> {
  @override
  Widget build(BuildContext context) {
    return Center(
        // Elevated Button 위젯
        child: SizedBox(
      width: 150,
      height: 30,
      child: ElevatedButton(
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
    ));
  }
}
