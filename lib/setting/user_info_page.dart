import "package:flutter/material.dart";
import 'package:my_app/Style/CommonSection.dart';
import 'package:my_app/cafe_list_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .end, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonSection.getHeader2(context, "더보기"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CafeList()));
                        },
                        child: Text('로그아웃')),
                    Container(
                      width: double.infinity,
                      // height: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipOval(
                                child: SizedBox.fromSize(
                              size: Size.fromRadius(48), // Image radius
                              child: Image.asset(
                                  height: 200, 'assets/coffee.jpeg'),
                            )),
                            Text("이름"),
                            Text("이메일"),
                            Text("전화번호"),
                            Text("회원정보 수정")
                          ]),
                    ),
                    Spacer(),
                    TextButton(
                        onPressed: () {
                          print("눌림");
                          _showWithdrawalDialog();
                        },
                        child: Text('회원탈퇴')),
                    SizedBox(
                      height: 30,
                    )
                  ]))),
    );
  }

  // 회원탈퇴 위젯
  void _showWithdrawalDialog() {
    TextEditingController inputController = TextEditingController();
    bool showingFail = false;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                content: Container(
              width: 500,
              height: 250,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("탈퇴하시겠습니끼?"),
                  Text("'회원탈퇴' 입력"),
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: '회원탈퇴',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  Visibility(
                    child: Text(
                      "'회원탈퇴' 입력창을 다시 확인해주세요",
                      style:
                          TextStyle(color: Colors.red), // 원하는 스타일을 적용할 수 있습니다.
                    ),
                    visible: showingFail,
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('탈퇴하기'),

                          // 클릭 이벤트
                          onPressed: () async {
                            print("버튼 눌림");
                            if (inputController.text == '탈퇴하기') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CafeList()));
                            } else {
                              setState(() {
                                print("버튼 눌림2");

                                showingFail = true;
                              });
                            }
                          },
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('취소'),

                          // 클릭 이벤트
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
          });
        });
  }
}
