import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GiftIcon extends StatefulWidget {
  const GiftIcon({Key? key}) : super(key: key);

  @override
  State<GiftIcon> createState() => _GiftIconState();
}

class _GiftIconState extends State<GiftIcon> {
  late bool showFront;

  @override
  void initState() {
    super.initState();

    showFront = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("선물함")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFront = !showFront;
                  });
                },
                child: AnimatedSwitcher(
                  transitionBuilder: wrapAnimatedBuilder,
                  layoutBuilder: (widget, list) {
                    return Stack(
                      children: [widget!, ...list],
                    );
                  },
                  duration: Duration(milliseconds: 1000),
                  child: showFront ? _renderFront() : _renderBack(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('유효기간 2022.01.01 ~2022.12.31'),
                  Text('주문번호 12345678'),
                  Text('주문일 2022.10.23'),
                  Text('쿠폰 상태 사용안함/사용완료/기간만료'),
                  Text('교환처 지도로보기'),
                ],
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Image.asset(
                  'assets/barcode.png',
                  height: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderCard({
    required Key key,
    bool isBack = true,
  }) {
    if (isBack) {
      return QrImageView(
        data: '1234567890',
        version: QrVersions.auto,
        size: 200.0,
      );
    } else {
      return Container(
        padding: EdgeInsets.all(20),
        child: Image.asset(
          'assets/menu.png',
          height: 250,
        ),
      );
    }
  }

  Widget _renderFront() {
    return _renderCard(
      key: ValueKey(true),
      isBack: false,
    );
  }

  Widget _renderBack() {
    return _renderCard(
      key: ValueKey(false),
      isBack: true,
    );
  }

  Widget wrapAnimatedBuilder(Widget widget, Animation<double> animation) {
    final rotate = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotate,
      child: widget,
      builder: (_, widget) {
        final isBack = showFront
            ? widget!.key == ValueKey(true)
            : widget!.key != ValueKey(true);

        final value = isBack ? min(rotate.value, pi / 2) : rotate.value;

        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.0025;

        tilt *= isBack ? -1.0 : 1.0;

        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }
}
