import 'package:flutter/material.dart';
import 'package:my_app/Payment/GiftToOthers.dart';
import 'package:my_app/Payment/input_recipient_info_page.dart';
import 'package:my_app/home.dart';
import 'package:my_app/Payment/CommonPaymentWidget.dart';
import 'package:my_app/model/menu.dart';

class SelectGiftPage extends StatefulWidget {
  const SelectGiftPage({Key? key, required Menu this.menu}) : super(key: key);

  final Menu menu; // 메뉴 객체를 저장할 필드 추가

  @override
  State<SelectGiftPage> createState() => _SelectGiftPagePageState();
}

class _SelectGiftPagePageState extends State<SelectGiftPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
                child: Column(
                  children: [
                    Text("선물하기"),
                    CommonPaymentWidget.getGiftInfo(widget.menu),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('지금 바로 주문하기'),

                        // 클릭 이벤트
                        onPressed: () {
                          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GiftToOthers()),
                            );
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: Text('나에게 선물하기'),

                        // 클릭 이벤트
                        onPressed: () {
                          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GiftToOthers()),
                            );
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('선물하기'),

                        // 클릭 이벤트
                        onPressed: () {
                          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GiftToOthers()),
                            );
                          });
                        },
                      ),
                    )
                  ],
                ))));
  }
}
