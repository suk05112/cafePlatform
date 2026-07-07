import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/home.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/utils/analytics_service.dart';
import 'package:cafeplatform/utils/meta_analytics_service.dart';

class SuccessPaymentPage extends StatefulWidget {
  const SuccessPaymentPage({super.key});

  @override
  State<SuccessPaymentPage> createState() => _SuccessPaymentPageState();
}

class _SuccessPaymentPageState extends State<SuccessPaymentPage> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logPurchase();
    MetaAnalyticsService.instance.logPurchase(
      amount: 0,
      currency: 'KRW',
      contentType: 'product',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Text("결제가 완료되었어요!"),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            foregroundColor: Colors.white,
            backgroundColor: ColorAssset.mainColor,
          ),
          child: Text('홈으로 돌아가기'),

          // 클릭 이벤트
          onPressed: () {
            // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            setState(() {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => MyApp()),
                  (route) => false);
//
              // Navigator.of(context).popUntil((route) => route.isFirst);
              // Navigator.of(context, rootNavigator: true)
              //     .push(MaterialPageRoute(builder: (context) => TabPage()));

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => TabPage()),
              // );
            });
          },
        ),
        Spacer(),
      ],
    )));
  }
}
