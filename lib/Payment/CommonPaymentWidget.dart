import 'package:flutter/material.dart';

class CommonPaymentWidget {
  Widget getGiftInfo() {
    return Column(
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
    );
  }
}
