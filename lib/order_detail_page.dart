import 'package:flutter/material.dart';
import 'package:my_app/Payment/CommonPaymentWidget.dart';

class OrderDetailPage extends StatefulWidget {
  OrderDetailPage({Key? key}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("init state 호출");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("To oo 님"),
                      Container(
                        height: 200,
                        child: CommonPaymentWidget.getGiftInfo(),
                      ),
                      Divider(thickness: 1, height: 1),
                      orderInfo(),
                      Divider(thickness: 1, height: 1),
                      payPrice(),
                      Divider(thickness: 1, height: 1),
                      payInfo()
                    ]))));
  }

  Widget orderInfo() {
    return Column(
      children: [
        Row(
          children: [Text("주문일"), Spacer(), Text("data")],
        ),
        Row(
          children: [Text("주문번호"), Spacer(), Text("data")],
        ),
        Row(
          children: [Text("결제방식"), Spacer(), Text("data")],
        ),
        Row(
          children: [Text("주문상태"), Spacer(), Text("data")],
        )
      ],
    );
  }

  Widget payPrice() {
    return Column(children: [
      Row(
        children: [Text("총 결제금액"), Spacer(), Text("4500")],
      ),
    ]);
  }

  Widget payInfo() {
    return Column(
        children: [Text("교환권 취소/환불 안내"), Text("결제금액ㅁㅇㄴ래ㅓㅈ대ㅓㅔㅐㅇ날멍ㄴㄹㅊㅊㅊㅊ")]);
  }
}
