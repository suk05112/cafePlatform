import 'package:flutter/material.dart';
import 'package:my_app/CompletePayment.dart';

class Payment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("결제하기"), // 타이틀 이름 지정
          foregroundColor: Colors.black,
          // titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: false, // 타이틀 이름을 가운데 정렬
          elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
          backgroundColor: Colors.redAccent.withOpacity(0.0),
        ),
        body: Column(
          children: [
            Container(
              // width: double.infinity,
              // height: double.infinity,
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  PaymentInfo(),
                  ApplyCoupons(),
                  ApplyPoints(),
                ],
              ),
            ),
            paymentBtn(),
          ],
        ));
  }
}

class PaymentInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text("결제 정보"),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, style: BorderStyle.solid, width: 1)),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'coffee.png',
                      height: 70,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("결제 금액"), Text("4500")],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ApplyCoupons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('사용가능쿠폰'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '받을 분의 전화번호를 입력해 주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              Text("찾아보기"),
            ],
          ),
          Row(
            children: [Text('00카페 20%할인쿠폰'), Text('적용완료')],
          )
        ],
      ),
    );
  }
}

class ApplyPoints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text("포인트"),
          TextField(
            decoration: InputDecoration(
              hintText: '20000원 이용가능',
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

class paymentBtn extends StatefulWidget {
  @override
  _paymentBtn createState() =>
      _paymentBtn(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

// int _cnt = 0;

class _paymentBtn extends State<paymentBtn> {
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
        child: Text('4500원 결제하기'),

        // 클릭 이벤트
        onPressed: () {
          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CompletePayment()),
            );
          });
        },
      ),
    ));
  }
}
