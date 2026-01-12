import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:cafeplatform/dummyData.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:cafeplatform/Payment/select_gift_type_page.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StorePage extends StatefulWidget {
  StorePage({super.key, required this.storeId, required this.storeName});

  int storeId;
  String storeName;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Store? store;
  late Future<Store?> futureStore;

  @override
  void initState() {
    super.initState();
    // 초기화 메서드 호출
    _initializeStoreData();
    // 메뉴 데이터 로드
    if (widget.storeId >= 0) {
      Provider.of<MenuProvider>(context, listen: false)
          .fetchMenuList(widget.storeId);
    }
  }

  Future<void> _initializeStoreData() async {
    print("_initializeStoreData 호출");

    if (widget.storeId < 0) {
      setState(() {
        store = StoreDummyRepository.stores.firstWhere(
            (s) => s?.store_id == widget.storeId,
            orElse: () => StoreDummyRepository.stores[0]);
      });
      return;
    }
    // 비동기 데이터 로드
    futureStore = Provider.of<StoreProvider>(context, listen: false)
        .fetchDetailStore(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: "",
      ),
      body: widget.storeId < 0
          ? _buildStoreContent(store)
          : FutureBuilder<Store?>(
              future: futureStore,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print(
                      "FutureBuilder - snapshot.connectionState: ${snapshot.connectionState}");
                  return Container(
                    color: Colors.white,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  print("FutureBuilder - snapshot.hasError: ${snapshot.error}");
                  return _buildStoreContent(store);
                } else if (snapshot.hasData) {
                  print(
                      "FutureBuilder - snapshot.hasData: ${snapshot.hasData}");
                  print(
                      "FutureBuilder - snapshot.data: ${snapshot.data?.store_address}");
                  print(
                      "FutureBuilder - snapshot.data 전체: ${snapshot.data?.toJson()}");
                  return _buildStoreContent(snapshot.data);
                } else {
                  print("FutureBuilder - snapshot.else: ${snapshot.error}");
                  return Container(
                    color: Colors.white,
                    child: Center(child: Text("기프티콘 읽어오기 실패")),
                  );
                }
              }),
    );
  }

  Widget _buildStoreContent(Store? storeData) {
    // 디버깅: storeData 확인
    if (storeData != null) {
      print("_buildStoreContent - store_address: ${storeData.store_address}");
      print(
          "_buildStoreContent - store_lat: ${storeData.store_lat}, store_lng: ${storeData.store_lng}");
    }
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 매장사진 (스와이프)
            StoreImageSlider(
              key: ValueKey('store_image_slider_${storeData?.store_id ?? 0}'),
              store: storeData,
            ),
            // 매장명과 설명
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 매장명
                  Text(
                    widget.storeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  // 매장설명
                  if (storeData?.store_description != null &&
                      (storeData?.store_description ?? '').isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      storeData!.store_description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 4),
            // 매장 정보
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    "매장 정보",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey[300]),
                  SizedBox(height: 8),
                  // 주소
                  _buildCompactInfoRow(
                    icon: Icons.location_on,
                    text: (storeData?.store_address != null &&
                            storeData!.store_address.isNotEmpty)
                        ? storeData.store_address
                        : "주소 정보 없음",
                  ),
                  SizedBox(height: 6),
                  // 전화번호
                  _buildCompactInfoRow(
                    icon: Icons.phone,
                    text: storeData?.store_telephone ?? "전화번호 정보 없음",
                  ),
                  SizedBox(height: 6),
                  // 매장위치 (클릭 가능)
                  GestureDetector(
                    onTap: () {
                      final lat = storeData?.store_lat ?? 0;
                      final lng = storeData?.store_lng ?? 0;
                      print("지도에서 보기 클릭: lat=$lat, lng=$lng");
                      if (lat != 0 && lng != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoreMapPage(
                              latitude: lat,
                              longitude: lng,
                              storeName: widget.storeName,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "지도에서 보기",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // 메뉴리스트
            _buildMenuSection(storeData),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(Store? storeData) {
    if (widget.storeId < 0) {
      final menuList = MenuDummyRepository.menus;
      if (menuList.isEmpty) {
        return SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "메뉴",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Divider(height: 1, color: Colors.grey[300]),
                SizedBox(height: 8),
              ],
            ),
          ),
          SizedBox(height: 8),
          _buildMenuGrid(menuList),
        ],
      );
    } else {
      return Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          List<Menu> menuList = menuProvider.menuCards ?? [];
          print("실 데이터 menuList.isNotEmpty: ${menuList.isNotEmpty}"
              "${menuList.length}");
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "메뉴",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(height: 1, color: Colors.grey[300]),
                    SizedBox(height: 2),
                  ],
                ),
              ),
              SizedBox(height: 2),
              _buildMenuGrid(menuList),
            ],
          );
        },
      );
    }
  }

  Widget _buildMenuGrid(List<Menu> menuList) {
    if (menuList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Text(
            "등록된 메뉴가 없습니다",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    print("_buildMenuGrid: ${menuList.isNotEmpty}" "${menuList[0]}");

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: menuList.length,
      itemBuilder: (context, index) => _buildMenuCard(menuList[index]),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    final hasImage =
        menu.menu_image_url != null && menu.menu_image_url!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // store_id가 0이거나 유효하지 않은 경우 widget.storeId로 설정
        if (menu.store_id <= 0 && widget.storeId > 0) {
          menu.store_id = widget.storeId;
          print('store_id 수정: ${menu.store_id} (menu_id: ${menu.menu_id})');
        }
        Provider.of<MenuProvider>(context, listen: false).setSelectedMenu(menu);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectGiftPage(menu: menu),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    menu.name ?? '메뉴명 없음',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${_formatPrice(menu.price)}원',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (hasImage) ...[
              SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (menu.menu_image_url != null &&
                        menu.menu_image_url!.isNotEmpty)
                    ? Image.network(
                        menu.menu_image_url!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 80,
                            height: 80,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("메뉴 이미지 로드 오류: $error");
                          return const SizedBox.shrink();
                        },
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 매장 이미지 슬라이더 위젯
class StoreImageSlider extends StatefulWidget {
  final Store? store;

  const StoreImageSlider({super.key, required this.store});

  @override
  _StoreImageSliderState createState() => _StoreImageSliderState();
}

class _StoreImageSliderState extends State<StoreImageSlider> {
  bool isLoadingImages = true;
  List<File> images = [];
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    // 기존 이미지 초기화
    images = [];
    isLoadingImages = true;
    _initializeStoreData();
  }

  @override
  void didUpdateWidget(StoreImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 매장이 변경되면 이미지 다시 로드
    if (oldWidget.store?.store_id != widget.store?.store_id) {
      setState(() {
        images = [];
        isLoadingImages = true;
      });
      _initializeStoreData();
    }
  }

  Future<void> _initializeStoreData() async {
    final fetchedImages = await _loadImages();
    if (mounted) {
      setState(() {
        images = fetchedImages;
        isLoadingImages = false;
      });
    }
  }

  Future<List<File>> _loadImages() async {
    print("_loadImages ${widget.store?.store_id}");
    List<String> storePhotoUrls;
    final storeId = widget.store?.store_id ?? 0;

    if (widget.store != null && widget.store!.store_id < 0) {
      // 더미 데이터인 경우에도 빈 리스트 반환 (기본 이미지 1장만 표시)
      storePhotoUrls = [];
    } else {
      // 실제 매장 사진 URL이 있으면 사용, 없으면 빈 리스트
      storePhotoUrls = widget.store?.store_photo_urls ?? [];
      // store_photo_urls가 비어있거나 모든 URL이 유효하지 않은 경우 빈 리스트 유지
      storePhotoUrls = storePhotoUrls.where((url) => url.isNotEmpty).toList();
    }

    print(":: $storePhotoUrls");

    // 사진이 없으면 빈 리스트 반환 (build에서 기본 이미지 표시)
    if (storePhotoUrls.isEmpty) {
      return [];
    }

    List<File> images = [];
    await Future.wait(storePhotoUrls.asMap().entries.map((e) async {
      var idx = e.key;
      var url = e.value;
      try {
        images.add(await getImageFileFromUrl(url, storeId, idx));
      } catch (e) {
        print("이미지 로드 실패: $url, 오류: $e");
        // 이미지 로드 실패 시 해당 이미지는 제외
      }
    }));
    return images;
  }

  Future<File> getImageFileFromUrl(
      String imageUrl, int storeId, int idx) async {
    final tempDir = await getTemporaryDirectory();

    // 매장 ID와 인덱스를 포함한 고유한 파일명 생성 (타임스탬프 없이 고정 이름 사용)
    final fileName = 'store_${storeId}_image_${idx}.png';
    final tempFile = File('${tempDir.path}/$fileName');

    // 기존 파일이 있으면 유효성 검사
    if (await tempFile.exists()) {
      try {
        // 파일 크기가 0이 아니고, 읽을 수 있는지 확인
        final fileSize = await tempFile.length();
        if (fileSize > 0) {
          // 이미지 파일인지 간단히 확인 (PNG 시그니처 체크)
          final bytes = await tempFile.readAsBytes();
          if (bytes.length >= 8 &&
              bytes[0] == 0x89 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x4E &&
              bytes[3] == 0x47) {
            // 유효한 PNG 파일인 것 같음
            return tempFile;
          }
        }
        // 유효하지 않은 파일이면 삭제
        print('손상된 이미지 파일 발견, 삭제 후 다시 다운로드: ${tempFile.path}');
        await tempFile.delete();
      } catch (e) {
        // 파일 읽기 실패 시 삭제 후 다시 다운로드
        print('이미지 파일 유효성 검사 실패, 삭제 후 다시 다운로드: $e');
        try {
          await tempFile.delete();
        } catch (_) {
          // 삭제 실패는 무시
        }
      }
    }

    // 파일이 없거나 손상된 경우 새로 다운로드
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // 빈 바이트 배열이 아닌지 확인
        if (bytes.isNotEmpty) {
          await tempFile.writeAsBytes(bytes);
          return tempFile;
        } else {
          throw Exception('빈 이미지 데이터');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 다운로드 실패: $imageUrl, 오류: $e');
      rethrow;
    }
  }

  Widget imageSlider(image, int index) {
    try {
      return Container(
        width: double.infinity,
        height: 240,
        color: Colors.white,
        child: Image.file(
          File(image.path),
          key: ValueKey('${widget.store?.store_id}_${image.path}_$index'),
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("이미지 로드 오류: $error, 파일: ${image.path}");
            // 손상된 파일 삭제 시도 (비동기이지만 결과는 기다리지 않음)
            try {
              File(image.path).delete().then((_) {
                print('손상된 이미지 파일 삭제 완료: ${image.path}');
              }).catchError((e) {
                print('파일 삭제 실패: $e');
              });
            } catch (e) {
              print('파일 삭제 시도 중 오류: $e');
            }

            // AssetImage로 대체
            return Image(
              image: const AssetImage('assets/coffee.jpeg'),
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Asset 이미지도 실패하면 빈 컨테이너 반환
                return Container(
                  width: double.infinity,
                  height: 240,
                  color: Colors.grey[200],
                );
              },
            );
          },
        ),
      );
    } catch (e) {
      print("이미지 슬라이더 오류: $e");
      // 전체적으로 실패하면 빈 컨테이너 반환
      return Container(
        width: double.infinity,
        height: 240,
        color: Colors.grey[200],
      );
    }
  }

  Widget indicator(length) => Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      alignment: Alignment.bottomCenter,
      child: AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: length,
        effect: JumpingDotEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withOpacity(0.6)),
      ));

  @override
  Widget build(BuildContext context) {
    if (isLoadingImages) {
      return Container(
        width: double.infinity,
        height: 240,
        color: Colors.grey[200],
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 240,
        color: Colors.grey,
        child: Image(
          image: AssetImage('assets/coffee.jpeg'),
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
        ),
      );
    } else if (images.length == 1) {
      // 이미지가 한 장일 때는 스와이프 비활성화
      return imageSlider(images[0], 0);
    } else {
      // 이미지가 여러 장일 때만 CarouselSlider 사용
      return Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        CarouselSlider.builder(
          options: CarouselOptions(
            initialPage: 0,
            viewportFraction: 1,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) => setState(() {
              activeIndex = index;
            }),
          ),
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            final path = images[index];
            return imageSlider(path, index);
          },
        ),
        Align(
            alignment: Alignment.bottomCenter, child: indicator(images.length))
      ]);
    }
  }
}

