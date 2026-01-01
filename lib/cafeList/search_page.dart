import 'package:flutter/material.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/store_post_response.dart';
import 'package:cafeplatform/gifticon_page.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/menu_page.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 디코딩을 위해 필요

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String inputText = '';
  List<StoreCard> storeCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(title: "매장검색"),
        backgroundColor: Colors.white,
        body: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Column(children: <Widget>[
              SearchBar(
                hintText: "검색어를 입력하세요",
                shape: WidgetStateProperty.all(ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
                onSubmitted: (value) {
                  setState(() => inputText = value);
                  print('Input Text = $inputText');
                  searchStore(value);
                },
                trailing: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // 현재 입력된 텍스트로 onSubmitted 실행
                      setState(() {
                        print('Button Clicked, Input Text = $inputText');
                        searchStore(inputText);
                      });
                    },
                  )
                ],
              ),
              SizedBox(height: 20),
              // 검색 결과를 보여주는 부분
              Expanded(
                child: ListView.builder(
                  itemCount: storeCards.length,
                  itemBuilder: (context, index) {
                    final storeCard = storeCards[index];
                    return StoreCardWidget(storeCard);
                  },
                ),
              ),
            ])));
  }

  Widget _buildStoreImage(String imageUrl, double width, double height) {
    // URL 검증 및 정리
    final cleanedUrl = imageUrl.trim();

    // URL이 비어있거나 유효하지 않은 경우
    if (cleanedUrl.isEmpty ||
        (!cleanedUrl.startsWith('http://') &&
            !cleanedUrl.startsWith('https://'))) {
      return Image.asset(
        'assets/coffee.jpeg',
        width: width,
        height: height,
        fit: BoxFit.fill,
      );
    }

    return Image.network(
      cleanedUrl,
      width: width,
      height: height,
      fit: BoxFit.fill,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame != null) return child;
        // 프레임이 null이면 로딩 중이거나 에러
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Image.asset(
            'assets/coffee.jpeg',
            width: width,
            height: height,
            fit: BoxFit.fill,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('이미지 로드 오류: $error, URL: $cleanedUrl');
        print('스택 트레이스: $stackTrace');
        return Image.asset(
          'assets/coffee.jpeg',
          width: width,
          height: height,
          fit: BoxFit.fill,
        );
      },
      // 캐시 최적화
      cacheWidth: width.toInt(),
      cacheHeight: height.toInt(),
      filterQuality: FilterQuality.medium,
    );
  }

  Widget StoreCardWidget(StoreCard? storeCard) {
    return GestureDetector(
        onTap: () {
          print("item 선택됨");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StorePage(
                        storeId: storeCard?.store_id ?? -1,
                        storeName: storeCard?.store_name ?? "store name",
                      )));
        },
        child: SizedBox(
          height: 130,
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(5),
            // decoration: BoxDecoration(
            //   border: Border.all(color: Color.fromARGB(255, 0, 0, 0)),
            //   borderRadius: BorderRadius.all(Radius.circular(5.0)),
            // ),
            width: 400,
            child: Row(children: [
              Expanded(child: _buildStoreImage(storeCard!.store_logo, 90, 90)),
              Spacer(),
              Text(storeCard.store_name),
            ]),
          ),
        ));
  }

  Future<void> searchStore(String item) async {
    const String baseUrl = 'https://openapi.naver.com/v1/search/local.json';
    const int display = 1; // 표시할 검색 결과 수
    double mapx, mapy;
    // 헤더 추가
    const headers = {
      'X-Naver-Client-Id': 'ipCnGcVKtSJXvUmXKkit',
      'X-Naver-Client-Secret': 'xMb38FealO',
    };

    // API 호출 URL
    final url = Uri.parse('$baseUrl?query=$item&display=$display');

    try {
      // GET 요청 전송
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // 성공적인 응답
        final body = json.decode(response.body);
        final items = body['items'] as List;

        for (var item in items) {
          print("${item['mapx']}, ${item['mapy']}");

          final mapxString = item['mapx'] as String;
          final mapyString = item['mapy'] as String;
          print("$mapxString, $mapyString");
          // double로 변환
          mapx = double.parse(mapxString) / 1e7;
          mapy = double.parse(mapyString) / 1e7;
        }

        if (items.isNotEmpty) {
          // items 내 첫 번째 아이템에서 mapx, mapy를 가져옴
          final firstItem = items.first;
          final mapxString = firstItem['mapx'] as String;
          final mapyString = firstItem['mapy'] as String;
          final parsedMapx = double.parse(mapxString) / 1e7;
          final parsedMapy = double.parse(mapyString) / 1e7;

          var searchResponse =
              await Api().client.searchStore(item, parsedMapy, parsedMapx);
          var storeList = searchResponse.storeList;
          print("${searchResponse.storeList}");
          setState(() {
            storeCards = storeList;
          });
        } else {
          // items가 비어있는 경우 예외 처리
          print('검색 결과가 없습니다.');
          setState(() {
            storeCards = [];
          });
        }

        // StoreCardList storeList = searchResponse.storeList;
        // print("검색결과 ${storeList}");
      } else {
        // 에러 처리
        print('에러: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('예외 발생: $e');
    }
  }
}
