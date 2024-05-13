import "package:flutter/material.dart";
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
              Image.asset(height: 200, 'assets/coffee.jpeg'),
              Text("이름"),
              Text("이메일"),
              Text("전화번호"),
              Text("회원정보 수정")
            ]),
      ),
    );
  }
}
