import 'package:flutter/material.dart';
import 'package:my_app/Store.dart';

class MenuForStore extends StatelessWidget {
  // scaffold = 구성된 앱에서 디자인적인 부분을 도와주는 뼈대

  // 화면 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("매장보기"), // 타이틀 이름 지정
        foregroundColor: Colors.black,
        // titleTextStyle: TextStyle(color: Colors.black),
        centerTitle: false, // 타이틀 이름을 가운데 정렬
        elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
        backgroundColor: Colors.redAccent.withOpacity(0.0),
      ),
      body: Center(
        child: StoreGridview(),
      ),
    );
  }
}

class StoreGridview extends StatefulWidget {
  const StoreGridview({Key? key}) : super(key: key);

  @override
  _StoreGridviewState createState() => _StoreGridviewState();
}

class _StoreGridviewState extends State<StoreGridview> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        body: GridView.count(
          crossAxisCount: 1, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 6 / 1, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 5, //수평 Padding
          crossAxisSpacing: 1, //수직 Padding
          children: List.generate(11, (index) {
            //item 의 반목문 항목 형성
            return Container(
              // height: 20,
              // color: Colors.lightGreen,
              child: store(),
            );
          }),
        ),
      ),
    );
  }
}

class store extends StatefulWidget {
  @override
  _store createState() =>
      _store(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

int _cnt = 0;

class _store extends State<store> {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Store()));
        print("Container clicked");
      },
      child: Container(
        width: double.infinity,
        color: Colors.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 10),
            Text('매장'),
          ],
        ),
      ),
    );
  }
}

class StoreTabPage extends StatefulWidget {
  const StoreTabPage({Key? key}) : super(key: key);

  @override
  _StoreTabPageState createState() => _StoreTabPageState();
}

class _StoreTabPageState extends State<StoreTabPage>
    with TickerProviderStateMixin {
  late TabController _storetabController;

  @override
  void initState() {
    _storetabController = TabController(
      length: 2,
      vsync: this, //vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '매장 리스트 보기',
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                // border: Border.all(),
                ),
            child: TabBar(
              tabs: [
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    '리스트로 보기',
                  ),
                ),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    '지도로 보기',
                  ),
                ),
              ],
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  //배경 그라데이션 적용
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blueAccent,
                    Colors.pinkAccent,
                  ],
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              controller: _storetabController,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _storetabController,
              children: [
                Container(
                  color: Colors.yellow[200],
                  alignment: Alignment.center,
                  child: StoreGridview(),
                ),
                Container(
                  color: Colors.green[200],
                  alignment: Alignment.center,
                  child: Text(
                    'Tab2 View',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
