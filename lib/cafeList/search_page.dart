import 'package:flutter/material.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<StoreCard> storeCards = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(title: "매장검색"),
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // 검색바 영역
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "매장명으로 검색",
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        storeCards = [];
                                        _hasSearched = false;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(fontSize: 15),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _performSearch(value.trim());
                            }
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            _performSearch(_searchController.text.trim());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // 검색 결과 영역
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _hasSearched && storeCards.isEmpty
                        ? _buildEmptyState()
                        : storeCards.isEmpty
                            ? _buildInitialState()
                            : _buildSearchResults(),
              ),
            ],
          ),
        ));
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    searchStore(query).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "매장명을 검색해보세요",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "원하는 카페를 찾아보세요",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "검색 결과가 없습니다",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "다른 검색어로 시도해보세요",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: storeCards.length,
      itemBuilder: (context, index) {
        final storeCard = storeCards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StoreCardWidget(storeCard),
        );
      },
    );
  }

  Widget _buildStoreImage(String imageUrl, double width, double height) {
    // URL 검증 및 정리
    final cleanedUrl = imageUrl.trim();

    // URL이 비어있거나 유효하지 않은 경우
    if (cleanedUrl.isEmpty ||
        (!cleanedUrl.startsWith('http://') &&
            !cleanedUrl.startsWith('https://'))) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[100],
        child: Icon(
          Icons.storefront,
          size: width > height ? height * 0.6 : width * 0.6,
          color: Colors.grey[400],
        ),
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
          child: Container(
            width: width,
            height: height,
            color: Colors.grey[100],
            child: Icon(
              Icons.storefront,
              size: width > height ? height * 0.6 : width * 0.6,
              color: Colors.grey[400],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('이미지 로드 오류: $error, URL: $cleanedUrl');
        print('스택 트레이스: $stackTrace');
        return Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: Icon(
            Icons.storefront,
            size: width > height ? height * 0.6 : width * 0.6,
            color: Colors.grey[400],
          ),
        );
      },
      // 캐시 최적화
      cacheWidth: width.toInt(),
      cacheHeight: height.toInt(),
      filterQuality: FilterQuality.medium,
    );
  }

  Widget StoreCardWidget(StoreCard? storeCard) {
    if (storeCard == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StorePage(
              storeId: storeCard.store_id,
              storeName: storeCard.store_name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 매장 이미지
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: _buildStoreImage(storeCard.store_logo, 120, 120),
            ),
            // 매장 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      storeCard.store_name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '위치 정보',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 화살표 아이콘
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
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
