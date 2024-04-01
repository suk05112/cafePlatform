import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:my_app/Home.dart';
import 'package:my_app/MenuForStore.dart';
import 'package:my_app/cafe_list_map_view.dart';
import 'package:my_app/cafe_list_page.dart';
import 'package:my_app/myPage.dart';
import 'package:my_app/GiftBox.dart';
import 'package:my_app/provider/store_provider.dart';
import 'package:provider/provider.dart';

// void main() => runApp(MyApp()); // 프로그램을 실행할 때 MyApp 부터 실행하겠어!

void main() async {
  await _initialize();
  runApp(MyApp());
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: 'ofzfofvuev',
      onAuthFailed: (ex) => log("********* 네이버맵 인증오류 : $ex *********"));
}

// StatelessWidget은 변화지 않는 화면을 작업할 때 사용.
// 변화는 화면을 작업 하고싶을 경우에는 StatefulWidget을 사용.
class MyApp extends StatelessWidget {
  // MaterialApp = 앱으로서 기능을 할 수 있도록 도와주는 뼈대
  @override
  Widget build(BuildContext context) {
    // return MaterialApp() -> Material 디자인 테마를 사용
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => StoreProvider()),
        ],
        child: MaterialApp(
          title: "MyApp", // 앱 이름
          debugShowCheckedModeBanner: false, // 타이틀 바 우측 띠 제거

          // 앱의 기본적인 테마를 지정
          theme: ThemeData(
            primarySwatch: Colors.blue, // priamrySwatch 기본적인 앱의 색상을 지정
          ),

          home: MyWidget(), // 앱이 실행될 때 표시할 화면의 함수를 호출
        ));
  }
}

// 앱이 실행 될때 표시할 화면의 함수
class MyWidget extends StatelessWidget {
  // scaffold = 구성된 앱에서 디자인적인 부분을 도와주는 뼈대

  // 화면 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱의 body 부분
      body: Center(
        child: TabPage(),
      ),
    );
  }
}

// Bottom Navigation Bar
// 동적으로 화면을 변화하므로 StatefulWdiget 사용
class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _selectedIndex = 0; // 처음에 나올 화면 지정

  // 이동할 페이지
  List _pages = [Home(), GiftBox(), CafeList(), myPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_selectedIndex], // 페이지와 연결
      ),

      // BottomNavigationBar 위젯
      bottomNavigationBar: BottomNavigationBar(
        //type: BottomNavigationBarType.fixed, // bottomNavigationBar item이 4개 이상일 경우

        // 클릭 이벤트
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // 현재 선택된 index
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blue,
        // unselectedLabelStyle: TextStyle(color: Colors.grey.shade300),

        // BottomNavigationBarItem 위젯
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "매장보기"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "mapview"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "MyPage"),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    // state 갱신
    setState(() {
      _selectedIndex = index; // index는 item 순서로 0, 1, 2로 구성
    });
  }
}
