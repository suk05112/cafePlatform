import 'package:flutter/material.dart';
import 'package:my_app/Payment/GiftToOthers.dart';
import 'package:my_app/Payment/Payment.dart';

class GifticonInfo extends StatelessWidget {
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  height: 100,
                  child: ItemInfo(),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  '*유의사항 \n상품은 우리랑 상관 없다. \n선물받은 기프티콘 사용안하면 80% 환불된다. \n나에게 선물하기 한 기프티콘은 일주일 안에 환불가능하다.\n80%이상 사용시 포인트로 환급된다. \n이런저런 유의사항 써놓기',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            Container(
                child: Column(
              children: [
                gift(),
                SizedBox(
                  height: 10.0,
                ),
                giftToMe()
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class ItemInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Row(
        children: [
          Image.asset(
            'assets/coffee.jpeg',
            height: 200,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                "아메리카노",
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
              Text(
                "4500원",
                style: TextStyle(fontSize: 15, color: Colors.black),
              )
            ],
          )
        ],
      ),
    );
  }
}

class gift extends StatefulWidget {
  @override
  _gift createState() =>
      _gift(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

int _cnt = 0;

class _gift extends State<gift> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 150,
      height: 30,
      child: ElevatedButton(
        child: Text('선물하기'),

        // 클릭 이벤트
        onPressed: () {
          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GiftToOthers()),
            );
          });
        },
      ),
    ));
  }
}

class giftToMe extends StatefulWidget {
  @override
  _giftToMe createState() =>
      _giftToMe(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

// int _cnt = 0;

class _giftToMe extends State<giftToMe> {
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
        child: Text('나에게 선물하기'),

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
