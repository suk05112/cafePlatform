import 'package:flutter/material.dart';
import 'package:my_app/GiftBox.dart';
import 'package:my_app/setting_page.dart';
// import 'package:flutter/semantics.dart';

class myPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Page"), // 타이틀 이름 지정
          foregroundColor: Colors.black,
          // titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: false, // 타이틀 이름을 가운데 정렬
          elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
          backgroundColor: Colors.redAccent.withOpacity(0.0),
        ),
        body: Column(
          children: [
            IconButton(
              icon: Icon(Icons.settings), // 검색 아이콘 생성
              onPressed: () {
                // 아이콘 버튼 실행
                print('Search button is clicked');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingPage()));
              },
            ),
            Text('this is my page'),
            MyPoint(),
            Text('선물함'),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GiftBox()));
                },
                child: Text('전체보기'))
          ],
        ));
  }
}

class MyPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("포인트"), Text('20000원')],
      ),
    );
  }
}
