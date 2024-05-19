import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/Payment/GifticonInfo.dart';
import 'package:my_app/model/gifticon.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GifticonPage extends StatefulWidget {
  const GifticonPage({Key? key, required this.gifticon}) : super(key: key);

  final Gifticon gifticon;
  @override
  State<GifticonPage> createState() => _GifticonPageState();
}

class _GifticonPageState extends State<GifticonPage> {
  late bool showFront;

  @override
  void initState() {
    super.initState();

    showFront = true;
  }

  @override
  Widget build(BuildContext context) {
    Gifticon gifticon = widget.gifticon;

    print("receiver ${gifticon.receiver}");
    return Scaffold(
        appBar: AppBar(title: Text("선물함")),
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text('From ${gifticon.receiver}'),
                  Image.network("${gifticon.menu_url}",
                      width: 250, height: 250, fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                    print(error);
                    return Image(
                        image: AssetImage('assets/coffee.jpeg'),
                        width: 79,
                        height: 79,
                        fit: BoxFit.fill);
                  }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${gifticon.name}'),
                      Text('유효기간 ${gifticon.validity}'),
                      Text('주문번호 ${gifticon.order_id}'),
                      gifticonStatus(gifticon.use_yn),
                      Text('교환처 지도로보기'),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('사용하기'),

                      // 클릭 이벤트
                      onPressed: () async {
                        await ShowQR();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget gifticonStatus(int status) {
    if (status == 0) {
      return Text("쿠폰 상태 사용가능");
    } else if (status == 1) {
      return Text("쿠폰 상태 사용완료");
    } else if (status == 2) {
      return Text("쿠폰 상태 기간완료");
    } else {
      return Text("쿠폰 상태 사용 불가능");
    }
  }

  Future<void> ShowQR() {
    return showDialog(
        context: context,
        barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부

        builder: (BuildContext context) {
          return Dialog(
              child: Container(
            height: 350, // 원하는 높이 설정
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
                Container(
                    padding: EdgeInsets.all(20),
                    child: QrImageView(
                      data: '1234567890',
                      version: QrVersions.auto,
                      size: 200.0,
                    )),
                // TextButton(
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //     child: Text('닫기'))
              ],
            ),
          ));
        });
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
