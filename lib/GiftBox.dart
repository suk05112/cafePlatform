import 'package:flutter/material.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/gifticon.dart';
import 'package:my_app/model/gifticon.dart';

class GiftBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("선물함"), // 타이틀 이름 지정
        foregroundColor: Colors.black,
        // titleTextStyle: TextStyle(color: Colors.black),
        centerTitle: false, // 타이틀 이름을 가운데 정렬
        elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
        backgroundColor: Colors.redAccent.withOpacity(0.0),
      ),
      body: Column(
        children: <Widget>[
          Text("유효기간"),
          Expanded(
              child: SizedBox(
            height: 30,
            child: GifticonGridview(),
          )),
          Text("선물"),
          Expanded(
              child: SizedBox(
            height: 30,
            child: GifticonGridview(),
          )),
        ],
      ),
    );
    // MaterialApp(
    //   home:
    // );
  }
}

class GifticonGridview extends StatefulWidget {
  const GifticonGridview({Key? key}) : super(key: key);

  @override
  _GifticonGridviewState createState() => _GifticonGridviewState();
}

// var gifticonList = ["아메리카노", "라떼", "에이드", "커피"];

class _GifticonGridviewState extends State<GifticonGridview> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Gifticon>>(
        future: fetchGifticonList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // 로딩 인디케이터를 표시합니다.
          } else if (snapshot.hasError) {
            return Text('오류: ${snapshot.error}'); // 오류 메시지를 표시합니다.
          } else {
            final gifticonList = snapshot.data;

            if (gifticonList == null || gifticonList.isEmpty) {
              return Scaffold(body: Text("사용 가능한 선물이 없습니다."));
            } else {
              return Scaffold(
                body: GridView.count(
                  padding: EdgeInsets.all(20.0),
                  shrinkWrap: true,
                  crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                  childAspectRatio: 1 / 1, //item 의 가로 1, 세로 2 의 비율
                  mainAxisSpacing: 10, //수평 Padding
                  crossAxisSpacing: 10, //수직 Padding
                  children: List.generate(gifticonList!.length, (index) {
                    //item 의 반목문 항목 형성
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GiftIcon()));
                        print("Container clicked");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.orange,
                          ),
                        ),
                        height: 10,
                        child: Text("${gifticonList![index]}"),
                      ),
                    );
                  }),
                ),
              );
            }
          }
        });
  }

  Future<List<Gifticon>> fetchGifticonList() async {
    try {
      print("store_provider::fetchStoreList:: fetch 호출");
      var response = await Api().client.getGifticonList(1);
      var gifticonList = response.gifticonList;
      return gifticonList;
    } catch (error) {
      print("store_provider::fetchStoreList:: fetch 오류: $error");
      return [];
    }
  }
}
