import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:cafeplatform/cafeList/cafe_list_map_view.dart';
import 'package:cafeplatform/cafeList/search_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/region.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/widget/network_aware_widget.dart';
import 'package:provider/provider.dart';

class CafeList extends StatefulWidget {
  const CafeList({super.key});

  @override
  State<CafeList> createState() => _CafeListState();
}

class _CafeListState extends State<CafeList>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedRegionCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      // 처음에는 "01"로 호출
      try {
        final response = await Api().client.getStoreListByDistrict("01");
        storeProvider.setStoreCard(response.store);
      } catch (error) {
        print("초기 매장 로드 오류: $error");
        await storeProvider.fetchStoreList();
      }
      storeProvider.fetchAvailableRegions();
    });
  }

  void _refreshData() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final response = await Api().client.getStoreListByDistrict("01");
        storeProvider.setStoreCard(response.store);
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
    final stores = List<Store>.from(storeProvider.storeCards ?? []);
    final selectedRegionCode =
        storeProvider.selectedRegionCode ?? _selectedRegionCode;

    final filteredStores = _filterStores(stores, selectedRegionCode);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NetworkAwareWidget(
          onRetry: _refreshData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildRegionAndSearchRow()),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: crashtest,
                          icon: const Icon(Icons.bug_report, size: 20),
                          tooltip: '크래시 테스트',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '카페 ${filteredStores.length}개',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                indicatorWeight: 3,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '리스트로 보기'),
                  Tab(text: '지도로 보기'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStoreList(filteredStores),
                    CafeListMapView(
                      key: ValueKey(
                          filteredStores.map((e) => e.store_id).join()),
                      storeList: filteredStores,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> crashtest() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Crashlytics 사용자 정보 및 커스텀 키 설정
    await FirebaseCrashlytics.instance.setCustomKey("test_key", "test_value");
    await FirebaseCrashlytics.instance.setUserIdentifier("test_user");

    // 테스트용 로그 기록
    await FirebaseCrashlytics.instance.log("크래시 로깅 테스트 시작");
    print("crashtest 호출");
    // String? testString = null;
    // print(testString!);

    FirebaseCrashlytics.instance.crash();

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

  Widget _buildRegionAndSearchRow() {
    final storeProvider = context.watch<StoreProvider>();
    final availableRegions = storeProvider.availableRegions;
    final selectedRegionCode =
        storeProvider.selectedRegionCode ?? _selectedRegionCode;
    final selectedRegion = availableRegions.firstWhere(
      (r) => r.region_code == selectedRegionCode,
      orElse: () => Region(region_name: '전체 지역', region_code: ''),
    );

    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: (regionCode) async {
            if (regionCode.isEmpty) {
              // 전체 지역 선택
              setState(() {
                _selectedRegionCode = null;
              });
              storeProvider.setSelectedRegionCode(null);
              // 전체 매장 다시 로드
              await storeProvider.fetchStoreList();
            } else {
              // 특정 지역 선택 - district_code로 API 호출
              setState(() {
                _selectedRegionCode = regionCode;
              });
              storeProvider.setSelectedRegionCode(regionCode);
              try {
                final selectedRegion = availableRegions.firstWhere(
                  (r) => r.region_code == regionCode,
                );
                // region의 첫 번째 district_code 사용
                final districtCode =
                    selectedRegion.districts?.isNotEmpty == true
                        ? selectedRegion.districts!.first.district_code
                        : regionCode; // district가 없으면 region_code 사용

                final response =
                    await Api().client.getStoreListByDistrict(districtCode);
                storeProvider.setStoreCard(response.store);
              } catch (error) {
                print("지역별 매장 로드 오류: $error");
              }
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 8,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.place_outlined, size: 18),
            label: Text(
              selectedRegionCode == null || selectedRegionCode.isEmpty
                  ? '전체 지역'
                  : selectedRegion.region_name,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: '',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: selectedRegionCode == null ||
                              selectedRegionCode.isEmpty
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '전체 지역',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selectedRegionCode == null ||
                                selectedRegionCode.isEmpty
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selectedRegionCode == null ||
                                selectedRegionCode.isEmpty
                            ? Colors.black87
                            : Colors.black87,
                      ),
                    ),
                    if (selectedRegionCode == null ||
                        selectedRegionCode.isEmpty) ...[
                      const Spacer(),
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ...availableRegions.map((region) => PopupMenuItem<String>(
                  value: region.region_code,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: selectedRegionCode == region.region_code
                              ? Colors.black87
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            region.region_name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  selectedRegionCode == region.region_code
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (selectedRegionCode == region.region_code) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchPage()),
              );
            },
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: ColorAssset.grey4,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: ColorAssset.grey5),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '매장명, 동네 이름으로 검색하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ColorAssset.grey5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreList(List<Store> stores) {
    if (stores.isEmpty) {
      return const Center(
        child: Text(
          '선택한 지역에 매장이 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // 세로 공간을 조금 더 넉넉하게 주어 카드 내용이 넘치지 않도록 조정
          childAspectRatio: 0.7,
          mainAxisSpacing: 18,
          crossAxisSpacing: 12,
        ),
        itemCount: stores.length,
        itemBuilder: (_, index) => _StoreCard(store: stores[index]),
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

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final Store store;

  String _getStoreImageUrl() {
    // 로고 URL이 있으면 로고 사용
    String? logoUrl = store.store_logo.trim();
    if (logoUrl.isNotEmpty &&
        (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
      return logoUrl;
    }
    
    // 로고가 없으면 매장 사진의 첫 번째 이미지 사용
    if (store.store_photo_urls.isNotEmpty) {
      String? photoUrl = store.store_photo_urls[0].trim();
      if (photoUrl.isNotEmpty &&
          (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
        return photoUrl;
      }
    }
    
    // 둘 다 없으면 빈 문자열 반환 (기본 이미지 사용)
    return '';
  }

  Widget _buildStoreImage(String imageUrl) {
    // URL 검증 및 정리
    final cleanedUrl = imageUrl.trim();

    // URL이 비어있거나 유효하지 않은 경우
    if (cleanedUrl.isEmpty ||
        (!cleanedUrl.startsWith('http://') &&
            !cleanedUrl.startsWith('https://'))) {
      return Image.asset(
        'assets/coffee.jpeg',
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      cleanedUrl,
      fit: BoxFit.cover,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame != null) return child;
        // 프레임이 null이면 로딩 중이거나 에러
        return Container(
          color: Colors.grey[200],
          child: Image.asset(
            'assets/coffee.jpeg',
            fit: BoxFit.cover,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('이미지 로드 오류: $error, URL: $cleanedUrl');
        print('스택 트레이스: $stackTrace');
        return Image.asset(
          'assets/coffee.jpeg',
          fit: BoxFit.cover,
        );
      },
      // 캐시 최적화
      cacheWidth: 800,
      cacheHeight: 450,
      // 이미지 형식 검증 비활성화 (일부 서버의 경우 필요)
      filterQuality: FilterQuality.medium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StorePage(
              storeId: store.store_id,
              storeName: store.store_name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildStoreImage(_getStoreImageUrl()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.store_name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.store_address,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store.store_description.isNotEmpty
                        ? store.store_description
                        : '특별한 커피와 디저트를 즐겨보세요.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
