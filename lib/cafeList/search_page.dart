import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/cafeList/cafe_list_map_view.dart';
import 'package:cafeplatform/cafeList/region_picker_sheet.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/region.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/utils/store_distance.dart';

/// Figma: 검색 전용 (1683:1533) — 흰 배경, 지역·검색·지도·결과 리스트
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
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
  double _refLat = kDefaultReferenceLatitude;
  double _refLng = kDefaultReferenceLongitude;

  static const Color _pageBg = Colors.white;
  static const Color _searchFill = Color(0xFFFAFAFA);
  static const Color _searchBorder = Color(0xFFEEEEEE);
  static const Color _hintColor = Color(0xFF9F9F9F);
  static const Color _titleColor = Color(0xFF333333);
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resolveDistanceReferencePoint().then((ref) {
        if (!mounted) return;
        setState(() {
          _refLat = ref.$1;
          _refLng = ref.$2;
        });
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && _currentQuery != null) {
        _loadMoreStores();
      }
    }
  }

  String _regionLabel(StoreProvider storeProvider) {
    final code = storeProvider.selectedRegionCode;
    if (code == null || code.isEmpty) return '전체';
    for (final Region r in storeProvider.availableRegions) {
      if (r.region_code == code) return r.region_name;
    }
    return '지역';
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    color: Colors.black87,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => showStoreRegionPickerBottomSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '현재 지역',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _regionLabel(storeProvider),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          size: 20, color: Colors.grey.shade700),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _buildSearchField()),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(Icons.map_outlined,
                          color: Colors.grey.shade800, size: 26),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const CafeListMapView(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasSearched && storeCards.isEmpty
                      ? _buildEmptyState()
                      : storeCards.isEmpty
                          ? _buildInitialState()
                          : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: _searchFill,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _searchBorder),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
          color: _titleColor,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: '매장명, 메뉴명으로 검색해보세요',
          hintStyle: const TextStyle(
            color: _hintColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade600, size: 20),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _performSearch(value.trim());
          }
        },
      ),
    );
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
          Icon(Icons.search_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            '매장·메뉴를 검색해보세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '상단 검색창에 키워드를 입력하면 목록이 표시됩니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
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
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '다른 검색어로 다시 시도해 보세요',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      itemCount: storeCards.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (index == storeCards.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _DiscoveryStoreRow(
          storeCard: storeCards[index],
          refLat: _refLat,
          refLng: _refLng,
          buildImage: _buildStoreImage,
          onTap: () {
            final c = storeCards[index];
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => StorePage(
                  storeId: c.store_id,
                  storeName: c.store_name,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStoreImage(String imageUrl, double width, double height) {
    final cleanedUrl = imageUrl.trim();

    if (cleanedUrl.isEmpty ||
        (!cleanedUrl.startsWith('http://') &&
            !cleanedUrl.startsWith('https://'))) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: Icon(
          Icons.storefront_outlined,
          size: width > height ? height * 0.45 : width * 0.45,
          color: Colors.white70,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        cleanedUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
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
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: Icon(
            Icons.storefront_outlined,
            size: width * 0.45,
            color: Colors.white70,
          ),
        ),
        cacheWidth: width.toInt(),
        cacheHeight: height.toInt(),
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Future<void> searchStore(String query) async {
    try {
      final searchResponse =
          await Api().client.searchStoreByQuery(query, null, 10);
      final storeList = searchResponse.store;

      if (searchResponse.pagination != null) {
        final pagination = searchResponse.pagination!;
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

      if (searchResponse.pagination != null) {
        final pagination = searchResponse.pagination!;
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

class _DiscoveryStoreRow extends StatelessWidget {
  const _DiscoveryStoreRow({
    required this.storeCard,
    required this.refLat,
    required this.refLng,
    required this.buildImage,
    required this.onTap,
  });

  final StoreCard storeCard;
  final double refLat;
  final double refLng;
  final Widget Function(String url, double w, double h) buildImage;
  final VoidCallback onTap;

  static const Color _titleColor = Color(0xFF333333);
  static const Color _subtitleColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final desc = (storeCard.store_description != null &&
            storeCard.store_description!.trim().isNotEmpty)
        ? storeCard.store_description!.trim()
        : (storeCard.store_address ?? '위치 정보 없음');

    final showOpenBadge =
        storeCard.open_yn != null && storeCard.open_yn!.toUpperCase() == 'Y';

    final distanceLabel = storeDistanceLabel(
      refLat,
      refLng,
      storeCard.store_lat,
      storeCard.store_lng,
    );

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: buildImage(
                            storeCard.store_logo,
                            100,
                            100,
                          ),
                        ),
                        if (showOpenBadge)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    ColorAssset.mainColor.withValues(alpha: 0.95),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'OPEN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeCard.store_name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _titleColor,
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _subtitleColor,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (distanceLabel != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distanceLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFFEEEEEE),
            ),
          ],
        ),
      ),
    );
  }
}
