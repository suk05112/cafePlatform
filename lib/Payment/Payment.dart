import 'package:flutter/material.dart';
import 'package:my_app/Payment/CommonPaymentWidget.dart';
import 'package:my_app/Payment/CompletePayment.dart';
import 'package:my_app/provider/menu_provider.dart';
import 'package:provider/provider.dart';

class Payment extends StatelessWidget {
  Payment({super.key, required this.type});

  var type;
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
        body: SafeArea(
            child: Column(
          children: [
            Container(
              // width: double.infinity,
              // height: double.infinity,
              margin: EdgeInsets.fromLTRB(10, 5, 10, 10),

              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  CommonPaymentWidget.getGiftInfo(),
                  type == 1
                      ? SizedBox(
                          height: 0,
                        )
                      : ReceiverInfo(),
                  ApplyCoupons(),
                  // ApplyPoints(),
                ],
              ),
            ),
            Spacer(),
            paymentBtn(),
          ],
        )));
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
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
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

class ReceiverInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          CommonPaymentWidget.getGiftInfo(),
          InputInfoWidget(
            title: "받는 분의 전화번호를 입력해 주세요",
            hintText: "-없이 입력",
            validator: validatePhoneNumber,
          ),
          Text("기프티콘은 카카오톡(문자)으로 전달됩니다. \n앱을 설치하지 않아도 이용할 수 있어요!"),
          SizedBox(
            height: 15.0,
          ),
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

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }
}
