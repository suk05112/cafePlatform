import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/region.dart';
import 'package:cafeplatform/store_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';

class CafeListMapView extends StatefulWidget {
  const CafeListMapView({super.key});

  @override
  State<CafeListMapView> createState() => _CafeListMapViewState();
}

class _CafeListMapViewState extends State<CafeListMapView> {
  final ValueNotifier<Store?> _selectedStore = ValueNotifier<Store?>(null);
  late NaverMapController _mapController;
  NMarker? _activeMarker;
  final Map<String, NMarker> _markers = {}; // store_id -> marker 매핑
  bool _permissionRequested = false;
  bool _isSearching = false; // 현위치 검색 중인지 여부
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

  NLatLng? _initialTarget;

  @override
  void initState() {
    super.initState();
    _requestPermissionOnEnter();
    // 초기 타겟 설정은 한 번만 수행
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final storeProvider =
            Provider.of<StoreProvider>(context, listen: false);
        final storesForMap = _effectiveStores(storeProvider);
        _initialTarget = await _resolveInitialTarget(storesForMap);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _selectedStore.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CafeListMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // 유효한 좌표인지 검증 (한국 지역 범위)
  bool _isValidCoordinate(double lat, double lng) {
    // 한국 위도 범위: 약 33~38.6
    // 한국 경도 범위: 약 124~132
    return lat >= 33.0 && lat <= 38.6 && lng >= 124.0 && lng <= 132.0;
  }

  NLatLng _getValidInitialTarget(List<Store> stores) {
    // _initialTarget이 있고 유효하면 사용
    if (_initialTarget != null &&
        _isValidCoordinate(
            _initialTarget!.latitude, _initialTarget!.longitude)) {
      return _initialTarget!;
    }

    // 매장 리스트에서 유효한 좌표 찾기
    for (final store in stores) {
      if (_isValidCoordinate(store.store_lat, store.store_lng)) {
        return NLatLng(store.store_lat, store.store_lng);
      }
    }

    // 모두 유효하지 않으면 기본 위치 (서울시청)
    return const NLatLng(37.5665, 126.9780);
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final storesForMap = _effectiveStores(storeProvider);

    // 유효한 좌표를 가진 초기 타겟 계산
    final initialTarget = _getValidInitialTarget(storesForMap);

    print(
        'build: initialTarget = ${initialTarget.latitude}, ${initialTarget.longitude}');
    print('build: _initialTarget = $_initialTarget');
    print('build: storesForMap.length = ${storesForMap.length}');
    if (storesForMap.isNotEmpty) {
      print(
          'build: 첫 번째 매장 좌표 = ${storesForMap.first.store_lat}, ${storesForMap.first.store_lng}');
    }

    // // Provider 데이터가 변경되면 마커 업데이트 (중복 방지)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted && !_isDisposed && mapControllerCompleter.isCompleted) {
    //     _updateMarkersDebounced();
    //   }
    // });

    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            indoorEnable: false,
            locationButtonEnable: true,
            scrollGesturesEnable: true,
            consumeSymbolTapEvents: true,
            initialCameraPosition: NCameraPosition(
              target: initialTarget,
              zoom: 13,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
          ),
          onMapReady: (controller) {
            _mapController = controller;
            final markers = <NMarker>[];
            for (final store in storesForMap) {
              final marker = NMarker(
                id: store.store_id.toString(),
                position: NLatLng(store.store_lat, store.store_lng),
              );
              marker.setIcon(NOverlayImage.fromAssetImage('assets/pin.png'));
              _markers[store.store_id.toString()] = marker;
              marker.setOnTapListener((overlay) {
                if (_selectedStore.value?.store_id == store.store_id) {
                  _clearSelection();
                } else {
                  _updateMarkerSelection(overlay, store);
                }
              });
              markers.add(marker);
            }
            if (markers.isNotEmpty) {
              controller.addOverlayAll(markers.toSet());
            }
          },
          onMapTapped: (point, latLng) {
            _clearSelection();
          },
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 140),
              child: _buildLocationSearchButton2(),
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

    /*Stack(
      children: [
        NaverMap(
          key: const ValueKey('naver_map'), // 고정된 key로 불필요한 재생성 방지
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: initialTarget,
              zoom: 13,
            ),
            indoorEnable: true,
            locationButtonEnable: true,
            nightModeEnable: false, // 야간 모드 비활성화
            liteModeEnable: false, // 라이트 모드 비활성화
          ),
          onMapReady: (controller) async {
            print('onMapReady: 지도 준비 완료');
            // if (!mounted || _isDisposed) return;
            _mapController = controller;
            // if (mapControllerCompleter.isCompleted == false) {
            //   mapControllerCompleter.complete(controller);
            // }

            // 지도가 준비된 후 현재 카메라 위치 확인
            try {
              final cameraPosition = await controller.getCameraPosition();
              print(
                  'onMapReady: 현재 카메라 위치 = ${cameraPosition.target.latitude}, ${cameraPosition.target.longitude}, zoom = ${cameraPosition.zoom}');
            } catch (e) {
              print('onMapReady: 카메라 위치 가져오기 오류: $e');
            }

            final marker =
                NMarker(id: 'test', position: NLatLng(37.514784, 126.945148));
            controller.addOverlay(marker);

            final marker1 =
                NMarker(id: 'test1', position: NLatLng(37.514784, 126.945142));
            controller.addOverlay(marker1);

/*
            if (mounted && !_isDisposed) {
              try {
                // 아이콘이 초기화되지 않았으면 초기화 대기
                if (_defaultIcon == null || _selectedIcon == null) {
                  print('onMapReady: 아이콘 초기화 대기 중...');
                  // 아이콘 초기화가 완료될 때까지 대기
                  for (int i = 0; i < 30; i++) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (_defaultIcon != null && _selectedIcon != null) {
                      print('onMapReady: 아이콘 초기화 완료');
                      break;
                    }
                    if (!mounted || _isDisposed) return;
                  }
                }

                // onMapReady에서는 마커가 이미 있으면 추가하지 않음
                if (!_isUpdatingMarkers) {
                  print('onMapReady: 마커 추가 시작, 매장 개수: ${storesForMap.length}');
                  await _mapController.clearOverlays();
                  // await _addMarkers(_mapController, storesForMap);

                  print('onMapReady: 마커 추가 완료');
                }

                // 마커가 있으면 카메라를 마커 위치로 이동
                if (storesForMap.isNotEmpty) {
                  // 유효한 좌표를 가진 매장만 필터링
                  final validStores = storesForMap
                      .where((store) =>
                          _isValidCoordinate(store.store_lat, store.store_lng))
                      .toList();

                  if (validStores.isNotEmpty) {
                    double sumLat = 0;
                    double sumLng = 0;
                    int count = 0;
                    for (final store in validStores) {
                      sumLat += store.store_lat;
                      sumLng += store.store_lng;
                      count++;
                    }
                    if (count > 0) {
                      final centerLat = sumLat / count;
                      final centerLng = sumLng / count;

                      print('onMapReady: 마커 중심 위치 = $centerLat, $centerLng');

                      // 카메라를 마커 중심으로 이동 (약간의 딜레이 후)
                      Future.delayed(Duration(milliseconds: 500), () async {
                        if (mounted && !_isDisposed) {
                          try {
                            await controller.updateCamera(
                              NCameraUpdate.withParams(
                                target: NLatLng(centerLat, centerLng),
                                zoom: 13,
                              ),
                            );
                            print('onMapReady: 카메라를 마커 중심으로 이동 완료');
                          } catch (e) {
                            print('onMapReady: 카메라 이동 오류: $e');
                          }
                        }
                      });
                    }
                  } else {
                    // 유효한 매장이 없으면 서울로 이동
                    print('onMapReady: 유효한 매장 좌표가 없어 서울로 이동');
                    Future.delayed(Duration(milliseconds: 500), () async {
                      if (mounted && !_isDisposed) {
                        try {
                          await controller.updateCamera(
                            NCameraUpdate.withParams(
                              target: const NLatLng(37.5665, 126.9780),
                              zoom: 13,
                            ),
                          );
                          print('onMapReady: 서울로 카메라 이동 완료');
                        } catch (e) {
                          print('onMapReady: 서울 카메라 이동 오류: $e');
                        }
                      }
                    });
                  }
                } else {
                  // 마커가 없으면 초기 타겟으로 카메라 이동
                  if (_initialTarget != null) {
                    Future.delayed(Duration(milliseconds: 500), () async {
                      if (mounted && !_isDisposed) {
                        try {
                          await controller.updateCamera(
                            NCameraUpdate.withParams(
                              target: _initialTarget!,
                              zoom: 13,
                            ),
                          );
                          print('onMapReady: 초기 타겟으로 카메라 이동 완료');
                        } catch (e) {
                          print('onMapReady: 초기 타겟 카메라 이동 오류: $e');
                        }
                      }
                    });
                  }
                }
              } catch (e) {
                print('onMapReady 마커 추가 오류: $e');
                print('스택 트레이스: ${StackTrace.current}');
              }
            }
            */
          },
          onSymbolTapped: (_) => _clearSelection(),
          onMapTapped: (_, __) => _clearSelection(),
        ),
        // 현위치에서 검색 버튼 (하단 배치)
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 140), // 하단 카드 위에 배치 (위로 올림)
              child: _buildLocationSearchButton2(),
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

    */
  }

  List<Store> _effectiveStores(StoreProvider storeProvider) {
    // 검색된 매장이 있으면 우선 표시
    if (_searchedStores.isNotEmpty) return _searchedStores;
    // Provider에서 지도 뷰 전용 데이터 가져오기
    if (storeProvider.mapViewStores != null &&
        storeProvider.mapViewStores!.isNotEmpty) {
      return storeProvider.mapViewStores!;
    }
    return _dummyStores;
  }

  Future<NLatLng> _resolveInitialTarget(List<Store> stores) async {
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final availableRegions = storeProvider.availableRegions;
      final selectedRegionCode = storeProvider.selectedRegionCode;

      // 1. 매장이 존재하는 지역이 있으면 그 지역 마커 보여주기
      if (stores.isNotEmpty) {
        // 매장들의 중심점 계산
        double sumLat = 0;
        double sumLng = 0;
        int count = 0;
        for (final store in stores) {
          sumLat += store.store_lat;
          sumLng += store.store_lng;
          count++;
        }
        return NLatLng(sumLat / count, sumLng / count);
      }

      // 위치 권한 확인
      bool hasLocationPermission = false;
      double? gpsLat;
      double? gpsLng;

      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            hasLocationPermission = false;
          } else {
            hasLocationPermission = true;
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            gpsLat = position.latitude;
            gpsLng = position.longitude;
          }
        }
      } catch (e) {
        print('위치 권한 확인 오류: $e');
        hasLocationPermission = false;
      }

      // 위치 권한이 있는 경우
      if (hasLocationPermission && gpsLat != null && gpsLng != null) {
        // 6. 위치권한 있고, gps위치에 매장 있으면 gps위치 보여주기
        try {
          await Api().setBaseClient(Api.BASE_URL);
          final response =
              await Api().client.getStoreListByLocation(gpsLat, gpsLng);
          if (response.store.isNotEmpty) {
            print('GPS 위치에 매장 있음, GPS 위치 표시');
            return NLatLng(gpsLat, gpsLng);
          }
        } catch (e) {
          print('GPS 위치 매장 확인 오류: $e');
        }

        // 5. 위치권한 있고, gps위치에 매장 없으면
        // 5-2. 매장 존재하는 다른 지역 보여주기(regioncode 적은 지역)
        if (availableRegions.isNotEmpty) {
          // region_code가 가장 작은 지역 선택
          final sortedRegions = List<Region>.from(availableRegions)
            ..sort((a, b) => a.region_code.compareTo(b.region_code));

          for (final region in sortedRegions) {
            if (region.districts?.isNotEmpty == true) {
              try {
                final districtCode = region.districts!.first.district_code;
                await Api().setBaseClient(Api.BASE_URL);
                final response = await Api()
                    .client
                    .getStoreListByDistrict(districtCode, 0, 1);
                if (response.store.isNotEmpty) {
                  // 매장이 있는 지역의 첫 번째 매장 위치 반환
                  print('매장 존재하는 지역 찾음: ${region.region_name}');
                  final store = response.store.first;
                  return NLatLng(store.store_lat, store.store_lng);
                }
              } catch (e) {
                print('지역별 매장 확인 오류: $e');
                continue;
              }
            }
          }
        }

        // 5-1. 전체지역에 매장 없으면 gps위치 보여주기
        print('전체 지역에 매장 없음, GPS 위치 표시');
        return NLatLng(gpsLat, gpsLng);
      }

      // 위치 권한이 없는 경우
      // 3. 위치권한 없고, 존재하는 지역 1개면 그 지역 보여주기
      if (availableRegions.length == 1) {
        final region = availableRegions.first;
        if (region.districts?.isNotEmpty == true) {
          try {
            final districtCode = region.districts!.first.district_code;
            await Api().setBaseClient(Api.BASE_URL);
            final response =
                await Api().client.getStoreListByDistrict(districtCode, 0, 1);
            if (response.store.isNotEmpty) {
              print('지역 1개에 매장 있음: ${region.region_name}');
              final store = response.store.first;
              return NLatLng(store.store_lat, store.store_lng);
            }
          } catch (e) {
            print('지역 1개 매장 확인 오류: $e');
          }
        }
      }

      // 4. 위치권한 없고, 존재하는 지역 여러개면 regioncode 지역 보여주기
      if (availableRegions.length > 1 && selectedRegionCode != null) {
        Region? selectedRegion;
        try {
          selectedRegion = availableRegions.firstWhere(
            (r) => r.region_code == selectedRegionCode,
          );
        } catch (e) {
          selectedRegion = availableRegions.first;
        }
        if (selectedRegion.districts?.isNotEmpty == true) {
          try {
            final districtCode = selectedRegion.districts!.first.district_code;
            await Api().setBaseClient(Api.BASE_URL);
            final response =
                await Api().client.getStoreListByDistrict(districtCode, 0, 1);
            if (response.store.isNotEmpty) {
              print('선택된 지역에 매장 있음: ${selectedRegion.region_name}');
              final store = response.store.first;
              return NLatLng(store.store_lat, store.store_lng);
            }
          } catch (e) {
            print('선택된 지역 매장 확인 오류: $e');
          }
        }
      }

      // 2. 위치권한 없고, 존재하는 매장도 없으면 기본위치 서울
      print('기본 위치 서울 표시');
      return const NLatLng(37.5665, 126.9780);
    } catch (e) {
      print('_resolveInitialTarget 오류: $e');
      // 오류 발생 시 기본 위치
      if (stores.isNotEmpty) {
        final store = stores.first;
        return NLatLng(store.store_lat, store.store_lng);
      }
      return const NLatLng(37.5665, 126.9780);
    }
  }

  void _addMarkersSimple(NaverMapController controller, List<Store> stores) {
    final markers = <NMarker>[];
    for (final store in stores) {
      final marker = NMarker(
        id: store.store_id.toString(),
        position: NLatLng(store.store_lat, store.store_lng),
      );
      marker.setIcon(NOverlayImage.fromAssetImage('assets/pin.png'));
      _markers[store.store_id.toString()] = marker;
      marker.setOnTapListener((overlay) {
        if (_selectedStore.value?.store_id == store.store_id) {
          _clearSelection();
        } else {
          _updateMarkerSelection(overlay, store);
        }
      });
      markers.add(marker);
    }
    if (markers.isNotEmpty) {
      controller.addOverlayAll(markers.toSet());
    }
  }

  Future<void> _addMarkers2(
      NaverMapController controller, List<Store> stores) async {
    final validStores = stores
        .where((store) => _isValidCoordinate(store.store_lat, store.store_lng))
        .toList();
    for (final store in validStores) {
      final marker = NMarker(
        id: store.store_id.toString(),
        position: NLatLng(store.store_lat, store.store_lng),
      );

      marker.setIcon(NOverlayImage.fromAssetImage('assets/pin.png'));
      _markers[store.store_id.toString()] = marker;

      marker.setOnTapListener((overlay) {
        if (_selectedStore.value?.store_id == store.store_id) {
          _clearSelection();
        } else {
          _updateMarkerSelection(overlay, store);
        }
      });

      await controller.addOverlay(marker);
    }
  }

  Future<void> _addMarkers(
      NaverMapController controller, List<Store> stores) async {
    if (stores.isEmpty) return;

    final validStores = stores
        .where((store) => _isValidCoordinate(store.store_lat, store.store_lng))
        .toList();

    for (final store in validStores) {
      final marker = NMarker(
        id: store.store_id.toString(),
        position: NLatLng(store.store_lat, store.store_lng),
      );

      marker.setIcon(NOverlayImage.fromAssetImage('assets/pin.png'));
      _markers[store.store_id.toString()] = marker;

      marker.setOnTapListener((overlay) {
        if (_selectedStore.value?.store_id == store.store_id) {
          _clearSelection();
        } else {
          _updateMarkerSelection(overlay, store);
        }
      });

      await controller.addOverlay(marker);
    }
  }

  void _updateMarkerSelection(NMarker selectedMarker, Store store) {
    // 이전 선택된 마커를 기본 아이콘으로 변경
    if (_activeMarker != null) {
      _activeMarker!.setIcon(NOverlayImage.fromAssetImage('assets/pin.png'));
    }
    // 새로 선택된 마커를 selected_pin 아이콘으로 변경
    selectedMarker
        .setIcon(NOverlayImage.fromAssetImage('assets/selected_pin.png'));
    _activeMarker = selectedMarker;
    _selectedStore.value = store;
  }

  void _clearSelection() {
    if (_activeMarker != null) {
      _activeMarker!.setIcon(NOverlayImage.fromAssetImage('assets/pin.png'));
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

  Widget _buildLocationSearchButton2() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isSearching
            ? null
            : () async {
                setState(() {
                  _isSearching = true;
                });
                try {
                  final cameraPosition =
                      await _mapController.getCameraPosition();
                  final centerLat = cameraPosition.target.latitude;
                  final centerLng = cameraPosition.target.longitude;

                  await Api().setBaseClient(Api.BASE_URL);
                  final response = await Api().client.getStoreListByLocation(
                        centerLat,
                        centerLng,
                      );
                  final validStores = response.store
                      .where((store) =>
                          _isValidCoordinate(store.store_lat, store.store_lng))
                      .toList();

                  if (validStores.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('주변에 매장이 없습니다.'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    }
                    return;
                  }

                  await _mapController.clearOverlays();
                  _markers.clear();
                  await _addMarkers(_mapController, validStores);
                  _searchedStores = validStores;

                  // 검색 결과가 있으면 첫 번째 매장 위치로 카메라 이동
                  if (validStores.isNotEmpty) {
                    final firstStore = validStores.first;
                    await _mapController.updateCamera(
                      NCameraUpdate.withParams(
                        target:
                            NLatLng(firstStore.store_lat, firstStore.store_lng),
                        zoom: 15,
                      ),
                    );
                  }
                } catch (e) {
                  print('현위치 검색 버튼 클릭 오류: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('검색 중 오류가 발생했습니다.'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSearching = false;
                    });
                  }
                }
              },
        icon: _isSearching
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.my_location, size: 18, color: Colors.white),
        label: Text(
          _isSearching ? '검색 중...' : '현위치에서 검색',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFE7831),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFFE7831).withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSearchButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.my_location, size: 18),
      label: const Text(
        '현위치에서 검색',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () async {
        try {
          final cameraPosition = await _mapController.getCameraPosition();
          final centerLat = cameraPosition.target.latitude;
          final centerLng = cameraPosition.target.longitude;

          if (!_isValidCoordinate(centerLat, centerLng)) {
            await _mapController.updateCamera(
              NCameraUpdate.withParams(
                target: const NLatLng(37.5665, 126.9780),
                zoom: 13,
              ),
            );
            return;
          }

          await Api().setBaseClient(Api.BASE_URL);
          final response = await Api().client.getStoreListByLocation(
                centerLat,
                centerLng,
              );

          _searchedStores = response.store;

          final validStores = response.store
              .where((store) =>
                  _isValidCoordinate(store.store_lat, store.store_lng))
              .toList();

          if (validStores.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('주변에 매장이 없습니다.'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          await _mapController.clearOverlays();
          await _addMarkers(_mapController, validStores);

          if (validStores.isNotEmpty) {
            double minLat = validStores.first.store_lat;
            double maxLat = validStores.first.store_lat;
            double minLng = validStores.first.store_lng;
            double maxLng = validStores.first.store_lng;

            for (final store in validStores) {
              if (store.store_lat < minLat) minLat = store.store_lat;
              if (store.store_lat > maxLat) maxLat = store.store_lat;
              if (store.store_lng < minLng) minLng = store.store_lng;
              if (store.store_lng > maxLng) maxLng = store.store_lng;
            }

            final boundsCenterLat = (minLat + maxLat) / 2;
            final boundsCenterLng = (minLng + maxLng) / 2;

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
                target: NLatLng(boundsCenterLat, boundsCenterLng),
                zoom: zoom,
              ),
            );
          }

          final storeProvider =
              Provider.of<StoreProvider>(context, listen: false);
          storeProvider.setMapViewStores(validStores);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('지도 중심 위치 주변 매장 ${validStores.length}개를 찾았습니다.'),
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (error) {
          print("지도 중심 위치 검색 오류: $error");
        }
      },
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
