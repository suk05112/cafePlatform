import 'dart:async';

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
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Figma StorePage (1695:1372) — 타이포·색·메뉴 카드·구분 바
class _StoreFigma {
  static const Color textPrimary = Color(0xFF121217);
  static const Color textMuted = Color(0xFF6B6B73);
  static const Color textBody = Color(0xFF3B3B42);
  static const Color menuTitle = Color(0xFF17171C);
  static const Color divider = Color(0xFFE3E3ED);
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
  bool _storeLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.storeId < 0) {
      store = StoreDummyRepository.stores.firstWhere(
          (s) => s?.store_id == widget.storeId,
          orElse: () => StoreDummyRepository.stores[0]);
    } else {
      _loadStore();
      Provider.of<MenuProvider>(context, listen: false)
          .fetchMenuList(widget.storeId);
    }
  }

  Future<void> _loadStore() async {
    setState(() => _storeLoading = true);
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final loaded = await storeProvider.fetchDetailStore(widget.storeId);
      if (!mounted) return;
      // 슬라이더 표시 전 모든 이미지 캐시 완료 후 setState
      final urls = (loaded?.store_photo_urls ?? []).where((u) => u.isNotEmpty);
      await Future.wait(
        urls.map((url) => precacheImage(NetworkImage(url), context).catchError((_) {})),
      );
      if (!mounted) return;
      setState(() {
        store = loaded;
        _storeLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _storeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: ""),
      body: _storeLoading && store == null
          ? const Center(child: CircularProgressIndicator(color: ColorAssset.mainColor))
          : _buildStoreContent(store),
    );
  }

  Widget _buildStoreContent(Store? storeData) {
    // 디버깅: storeData 확인
    if (storeData != null) {
    }
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 매장사진 (스와이프)
            StoreImageSlider(
              key: ValueKey('store_image_slider_${widget.storeId}'),
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
class _StoreImagePlaceholder extends StatelessWidget {
  final double height;
  const _StoreImagePlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE0CC), Color(0xFFFFC5A0), Color(0xFFFFAB7B)],
        ),
      ),
      child: Stack(
        children: [
          // 배경 원형 장식
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // 중앙 아이콘 + 텍스트
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_cafe_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '매장 사진 준비 중',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoreImageSlider extends StatefulWidget {
  final Store? store;

  const StoreImageSlider({super.key, required this.store});

  @override
  _StoreImageSliderState createState() => _StoreImageSliderState();
}

class _StoreImageSliderState extends State<StoreImageSlider> {
  int _activeIndex = 0;
  List<String>? _frozenUrls;

  List<String> get _urls {
    if (_frozenUrls != null) return _frozenUrls!;
    if (widget.store == null || widget.store!.store_id < 0) return [];
    final urls = (widget.store!.store_photo_urls ?? [])
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isNotEmpty) _frozenUrls = urls;
    return urls;
  }

  Widget _imageSlide(String url, int index) {
    return Image.network(
      url,
      key: ValueKey('${widget.store?.store_id}_$index'),
      width: double.infinity,
      height: _StoreFigma.sliderHeight,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) =>
          _StoreImagePlaceholder(height: _StoreFigma.sliderHeight),
    );
  }

  Widget _indicator(int count) => Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        alignment: Alignment.bottomCenter,
        child: AnimatedSmoothIndicator(
          activeIndex: _activeIndex,
          count: count,
          effect: JumpingDotEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final urls = _urls;

    if (urls.isEmpty) {
      return _StoreImagePlaceholder(height: _StoreFigma.sliderHeight);
    }

    if (urls.length == 1) {
      return SizedBox(
        width: double.infinity,
        height: _StoreFigma.sliderHeight,
        child: _imageSlide(urls[0], 0),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            height: _StoreFigma.sliderHeight,
            viewportFraction: 1,
            enlargeCenterPage: false,
            onPageChanged: (index, _) =>
                setState(() => _activeIndex = index),
          ),
          itemCount: urls.length,
          itemBuilder: (_, index, __) => _imageSlide(urls[index], index),
        ),
        _indicator(urls.length),
      ],
    );
  }
}