// 지도 전용 화면
class StoreMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String storeName;

  const StoreMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "매장위치",
      ),
      body: NaverMapWidget(
        latitude: latitude,
        longitude: longitude,
        fullScreen: true,
      ),
    );
  }
}

class NaverMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool fullScreen;

  const NaverMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.fullScreen = false,
  });

  @override
  _NaverMapWidgetState createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget>
    with AutomaticKeepAliveClientMixin {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  bool _isMapReady = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _isDisposed = true;
    // 지도 컨트롤러 정리
    if (_isMapReady && mapControllerCompleter.isCompleted) {
      try {
        _mapController.dispose();
      } catch (e) {
        print('NaverMapWidget dispose 오류 (무시 가능): $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항

    if (widget.fullScreen) {
      return NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(widget.latitude, widget.longitude),
            zoom: 15,
          ),
          indoorEnable: true,
          locationButtonEnable: true,
          consumeSymbolTapEvents: false,
        ),
        onMapReady: (controller) async {
          if (_isMapReady || _isDisposed) return;
          _isMapReady = true;

          if (_isDisposed) return;
          _mapController = controller;
          if (!mapControllerCompleter.isCompleted) {
            mapControllerCompleter.complete(controller);
          }

          if (_isDisposed) return;
          // 마커 추가
          final marker = NMarker(
            id: 'store',
            position: NLatLng(widget.latitude, widget.longitude),
          );
          marker.setIcon(NOverlayImage.fromAssetImage("assets/pin.png"));
          controller.addOverlay(marker);

          print("Naver Map is ready.");
        },
      );
    } else {
      return Container(
          margin: EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height / 4,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(widget.latitude, widget.longitude),
                    zoom: 13,
                  ),
                  indoorEnable: true,
                  locationButtonEnable: true,
                  consumeSymbolTapEvents: false,
                ),
                onMapReady: (controller) async {
                  if (_isMapReady || _isDisposed) return;
                  _isMapReady = true;

                  if (_isDisposed) return;
                  _mapController = controller;
                  if (!mapControllerCompleter.isCompleted) {
                    mapControllerCompleter.complete(controller);
                  }

                  if (_isDisposed) return;
                  // 마커 추가
                  final marker = NMarker(
                    id: 'store',
                    position: NLatLng(widget.latitude, widget.longitude),
                  );
                  marker
                      .setIcon(NOverlayImage.fromAssetImage("assets/pin.png"));
                  controller.addOverlay(marker);

                  print("Naver Map is ready.");
                },
              )));
    }
  }
}
