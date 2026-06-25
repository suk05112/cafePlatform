import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

class GifticonInfo extends StatelessWidget {
  const GifticonInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "선물하기"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ItemInfo(),
              const SizedBox(height: 20),
              Text(
                '*유의사항 \n상품은 우리랑 상관 없다. \n선물받은 기프티콘 사용안하면 80% 환불된다. \n나에게 선물하기 한 기프티콘은 일주일 안에 환불가능하다.\n80%이상 사용시 포인트로 환급된다. \n이런저런 유의사항 써놓기',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 28),
              gift(),
              const SizedBox(height: 12),
              giftToMe(),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemInfo extends StatelessWidget {
  const ItemInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/coffee.jpeg',
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '아메리카노',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '4500원',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class gift extends StatefulWidget {
  const gift({super.key});

  @override
  _gift createState() =>
      _gift(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

class _gift extends State<gift> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 150,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          foregroundColor: Colors.white,
          backgroundColor: ColorAssset.mainColor,
        ),
        child: Text('선물하기'),

        onPressed: () {
          Get.offAll(() => const TabPage(initialIndex: 0));
        },
      ),
    ));
  }
}

class giftToMe extends StatefulWidget {
  const giftToMe({super.key});

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

        onPressed: () {
          Get.offAll(() => const TabPage(initialIndex: 0));
        },
      ),
    ));
  }
}
