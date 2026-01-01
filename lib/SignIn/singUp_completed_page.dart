import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class SignUpCompletePage extends StatelessWidget {
  const SignUpCompletePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // SizedBox(),
            Container(
              height: 40,
              margin: const EdgeInsets.fromLTRB(10, 100, 30, 0),
              // color: Colors.red,
            ),
            Container(
                // decoration:
                // BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  const Text(
                    "가입 완료",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    // decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)),
                    child: const Text("승인되기 전에도 매장과 메뉴를 등록할 수 있습니다."),
                  ),
                ])),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(children: [
                SizedBox(
                  width: double.infinity, // <-- Your width
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorAssset.mainColor,
                      foregroundColor: Colors
                          .white, // minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => CafeList()));
                    },
                    child: const Text('매장 등록하러 가기'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  // width: double.infinity,
                  // height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorAssset.mainColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);

                      // Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    child: const Text('홈으로'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
