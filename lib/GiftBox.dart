import 'package:flutter/material.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/gifticon_page.dart';
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
        body: Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
          child: Column(
            children: <Widget>[
              Row(
                children: [CountUnused(), CountUsed()],
              ),
              Expanded(
                  child: SizedBox(
                height: 30,
                child: GifticonGridview(),
              )),
              Text("선물"),
            ],
          ),
        ));
  }

  Widget CountUsed() {
    return FutureBuilder<List<Gifticon>>(
      future: GifticonGridview.fetchGifticonList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 인디케이터를 표시합니다.
        } else if (snapshot.hasError) {
          return Text('오류: ${snapshot.error}'); // 오류 메시지를 표시합니다.
        } else {
          int usedCount = snapshot.data!
              .where((gifticon) => gifticon.validity!.isBefore(DateTime.now()))
              .length;
          return Row(
            children: [
              Text("사용완료"),
              Text("$usedCount"),
            ],
          );
        }
      },
    );
  }

  Widget CountUnused() {
    return FutureBuilder<List<Gifticon>>(
      future: GifticonGridview.fetchGifticonList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 인디케이터를 표시합니다.
        } else if (snapshot.hasError) {
          return Text('오류: ${snapshot.error}'); // 오류 메시지를 표시합니다.
        } else {
          int unusedCount = snapshot.data!
              .where((gifticon) =>
                  gifticon.validity!.isAfter(DateTime.now()) ||
                  gifticon.validity!.isAtSameMomentAs(DateTime.now()))
              .length;
          return Row(
            children: [
              Text("미사용"),
              Text("$unusedCount"),
            ],
          );
        }
      },
    );
  }
}

class GifticonGridview extends StatefulWidget {
  GifticonGridview({Key? key}) : super(key: key);
  int unusedCount = 0;
  int usedCount = 0;

  static Future<List<Gifticon>> fetchGifticonList() async {
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

  @override
  _GifticonGridviewState createState() => _GifticonGridviewState();
}

class _GifticonGridviewState extends State<GifticonGridview> {
  late Future<List<Gifticon>> gifticonListFuture = [] as Future<List<Gifticon>>;

  @override
  void initState() {
    super.initState();
    gifticonListFuture = GifticonGridview.fetchGifticonList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Gifticon>>(
        future: gifticonListFuture,
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
                  children: List.generate(gifticonList.length, (index) {
                    //item 의 반목문 항목 형성
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GifticonPage(
                                      gifticon: gifticonList[index],
                                    )));
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
                          child: Column(
                            children: [
                              Image.network("${gifticonList[index].menu_url}",
                                  width: 79, height: 79, fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                print(gifticonList[index].menu_url);
                                print(error);
                                return Image(
                                    image: AssetImage('assets/coffee.jpeg'),
                                    width: 79,
                                    height: 79,
                                    fit: BoxFit.fill);
                              }),
                              Text("${gifticonList[index].name}"),
                            ],
                          )),
                    );
                  }),
                ),
              );
            }
          }
        });
  }
}
