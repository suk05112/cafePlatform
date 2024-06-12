import 'package:flutter/material.dart';
import 'package:my_app/order_detail_page.dart';

class OrderListPage extends StatefulWidget {
  OrderListPage({Key? key}) : super(key: key);

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
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
                      Text("store 이름"),
                    ]))));
  }

  Widget Order() {
    return Container(
        height: 200,
        // width: double.infinity,
        padding: EdgeInsets.fromLTRB(21, 15, 21, 10),
        decoration: BoxDecoration(
          color: Color(0xffCAC9FF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("주문일"), Text("2024.05.17 14:39:23")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("From 홍길동"),
                Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderDetailPage()));
                    },
                    child: Text('주문상세')),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/coffee.png',
                  width: 130,
                  height: 130,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      "메뉴 이름",
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                    Text(
                      "메뉴 가격",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    Text("4500원")
                  ],
                )
              ],
            ),
          ],
        ));
  }
}
