import 'package:flutter/material.dart';
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
            Text('this is my page'),
            MyPoint(),
            Text('선물함'),
            Text('전체보기')
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
