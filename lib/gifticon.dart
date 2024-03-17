import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class gifticon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("선물함")),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  child: Image.asset(
                    'coffee.png',
                    height: 250,
                  ),
                ),
                QrImageView(
                  data: '1234567890',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                Image.asset(
                  'barcode.png',
                  width: 200,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text('유효기간 2022.01.01 ~2022.12.31'),
                      Text('주문번호 12345678'),
                      Text('주문일 2022.10.23'),
                      Text('쿠폰 상태 사용안함/사용완료/기간만료'),
                      Text('교환처 지도로보기'),
                    ])
              ],
            ),
          )),
    );
  }
}
