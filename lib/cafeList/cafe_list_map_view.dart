import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';

class CafeListMapView extends StatefulWidget {
  const CafeListMapView({super.key, required this.storeList});

  final List<Store> storeList;

  @override
  State<CafeListMapView> createState() => _CafeListMapViewState();
}

class _CafeListMapViewState extends State<CafeListMapView> {
  final ValueNotifier<Store?> _selectedStore = ValueNotifier<Store?>(null);
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  NMarker? _activeMarker;
  NOverlayImage? _defaultIcon;
  NOverlayImage? _selectedIcon;
  bool _permissionRequested = false;
  List<Store> _searchedStores = []; // 검색된 매장 리스트
  final List<Store> _dummyStores = [
    Store(
      store_id: 201,
      store_name: "시청 더블샷",
      store_address: "서울특별시 중구 세종대로 110",
      store_lat: 37.5663,
      store_lng: 126.9779,
      store_description: "서울 도심이 내려다보이는 스페셜티 카페",
      store_logo: "",
    ),
    Store(
      store_id: 202,
      store_name: "강남 브랜치",
      store_address: "서울특별시 강남구 테헤란로 231",
      store_lat: 37.5013,
      store_lng: 127.0396,
      store_description: "바리스타 챔피언이 상주하는 라운지",
      store_logo: "",
    ),
    Store(
      store_id: 203,
      store_name: "성수 한강뷰",
      store_address: "서울특별시 성동구 왕십리로 83",
      store_lat: 37.5430,
      store_lng: 127.0550,
      store_description: "루프탑에서 즐기는 디저트와 드립커피",
      store_logo: "",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissionOnEnter();
    // 작은 크기의 핀 아이콘 초기화 (비동기)
    _initIcons();
  }

  Future<void> _initIcons() async {
    if (!mounted) return;
    // 작은 크기의 핀 아이콘 생성 (30x40 픽셀)
    _defaultIcon = await NOverlayImage.fromWidget(
      context: context,
      widget: SizedBox(
        width: 30,
        height: 40,
        child: Image.asset('assets/pin.png', fit: BoxFit.contain),
      ),
      size: const Size(30, 40),
    );
    _selectedIcon = await NOverlayImage.fromWidget(
      context: context,
      widget: SizedBox(
        width: 30,
        height: 40,
        child: Image.asset('assets/selected_pin.png', fit: BoxFit.contain),
      ),
      size: const Size(30, 40),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant CafeListMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storeList.isEmpty) {
      _selectedStore.value = null;
    } else if (_selectedStore.value != null &&
        !widget.storeList.any(
          (element) => element.store_id == _selectedStore.value!.store_id,
        )) {
      _selectedStore.value = null;
    }
    // 매장 리스트가 변경되면 마커 업데이트
    if (oldWidget.storeList.length != widget.storeList.length ||
        oldWidget.storeList.map((e) => e.store_id).join() !=
            widget.storeList.map((e) => e.store_id).join()) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (!mapControllerCompleter.isCompleted) return;
    final storesForMap = _effectiveStores();
    await _mapController.clearOverlays();
    await _addMarkers(_mapController, storesForMap);
  }

  @override
  Widget build(BuildContext context) {
    final storesForMap = _effectiveStores();
    return FutureBuilder<NLatLng>(
      future: _resolveInitialTarget(storesForMap),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final initialTarget = snapshot.data ?? _fallbackTarget(storesForMap);

        return Stack(
          children: [
            NaverMap(
              key: ValueKey(storesForMap.map((e) => e.store_id).join()),
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: initialTarget,
                  zoom: 13,
                ),
                indoorEnable: true,
                locationButtonEnable: true,
              ),
              onMapReady: (controller) {
                _mapController = controller;
                _addMarkers(_mapController, storesForMap);
                if (mapControllerCompleter.isCompleted == false) {
                  mapControllerCompleter.complete(controller);
                }
              },
              onSymbolTapped: (_) => _clearSelection(),
              onMapTapped: (_, __) => _clearSelection(),
            ),
            // 현위치에서 검색 버튼
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildLocationSearchButton(),
                ),
              ),
            ),
            ValueListenableBuilder<Store?>(
              valueListenable: _selectedStore,
              builder: (_, store, __) {
                if (store == null) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomCard(store),
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<Store> _effectiveStores() {
    // 검색된 매장이 있으면 우선 표시
    if (_searchedStores.isNotEmpty) return _searchedStores;
    if (widget.storeList.isNotEmpty) return widget.storeList;
    return _dummyStores;
  }

  Future<NLatLng> _resolveInitialTarget(List<Store> stores) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackTarget(stores);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallbackTarget(stores);
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return NLatLng(position.latitude, position.longitude);
    } catch (_) {
      return _fallbackTarget(stores);
    }
  }

  NLatLng _fallbackTarget(List<Store> stores) {
    if (stores.isNotEmpty) {
      final store = stores.first;
      return NLatLng(store.store_lat, store.store_lng);
    }
    // 서울시청 좌표
    return const NLatLng(37.5665, 126.9780);
  }

