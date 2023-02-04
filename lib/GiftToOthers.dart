import 'package:flutter/material.dart';
import 'package:my_app/Payment.dart';

class GiftToOthers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("선물하기"), // 타이틀 이름 지정
          foregroundColor: Colors.black,
          // titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: false, // 타이틀 이름을 가운데 정렬
          elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
          backgroundColor: Colors.redAccent.withOpacity(0.0),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [InputOhtersInfo(), nextBtn()],
          ),
        ));
  }
}

class InputOhtersInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text("받을 분의 전화번호를 입력해 주세요."),
          TextField(
            decoration: InputDecoration(
              hintText: '받을 분의 전화번호를 입력해 주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          Text("기프티콘은 카카오톡(문자)으로 전달됩니다. \n앱을 설치하지 않아도 이용할 수 있어요!"),
          SizedBox(
            height: 15.0,
          ),
          Text('메시지를 입력해주세요(생략가능)'),
          TextField(
            decoration: InputDecoration(
              hintText: '메시지를 입력해주세요(생략가능)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class nextBtn extends StatefulWidget {
  @override
  _nextBtn createState() =>
      _nextBtn(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

// int _cnt = 0;

class _nextBtn extends State<nextBtn> {
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
        child: Text('다음'),

        // 클릭 이벤트
        onPressed: () {
          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Payment()),
            );
          });
        },
      ),
    ));
  }
}
