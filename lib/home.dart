import 'package:flutter/material.dart';
import 'package:cafeplatform/Payment/GifticonInfo.dart';
import 'package:cafeplatform/setting/myPage.dart';

// StatelessWidget은 변화지 않는 화면을 작업할 때 사용.
// 변화는 화면을 작업 하고싶을 경우에는 StatefulWidget을 사용.
class Home extends StatelessWidget {
  const Home({super.key});

  // MaterialApp = 앱으로서 기능을 할 수 있도록 도와주는 뼈대
  @override
  Widget build(BuildContext context) {
    // return MaterialApp() -> Material 디자인 테마를 사용
    return MaterialApp(
      title: "MyApp", // 앱 이름
      debugShowCheckedModeBanner: false, // 타이틀 바 우측 띠 제거

      // 앱의 기본적인 테마를 지정
      theme: ThemeData(
        primarySwatch: Colors.blue, // priamrySwatch 기본적인 앱의 색상을 지정
      ),

      home: MyWidget(), // 앱이 실행될 때 표시할 화면의 함수를 호출
    );
  }
}

// 앱이 실행 될때 표시할 화면의 함수
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  // scaffold = 구성된 앱에서 디자인적인 부분을 도와주는 뼈대

  // 화면 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar에 AppBar 위젯을 가져온다.
        appBar: AppBar(
          title: Text("Home"), // 타이틀 이름 지정
          centerTitle: true,

          foregroundColor: Colors.black,
          // titleTextStyle: TextStyle(color: Colors.black),
          elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
          backgroundColor: Colors.redAccent.withOpacity(0.0),

          // appBar 높이
          // toolbarHeight: 70,

          // 좌측 아이콘 버튼
          // leading: IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.menu),
          // ),
        ),

        // 앱의 body 부분
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CafeBannerWidget(),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '검색',
                      hintText: '매장검색, 메뉴검색',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    color: Colors.red,
                    height: 200,
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: categoryState(),
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: BodyLayout(),
                ),
              ],
            )));
  }
}

// 버튼을 눌렀을 때 숫자를 카운트 하기위해서는 화면을 변하게끔 작업해야한다.
// 즉, StatefulWidget 선언해야 한다.
class cntState extends StatefulWidget {
  const cntState({super.key});

  @override
  _cntState createState() =>
      _cntState(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

int _cnt = 0;

class _cntState extends State<cntState> {
  @override
  Widget build(BuildContext context) {
    return Center(
      // Elevated Button 위젯
      child: ElevatedButton(
        // 버튼에 Text를 입힌다.
        child: Text('현재 숫자 : $_cnt'),

        // 클릭 이벤트
        onPressed: () {
          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
          setState(() {
            _cnt++;
          });
        },
      ),
    );
  }
}

List<Image> categoryImage = [
  Image.asset('coffee.jpeg'),
  Image.asset('coffee.jpeg'),
  Image.asset('coffee.jpeg'),
  Image.asset('coffee.jpeg'),
  Image.asset('coffee.jpeg'),
  Image.asset('coffee.jpeg'),
];

var categoryText = [
  "아메리카노",
  "케이크",
  "크로플",
  "라떼",
  "에이드",
  "디저트",
];

class GridviewPage extends StatefulWidget {
  const GridviewPage({super.key});

  @override
  _GridviewPageState createState() => _GridviewPageState();
}

class _GridviewPageState extends State<GridviewPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GridviewPage'),
        ),
        body: GridView.count(
          crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 2, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 5, //수평 Padding
          crossAxisSpacing: 1, //수직 Padding
          children: List.generate(11, (index) {
            //item 의 반목문 항목 형성
            return Container(
              color: Colors.lightGreen,
              child: Text(' Item : $index'),
            );
          }),
        ),
      ),
    );
  }
}

class categoryState extends StatefulWidget {
  const categoryState({super.key});

  @override
  _categoryState createState() =>
      _categoryState(); // StatefulWidget은 상태를 생성하는 createState() 메서드로 구현한다.
}

class _categoryState extends State<categoryState> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyPage()));
      },
      child: Container(
        // height: 300,
        child: GridView.builder(
          itemCount: 6, //item 개수
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
            // childAspectRatio: 1 / 2, //item 의 가로 1, 세로 2 의 비율
            mainAxisSpacing: 1, //수평 Padding
            crossAxisSpacing: 1, //수직 Padding
          ),
          itemBuilder: (BuildContext context, int index) {
            //item 의 반목문 항목 형성
            return Container(
                height: 50,
                width: 30,
                color: Colors.blue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets.coffee.jpeg',
                      height: 40,
                    ),
                    Text(
                      categoryText[index],
                      style: TextStyle(fontSize: 8),
                    )
                  ],
                ));
          },
        ),
      ),
    );
    // Elevated Button 위젯
  }
}

class BodyLayout extends StatelessWidget {
  const BodyLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return _myListView(context);
  }
}

Widget _myListView(BuildContext context) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {
      return Container(
        color: Color(0xFFEEEEEE),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        width: 80.0,
        child: RecommendedGifticon(),
      );
    },
  );
}

class RecommendedGifticon extends StatefulWidget {
  const RecommendedGifticon({super.key});

  @override
  _RecommendedGifticonState createState() => _RecommendedGifticonState();
}

class _RecommendedGifticonState extends State<RecommendedGifticon> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => GifticonInfo()));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 10),
          Text('기프티콘 \n 추천'),
        ],
      ),
    );
  }
}

class CafeBannerWidget extends StatelessWidget {
  const CafeBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Container(
        // width: 150,
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        color: Colors.blue,
        child: PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: controller,
          children: const <Widget>[
            Center(
              child: Text('카페 광고배너1'),
            ),
            Center(
              child: Text('카페 광고배너2'),
            ),
            Center(
              child: Text('카페 광고배너3'),
            ),
          ],
        ));
  }
}
