import 'package:flutter/material.dart';
import 'package:my_app/GiftBox.dart';
import 'package:my_app/order_list.dart';
import 'package:my_app/setting/notice_page.dart';
import 'package:my_app/setting/setting_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text("My Page"), // 타이틀 이름 지정
        //   foregroundColor: Colors.black,
        //   // titleTextStyle: TextStyle(color: Colors.black),
        //   centerTitle: false, // 타이틀 이름을 가운데 정렬
        //   elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
        //   backgroundColor: Colors.redAccent.withOpacity(0.0),
        // ),
        body: Container(
            margin: EdgeInsets.fromLTRB(21, 50, 21, 21),
            child: Column(
              children: [
                Container(
                    width: double.infinity,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.settings), // 검색 아이콘 생성
                            onPressed: () {
                              // 아이콘 버튼 실행
                              print('Search button is clicked');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingPage()));
                            },
                          ),
                        ])),
                // MyPoint(),
                Container(
                    width: double.infinity,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('선물함'),
                        ])),
                getGiticonRowGrid(),
                Container(
                  width: double.infinity,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GiftBox()));
                            },
                            child: Text('전체보기')),
                      ]),
                ),
                SizedBox(
                  height: 20,
                ),
                getListView()
              ],
            )));
  }

  Widget getListView() {
    var selectedPageName = ['주문내역', '고객센터'];

    var selectedPage = [OrderListPage(), const NoticePage()];
    // var listView = ListView.separated(
    var listView = ListView.builder(
      itemCount: selectedPage.length,
      itemExtent: 46.0,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
            //You need to make my child interactive
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => selectedPage[index])),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${selectedPageName[index]}"),
                  const Divider()
                ]));
        // return ListTile(title: Text(allItems[index]));
      },
    );
    return listView;
  }

  Widget getGiticonRowGrid() {
    var gifticonList = ["아메리카노", "라떼", "에이드", "커피", "아메리카노", "라떼", "에이드", "커피"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: gifticonList.map((gifticon) {
          return GestureDetector(
            onTap: () {
              // NavigaageRoutor.push(context,
              //     MaterialPte(builder: (context) => GifticonListPage()));
              print("Container clicked");
            },
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.orange,
                ),
              ),
              width: 100,
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("From ㅇㅇ"),
                  Text("$gifticon"),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget getGiticonRowGrid() {
  //   var gifticonList = ["아메리카노", "라떼", "에이드", "커피", "아메리카노", "라떼", "에이드", "커피"];

  //   return GridView.count(
  //     // padding: EdgeInsets.all(20.0),
  //     shrinkWrap: true,
  //     crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
  //     childAspectRatio: 1 / 1, //item 의 가로 1, 세로 2 의 비율
  //     mainAxisSpacing: 10, //수평 Padding
  //     crossAxisSpacing: 10, //수직 Padding
  //     children: List.generate(gifticonList.length, (index) {
  //       //item 의 반목문 항목 형성
  //       return new GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => GiftIcon()));
  //           print("Container clicked");
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //             border: Border.all(
  //               width: 1,
  //               color: Colors.orange,
  //             ),
  //           ),
  //           height: 10,
  //           child: Column(
  //               children: [Text("From ㅇㅇ"), Text("${gifticonList[index]}")]),
  //         ),
  //       );
  //     }),
  //   );
  // }
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