  Future<void> _addMarkers(
      NaverMapController controller, List<Store> stores) async {
    for (final store in stores) {
      final marker = NMarker(
        id: store.store_id.toString(),
        position: NLatLng(store.store_lat, store.store_lng),
      );

      marker.setOnTapListener((overlay) {
        if (_selectedStore.value?.store_id == store.store_id) {
          _clearSelection();
        } else {
          _selectedStore.value = store;
          if (_activeMarker != null && _activeMarker != overlay) {
            _activeMarker!.setIcon(_defaultIcon ?? NOverlayImage.fromAssetImage('assets/pin.png'));
          }
          overlay.setIcon(_selectedIcon ?? NOverlayImage.fromAssetImage('assets/selected_pin.png'));
          _activeMarker = overlay;
        }
      });

      marker.setIcon(_defaultIcon ?? NOverlayImage.fromAssetImage('assets/pin.png'));
      controller.addOverlay(marker);
    }
  }

  void _clearSelection() {
    if (_activeMarker != null) {
      _activeMarker!.setIcon(_defaultIcon ?? NOverlayImage.fromAssetImage('assets/pin.png'));
      _activeMarker = null;
    }
    _selectedStore.value = null;
  }

  String _getStoreImageUrl(Store store) {
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
      fit: BoxFit.cover,
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
      errorBuilder: (context, error, stackTrace) {
        print('이미지 로드 오류: $error, URL: $cleanedUrl');
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
    );
  }

  Widget _buildBottomCard(Store store) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
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
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildStoreImage(_getStoreImageUrl(store), 60, 60),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.store_name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.store_address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissionOnEnter() async {
    if (_permissionRequested) return;
    _permissionRequested = true;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  Widget _buildLocationSearchButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.my_location, size: 18),
      onPressed: () async {
        try {
          // 지도 컨트롤러가 준비될 때까지 대기
          if (!mapControllerCompleter.isCompleted) {
            await mapControllerCompleter.future;
          }

          // 실제 GPS 위치 가져오기
          double? currentLat;
          double? currentLng;

          try {
            final serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              throw Exception('위치 서비스가 비활성화되어 있습니다.');
            }

            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
            }

            if (permission == LocationPermission.denied ||
                permission == LocationPermission.deniedForever) {
              throw Exception('위치 권한이 필요합니다.');
            }

            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            currentLat = position.latitude;
            currentLng = position.longitude;
          } catch (locationError) {
            print("위치 가져오기 오류: $locationError");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('현재 위치를 가져올 수 없습니다. 지도 중심 위치로 검색합니다.'),
                  duration: const Duration(seconds: 2),
                ),
              );
              // 위치를 가져올 수 없으면 지도 중심 좌표 사용
              final cameraPosition = await _mapController.getCameraPosition();
              currentLat = cameraPosition.target.latitude;
              currentLng = cameraPosition.target.longitude;
            }
          }

          if (currentLat == null || currentLng == null) {
            return;
          }

          // 현위치에서 검색 API 호출
          await Api().setBaseClient(Api.BASE_URL);
          final response = await Api().client.getStoreListByLocation(
                currentLat,
                currentLng,
              );

          // Provider에 매장 리스트 업데이트
          final storeProvider =
              Provider.of<StoreProvider>(context, listen: false);
          storeProvider.setStoreCard(response.store);

          // 검색된 매장 리스트 저장 및 마커 업데이트
          if (mounted) {
            setState(() {
              _searchedStores = response.store;
            });

            // 기존 마커 제거 후 새 마커 추가
            await _mapController.clearOverlays();
            await _addMarkers(_mapController, response.store);

            // 검색된 매장이 있으면 모든 매장이 보이도록 카메라 조정
            if (response.store.isNotEmpty) {
              // 모든 매장의 경계 계산
              double minLat = response.store.first.store_lat;
              double maxLat = response.store.first.store_lat;
              double minLng = response.store.first.store_lng;
              double maxLng = response.store.first.store_lng;

              for (final store in response.store) {
                if (store.store_lat < minLat) minLat = store.store_lat;
                if (store.store_lat > maxLat) maxLat = store.store_lat;
                if (store.store_lng < minLng) minLng = store.store_lng;
                if (store.store_lng > maxLng) maxLng = store.store_lng;
              }

              // 현위치도 포함하도록 경계 확장
              if (currentLat < minLat) minLat = currentLat;
              if (currentLat > maxLat) maxLat = currentLat;
              if (currentLng < minLng) minLng = currentLng;
              if (currentLng > maxLng) maxLng = currentLng;

              // 경계의 중심점 계산
              final centerLat = (minLat + maxLat) / 2;
              final centerLng = (minLng + maxLng) / 2;

              // 경계의 크기에 따라 줌 레벨 조정
              final latDiff = maxLat - minLat;
              final lngDiff = maxLng - minLng;
              final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

              double zoom = 14;
              if (maxDiff > 0.1) {
                zoom = 12;
              } else if (maxDiff > 0.05) {
                zoom = 13;
              } else if (maxDiff < 0.01) {
                zoom = 15;
              }

              await _mapController.updateCamera(
                NCameraUpdate.withParams(
                  target: NLatLng(centerLat, centerLng),
                  zoom: zoom,
                ),
              );
            } else {
              // 검색된 매장이 없으면 현위치로 이동
              await _mapController.updateCamera(
                NCameraUpdate.withParams(
                  target: NLatLng(currentLat, currentLng),
                  zoom: 14,
                ),
              );
            }
          }

          // 성공 메시지 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('현위치 주변 매장 ${response.store.length}개를 찾았습니다.'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (error) {
          print("현위치 검색 오류: $error");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('매장 검색에 실패했습니다: ${error.toString()}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      label: const Text(
        '현위치에서 검색',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
