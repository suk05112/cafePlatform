import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:cafeplatform/cafeList/cafe_list_map_view.dart';
import 'package:cafeplatform/cafeList/region_picker_sheet.dart';
import 'package:cafeplatform/cafeList/search_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/model/region.dart';
import 'package:cafeplatform/Payment/select_gift_type_page.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/widget/network_aware_widget.dart';
import 'package:cafeplatform/utils/store_distance.dart';
import 'package:provider/provider.dart';

// Figma discovery (1690:5323) — 메뉴 추천 API 연동 전 플레이스홀더
class _MenuRecPh {
  const _MenuRecPh({
    required this.menuName,
    required this.storeName,
    required this.priceLabel,
  });
  final String menuName;
  final String storeName;
  final String priceLabel;
}

const _kMenuRecPlaceholders = <_MenuRecPh>[
  _MenuRecPh(
    menuName: '아이스 아메리카노',
    storeName: '오쏘몰',
    priceLabel: '4,500원',
  ),
  _MenuRecPh(
    menuName: '카페라떼',
    storeName: '드롭탑',
    priceLabel: '5,000원',
  ),
  _MenuRecPh(
    menuName: '콜드브루',
    storeName: '비엔나커피',
    priceLabel: '4,800원',
  ),
];

class CafeList extends StatefulWidget {
  const CafeList({super.key});

  @override
  State<CafeList> createState() => _CafeListState();
}

class _CafeListState extends State<CafeList> {
  static const Color _pageBg = Colors.white;
  static const Color _searchFill = Color(0xFFFAFAFA);
  static const Color _searchBorder = Color(0xFFEEEEEE);
  static const Color _hintColor = Color(0xFF9F9F9F);
  static const Color _subtitleColor = Color(0xFF757575);

