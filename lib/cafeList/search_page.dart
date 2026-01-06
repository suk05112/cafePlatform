import 'package:flutter/material.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<StoreCard> storeCards = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  String? _currentQuery;
  int? _nextCursor;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 스크롤이 하단에 가까워지면 다음 페이지 로드
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && _currentQuery != null) {
        _loadMoreStores();
      }
    }
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
      _currentQuery = query;
      _nextCursor = null;
      _hasMore = false;
      storeCards = [];
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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: storeCards.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 로딩 인디케이터 표시
        if (index == storeCards.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        cleanedUrl,
        width: width,
        height: height,
        fit: BoxFit.cover, // 비율 유지하면서 컨테이너 채우기
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
      ),
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
            SizedBox(
              width: 120,
              height: 120,
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
                            storeCard.store_address ?? '위치 정보 없음',
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

  Future<void> searchStore(String query) async {
    try {
      // cursor는 null로 첫 페이지 요청, limit은 10 사용
      final searchResponse =
          await Api().client.searchStoreByQuery(query, null, 10);
      final storeList = searchResponse.store;
      print("검색 결과: ${storeList.length}개");

      if (searchResponse.pagination != null) {
        final pagination = searchResponse.pagination!;
        print(
            "페이지네이션 정보 - has_next: ${pagination.has_next}, next_cursor: ${pagination.next_cursor}");

        if (mounted) {
          setState(() {
            storeCards = storeList;
            _nextCursor = pagination.next_cursor;
            _hasMore = pagination.has_next;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            storeCards = storeList;
            _nextCursor = null;
            _hasMore = false;
          });
        }
      }
    } catch (e) {
      print('검색 API 오류: $e');
      if (mounted) {
        setState(() {
          storeCards = [];
          _nextCursor = null;
          _hasMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreStores() async {
    if (_currentQuery == null || _nextCursor == null || _isLoadingMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final searchResponse = await Api()
          .client
          .searchStoreByQuery(_currentQuery!, _nextCursor, 10);
      final storeList = searchResponse.store;
      print("추가 검색 결과: ${storeList.length}개");

      if (searchResponse.pagination != null) {
        final pagination = searchResponse.pagination!;
        print(
            "추가 페이지네이션 정보 - has_next: ${pagination.has_next}, next_cursor: ${pagination.next_cursor}");

        if (mounted) {
          setState(() {
            storeCards.addAll(storeList);
            _nextCursor = pagination.next_cursor;
            _hasMore = pagination.has_next;
            _isLoadingMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            storeCards.addAll(storeList);
            _nextCursor = null;
            _hasMore = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      print('추가 검색 API 오류: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }
}
