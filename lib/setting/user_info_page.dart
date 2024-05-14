import "package:flutter/material.dart";
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .center, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CafeList()));
                    },
                    child: Text('로그아웃')),
                Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(height: 200, 'assets/coffee.jpeg'),
                      Text("이름"),
                      Text("이메일"),
                      Text("전화번호"),
                      Text("회원정보 수정")
                    ]),
                TextButton(
                    onPressed: () {
                      _showWithdrawalDialog();
                    },
                    child: Text('회원탈퇴')),
              ])),
    );
  }

  void _showWithdrawalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Withdrawal();
      },
    );
  }

  // 회원탈퇴 위젯
  Widget Withdrawal() {
    TextEditingController inputController = TextEditingController();
    bool showingFail = false;
    return AlertDialog(
        content: Container(
      width: 500,
      height: 500,
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
            child: Text("'회원탈퇴' 입력창을 다시 확인해주세요"),
            visible: showingFail,
          ),
          Row(
            children: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('탈퇴하기'),

                  // 클릭 이벤트
                  onPressed: () async {
                    if (inputController.text == '탈퇴하기') {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CafeList()));
                    } else {
                      setState(() {
                        showingFail = true;
                      });
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
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
  }
}