  String? _selectedRegionCode;
  final ScrollController _scrollController = ScrollController();
  double _refLat = kDefaultReferenceLatitude;
  double _refLng = kDefaultReferenceLongitude;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      storeProvider.resetPagination();
      // 처음에는 "01"로 호출
      try {
        await storeProvider.fetchListViewStoresByDistrict("01",
            cursor: null, limit: 10);
      } catch (error) {
        print("초기 매장 로드 오류: $error");
        await storeProvider.fetchStoreList();
      }
      storeProvider.fetchAvailableRegions();
    });
  }

  bool _storeNameMatches(Store s, String wantRaw) {
    final want = wantRaw.trim().toLowerCase();
    final name = s.store_name.trim().toLowerCase();
    if (want.isEmpty || name.isEmpty) return false;
    return name == want || name.contains(want) || want.contains(name);
  }

  bool _menuNameMatches(Menu m, String wantRaw) {
    final want = wantRaw.trim().toLowerCase();
    final name = (m.name ?? '').trim().toLowerCase();
    if (want.isEmpty || name.isEmpty) return false;
    return name == want || name.contains(want) || want.contains(name);
  }

  /// 플레이스홀더 매장·메뉴명으로 목록 매칭 후 선물하기(결제) 화면으로 이동
  Future<void> _onRecommendedMenuTap(_MenuRecPh item) async {
    final messenger = ScaffoldMessenger.of(context);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final stores = storeProvider.listViewStores ?? [];

    Store? matched;
    for (final s in stores) {
      if (_storeNameMatches(s, item.storeName)) {
        matched = s;
        break;
      }
    }

    if (matched == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('현재 목록에서 해당 매장을 찾을 수 없습니다.')),
      );
      return;
    }
    final store = matched;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    await menuProvider.fetchMenuList(store.store_id);
    if (!mounted) return;

    final menus = menuProvider.menuCards ?? [];
    Menu? picked;
    for (final m in menus) {
      if (_menuNameMatches(m, item.menuName)) {
        picked = m;
        break;
      }
    }

    if (picked == null) {
      if (menus.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('메뉴를 불러오지 못했습니다.')),
        );
        return;
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => StorePage(
            storeId: store.store_id,
            storeName: store.store_name,
          ),
        ),
      );
      return;
    }

    menuProvider.setSelectedMenu(picked);
    final detail = await storeProvider.fetchDetailStore(store.store_id);
    if (!mounted) return;

    final placeName = detail.store_name.isNotEmpty
        ? detail.store_name
        : store.store_name;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SelectGiftPage(
          menu: picked!,
          contextStoreId: store.store_id,
          exchangeAddress: detail.store_address,
          exchangeLat: detail.store_lat,
          exchangeLng: detail.store_lng,
          exchangePlaceName: placeName,
        ),
      ),
    );
  }

  void _onScroll() {
    // 스크롤 위치 확인
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;

    // 하단 200px 전에 도달하면 다음 페이지 로드
    final threshold = position.maxScrollExtent - 200;
    if (position.pixels >= threshold && position.pixels > 0) {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);

      // print(
      //     '스크롤 감지: pixels=${position.pixels}, maxScrollExtent=${position.maxScrollExtent}, threshold=$threshold');
      // print(
      //     '페이지네이션 상태: hasMore=${storeProvider.hasMore}, isLoadingMore=${storeProvider.isLoadingMore}, nextCursor=${storeProvider.nextCursor}');

      if (storeProvider.hasMore && !storeProvider.isLoadingMore) {
        // print('다음 페이지 로드 시작');
        storeProvider.loadMoreStores();
      }
      // else {
      //   print(
      //       '다음 페이지 로드 스킵: hasMore=${storeProvider.hasMore}, isLoadingMore=${storeProvider.isLoadingMore}');
      // }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshData() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.resetPagination();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await storeProvider.fetchListViewStoresByDistrict("01",
            cursor: null, limit: 10);
      } catch (error) {
        print("매장 로드 오류: $error");
        await storeProvider.fetchStoreList();
      }
      storeProvider.fetchAvailableRegions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    // 리스트 뷰는 독립적인 데이터 사용
    final listViewStores = List<Store>.from(storeProvider.listViewStores ?? []);
    final selectedRegionCode =
        storeProvider.selectedRegionCode ?? _selectedRegionCode;

    final filteredListViewStores =
        _filterStores(listViewStores, selectedRegionCode);

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: NetworkAwareWidget(
          onRetry: _refreshData,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildDiscoveryRegionRow(),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSearchAndMapRow(),
                      ),
                      const SizedBox(height: 20),
                      _buildMenuRecommendationSection(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '내 근처 매장 찾기',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121),
                                height: 1.2,
                              ),
                            ),
                            if (filteredListViewStores.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${filteredListViewStores.length}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filteredListViewStores.isEmpty && !storeProvider.isLoadingMore)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyStoreState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= filteredListViewStores.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final store = filteredListViewStores[index];
                        return _CafeDiscoveryStoreRow(
                          store: store,
                          refLat: _refLat,
                          refLng: _refLng,
                          buildImage: _buildStoreThumb,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => StorePage(
                                  storeId: store.store_id,
                                  storeName: store.store_name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredListViewStores.length +
                          (storeProvider.isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStoreState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              '등록된 매장이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '다른 지역을 선택하거나 잠시 후 다시 확인해 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '이런 메뉴는 어떠세요?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _kMenuRecPlaceholders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final m = _kMenuRecPlaceholders[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onRecommendedMenuTap(m),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 120,
                            height: 120,
                            color: const Color(0xFFBDBDBD),
                            child: Icon(
                              Icons.local_cafe_outlined,
                              size: 40,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.storeName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _subtitleColor,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          m.menuName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1F),
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          m.priceLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1F),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndMapRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SearchPage()),
              );
            },
            child: Container(
              height: 47,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _searchFill,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: _searchBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '매장명, 메뉴명으로 검색해보세요',
                      style: TextStyle(
                        color: _hintColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    );
  }

  Widget _buildStoreThumb(String imageUrl, double width, double height) {
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
        cacheWidth: width.toInt() * 2,
        cacheHeight: height.toInt() * 2,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Future<void> crashtest() async {
    try {
      // Crashlytics 사용자 정보 및 커스텀 키 설정
      await FirebaseCrashlytics.instance.setCustomKey("test_key", "test_value");
      await FirebaseCrashlytics.instance
          .setCustomKey("test_time", DateTime.now().toString());
      await FirebaseCrashlytics.instance.setUserIdentifier("test_user");

      // 테스트용 로그 기록
      await FirebaseCrashlytics.instance.log("크래시 로깅 테스트 시작");
      print("✅ Crashlytics 테스트 설정 완료");

      // 테스트 에러 기록 (크래시 없이)
      await FirebaseCrashlytics.instance.recordError(
        Exception("테스트 에러 - 크래시 없음"),
        StackTrace.current,
        reason: "Crashlytics 테스트",
        fatal: false,
      );

      print("✅ 테스트 에러가 Crashlytics에 기록되었습니다. Firebase 콘솔에서 확인하세요.");

      // 실제 크래시를 발생시키려면 아래 주석 해제 (앱이 종료됩니다)
      // await Future.delayed(const Duration(seconds: 2));
      // FirebaseCrashlytics.instance.crash();
    } catch (error, stackTrace) {
      print("❌ Crashlytics 테스트 오류: $error");
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: "Crashlytics 테스트 중 오류",
        fatal: false,
      );
    }

    try {
      // Crashlytics가 준비될 때까지 잠시 대기
      await Future.delayed(const Duration(milliseconds: 1000));

      // Crashlytics 사용자 정보 및 커스텀 키 설정
      await FirebaseCrashlytics.instance.setCustomKey("test_key", "test_value");
      await FirebaseCrashlytics.instance.setUserIdentifier("test_user");

      // 테스트용 로그 기록
      await FirebaseCrashlytics.instance.log("크래시 로깅 테스트 시작");

      print("크래시 로깅 테스트 준비 완료");

      // 실제 크래시를 테스트하려면 아래 주석을 해제하세요
      // 주의: 이 코드는 앱을 강제로 크래시시킵니다
      // FirebaseCrashlytics.instance.crash();

      // 또는 null assertion으로 크래시 발생 (자동으로 Crashlytics에 기록됨)
      String? testString;
      print(testString!); // 이 코드는 NullPointerException을 발생시켜 크래시를 만듭니다
    } catch (error, stackTrace) {
      print("crashtest error: $error");
      // 에러 발생 시 Crashlytics에 기록
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'crashtest 함수 실행 중 에러 발생',
          fatal: false,
        );
        print("에러가 Crashlytics에 기록되었습니다");
      } catch (crashlyticsError) {
        print("Crashlytics에 에러 기록 실패: $crashlyticsError");
      }
    }
  }

  Widget _buildDiscoveryRegionRow() {
    final storeProvider = context.watch<StoreProvider>();
    final availableRegions = storeProvider.availableRegions;
    final selectedRegionCode =
        storeProvider.selectedRegionCode ?? _selectedRegionCode;

    if (availableRegions.length == 1 && selectedRegionCode == null) {
      final singleRegionCode = availableRegions.first.region_code;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedRegionCode = singleRegionCode;
          });
          storeProvider.setSelectedRegionCode(singleRegionCode);
          final districtCode =
              availableRegions.first.districts?.isNotEmpty == true
                  ? availableRegions.first.districts!.first.district_code
                  : singleRegionCode;
          storeProvider.resetPagination();
          storeProvider.fetchListViewStoresByDistrict(districtCode,
              cursor: null, limit: 10);
        }
      });
    } else if (selectedRegionCode == null && availableRegions.isNotEmpty) {
      final firstRegionCode = availableRegions.first.region_code;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedRegionCode = firstRegionCode;
          });
          storeProvider.setSelectedRegionCode(firstRegionCode);
          final firstDistrictCode =
              availableRegions.first.districts?.isNotEmpty == true
                  ? availableRegions.first.districts!.first.district_code
                  : firstRegionCode;
          storeProvider.resetPagination();
          storeProvider.fetchListViewStoresByDistrict(firstDistrictCode,
              cursor: null, limit: 10);
        }
      });
    }

    final selectedRegion = availableRegions.firstWhere(
      (r) =>
          r.region_code ==
          (selectedRegionCode ??
              (availableRegions.isNotEmpty
                  ? availableRegions.first.region_code
                  : '')),
      orElse: () => availableRegions.isNotEmpty
          ? availableRegions.first
          : Region(region_name: '지역 선택', region_code: ''),
    );

    return InkWell(
      onTap: () => showStoreRegionPickerBottomSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: Text(
                selectedRegion.region_name,
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
    );
  }

  List<Store> _filterStores(List<Store> stores, String? selectedRegionCode) {
    if (selectedRegionCode == null || selectedRegionCode.isEmpty) {
      return stores;
    }
    // region_code로 필터링 (실제로는 API에서 이미 필터링된 결과를 받아오므로
    // 여기서는 추가 필터링이 필요 없을 수 있음)
    return stores;
  }
}

