import 'package:flutter/material.dart';
import 'package:my_app/home.dart';
import 'package:my_app/Payment/CommonPaymentWidget.dart';

class SelectGiftPage extends StatefulWidget {
  const SelectGiftPage({Key? key}) : super(key: key);

  @override
  State<SelectGiftPage> createState() => _SelectGiftPagePageState();
}

class _SelectGiftPagePageState extends State<SelectGiftPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Text("선물하기"),
        CommonPaymentWidget.getGiftInfo(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('지금 바로 주문하기'),

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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('나에게 선물하기'),

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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('선물하기'),

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
