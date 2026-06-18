import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cafeplatform/dummyData.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:cafeplatform/Payment/select_gift_type_page.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/widget/store_map_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Figma StorePage (1695:1372) — 타이포·색·메뉴 카드·구분 바
class _StoreFigma {
  static const Color textPrimary = Color(0xFF121217);
  static const Color textMuted = Color(0xFF6B6B73);
  static const Color textBody = Color(0xFF3B3B42);
  static const Color menuTitle = Color(0xFF17171C);
  static const Color divider = Color(0xFFE3E3ED);
  static const Color sliderPlaceholder = Color(0xFFE0E3ED);
  static const Color menuImagePlaceholder = Color(0xFFE5E8ED);
  static const Color sectionBar = Color(0xFFF5F6FA);
  static const double horizontalInset = 16;
  static const double sliderHeight = 251;
}

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
    if (widget.storeId < 0) {
      store = StoreDummyRepository.stores.firstWhere(
          (s) => s?.store_id == widget.storeId,
          orElse: () => StoreDummyRepository.stores[0]);
    } else {
      futureStore = Provider.of<StoreProvider>(context, listen: false)
          .fetchDetailStore(widget.storeId);
      Provider.of<MenuProvider>(context, listen: false)
          .fetchMenuList(widget.storeId);
    }
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
                    child: const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor)),
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
              padding: const EdgeInsets.fromLTRB(
                _StoreFigma.horizontalInset,
                16,
                _StoreFigma.horizontalInset,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.storeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _StoreFigma.textPrimary,
                      height: 1.22,
                    ),
                  ),
                  if (storeData?.store_description != null &&
                      (storeData?.store_description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      storeData!.store_description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _StoreFigma.textMuted,
                        height: 1.21,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 매장 정보
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _StoreFigma.horizontalInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "매장 정보",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _StoreFigma.textPrimary,
                      height: 1.21,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _storeInfoIconRow(
                    icon: Icons.location_on_outlined,
                    iconColor: _StoreFigma.textMuted,
                    child: Text(
                      (storeData != null &&
                              storeData.store_address.isNotEmpty)
                          ? storeData.store_address
                          : "주소 정보 없음",
                      style: TextStyle(
                        fontSize: 13,
                        color: storeData != null &&
                                storeData.store_address.isNotEmpty
                            ? _StoreFigma.textBody
                            : _StoreFigma.textMuted,
                        height: 1.21,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _storeInfoIconRow(
                    icon: Icons.phone_outlined,
                    iconColor: _StoreFigma.textMuted,
                    child: Text(
                      (storeData != null &&
                              storeData.store_telephone.isNotEmpty)
                          ? storeData.store_telephone
                          : "전화번호 정보 없음",
                      style: TextStyle(
                        fontSize: 13,
                        color: storeData != null &&
                                storeData.store_telephone.isNotEmpty
                            ? _StoreFigma.textBody
                            : _StoreFigma.textMuted,
                        height: 1.21,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final lat = storeData?.store_lat ?? 0;
                      final lng = storeData?.store_lng ?? 0;
                      if (lat != 0 && lng != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => StoreMapPage(
                              latitude: lat,
                              longitude: lng,
                              storeName: widget.storeName,
                            ),
                          ),
                        );
                      }
                    },
                    child: _storeInfoIconRow(
                      icon: Icons.map_outlined,
                      iconColor: ColorAssset.mainColor,
                      child: Text(
                        "지도에서 보기",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorAssset.mainColor,
                          height: 1.21,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 14,
              width: double.infinity,
              color: _StoreFigma.sectionBar,
            ),
            // 메뉴리스트
            _buildMenuSection(storeData),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _storeInfoIconRow({
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
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
            padding: const EdgeInsets.fromLTRB(
              _StoreFigma.horizontalInset,
              16,
              _StoreFigma.horizontalInset,
              8,
            ),
            child: const Text(
              "메뉴",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _StoreFigma.textPrimary,
                height: 1.21,
              ),
            ),
          ),
          _buildMenuGrid(menuList, null),
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
                padding: const EdgeInsets.fromLTRB(
                  _StoreFigma.horizontalInset,
                  16,
                  _StoreFigma.horizontalInset,
                  8,
                ),
                child: const Text(
                  "메뉴",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _StoreFigma.textPrimary,
                    height: 1.21,
                  ),
                ),
              ),
              if (menuProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor)),
                )
              else
                _buildMenuGrid(menuList, storeData),
            ],
          );
        },
      );
    }
  }

  Widget _buildMenuGrid(List<Menu> menuList, Store? storeData) {
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuList.length,
      itemBuilder: (context, index) => _buildMenuCard(
        menuList[index],
        storeData,
        showBottomDivider: index < menuList.length - 1,
      ),
    );
  }

  Widget _buildMenuCard(
    Menu menu,
    Store? storeData, {
    required bool showBottomDivider,
  }) {
    final hasImage =
        menu.menu_image_url != null && menu.menu_image_url!.trim().isNotEmpty;
    final desc = menu.description?.trim();
    final hasDesc = desc != null && desc.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (menu.store_id <= 0 && widget.storeId > 0) {
            menu.store_id = widget.storeId;
            print('store_id 수정: ${menu.store_id} (menu_id: ${menu.menu_id})');
          }
          Provider.of<MenuProvider>(context, listen: false).setSelectedMenu(menu);

          final Store? forExchange = storeData;
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => SelectGiftPage(
                menu: menu,
                contextStoreId: widget.storeId > 0 ? widget.storeId : null,
                exchangeAddress: forExchange?.store_address,
                exchangeLat: forExchange?.store_lat,
                exchangeLng: forExchange?.store_lng,
                exchangePlaceName: (forExchange?.store_name.isNotEmpty == true)
                    ? forExchange!.store_name
                    : widget.storeName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _StoreFigma.horizontalInset,
                12,
                _StoreFigma.horizontalInset,
                12,
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            menu.name ?? '메뉴명 없음',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: _StoreFigma.menuTitle,
                              height: 1.21,
                            ),
                          ),
                          if (hasDesc) ...[
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: _StoreFigma.menuTitle,
                                height: 1.21,
                              ),
                            ),
                          ],
                          const SizedBox(height: 9),
                          Text(
                            '${_formatPrice(menu.price)}원',
                            style: TextStyle(
                              color: ColorAssset.mainColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.21,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasImage
                          ? Image.network(
                              menu.menu_image_url!.trim(),
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 85,
                                  height: 85,
                                  color: _StoreFigma.menuImagePlaceholder,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ColorAssset.mainColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 85,
                                  height: 85,
                                  color: _StoreFigma.menuImagePlaceholder,
                                );
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
                          : Container(
                              width: 85,
                              height: 85,
                              color: _StoreFigma.menuImagePlaceholder,
                            ),
                    ),
                  ],
                ),
            ),
            if (showBottomDivider)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _StoreFigma.horizontalInset,
                ),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: _StoreFigma.divider,
                ),
              ),
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
        height: _StoreFigma.sliderHeight,
        color: Colors.white,
        child: Image.file(
          File(image.path),
          key: ValueKey('${widget.store?.store_id}_${image.path}_$index'),
          width: double.infinity,
          height: _StoreFigma.sliderHeight,
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
              height: _StoreFigma.sliderHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Asset 이미지도 실패하면 빈 컨테이너 반환
                return Container(
                  width: double.infinity,
                  height: _StoreFigma.sliderHeight,
                  color: _StoreFigma.sliderPlaceholder,
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
        height: _StoreFigma.sliderHeight,
        color: _StoreFigma.sliderPlaceholder,
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
            dotColor: Colors.white.withValues(alpha: 0.6)),
      ));

  @override
  Widget build(BuildContext context) {
    if (isLoadingImages) {
      return Container(
        width: double.infinity,
        height: _StoreFigma.sliderHeight,
        color: _StoreFigma.sliderPlaceholder,
        child: const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor)),
      );
    } else if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: _StoreFigma.sliderHeight,
        color: _StoreFigma.sliderPlaceholder,
        child: Image(
          image: const AssetImage('assets/coffee.jpeg'),
          width: double.infinity,
          height: _StoreFigma.sliderHeight,
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