/// Figma discovery 리스트 행 (검색 화면 [_DiscoveryStoreRow]와 동일 톤)
class _CafeDiscoveryStoreRow extends StatelessWidget {
  const _CafeDiscoveryStoreRow({
    required this.store,
    required this.refLat,
    required this.refLng,
    required this.buildImage,
    required this.onTap,
  });

  final Store store;
  final double refLat;
  final double refLng;
  final Widget Function(String url, double w, double h) buildImage;
  final VoidCallback onTap;

  static const Color _rowTitleColor = Color(0xFF333333);
  static const Color _rowSubtitleColor = Color(0xFF757575);

  static String _imageUrl(Store store) {
    final logoUrl = store.store_logo.trim();
    if (logoUrl.isNotEmpty &&
        (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
      return logoUrl;
    }
    if (store.store_photo_urls.isNotEmpty) {
      final photoUrl = store.store_photo_urls[0].trim();
      if (photoUrl.isNotEmpty &&
          (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
        return photoUrl;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final desc = store.store_description.trim().isNotEmpty
        ? store.store_description.trim()
        : store.store_address;

    final showOpenBadge =
        store.open_yn != null && store.open_yn!.toUpperCase() == 'Y';

    final distanceLabel = storeDistanceLabel(
      refLat,
      refLng,
      store.store_lat,
      store.store_lng,
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
                          child: buildImage(_imageUrl(store), 100, 100),
                        ),
                        if (showOpenBadge)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ColorAssset.mainColor
                                    .withValues(alpha: 0.95),
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
                          store.store_name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _rowTitleColor,
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
                            color: _rowSubtitleColor,
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
                                Icons.location_on_outlined,
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
