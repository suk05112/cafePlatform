import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:my_app/model/Store.dart';
import 'package:my_app/provider/store_provider.dart';
import 'package:provider/provider.dart';

class CafeListMapView extends StatefulWidget {
  CafeListMapView({Key? key, required this.storeList}) : super(key: key);
  List<Store> storeList;

  @override
  State<CafeListMapView> createState() => _CafeListMapViewState();
}

class _CafeListMapViewState extends State<CafeListMapView> {
  // late NaverMapController _mapController;
  // final Completer<NaverMapController> mapControllerCompleter = Completer();

  bool isBottomSheetShowing = false;
  @override
  void initState() {
    super.initState();
    // Provider.of<StoreProvider>(context, listen: false).fetchStoreList();

    // _initialize();
  }

//   Future<void> _initialize() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NaverMapSdk.instance.initialize(
//       clientId: 'ofzfofvuev',
//       onAuthFailed: (ex) => log("********* 네이버맵 인증오류 : $ex *********"));
// }

  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  // Store? _selectedStore;
  ValueNotifier<Store?> _selectedStore = ValueNotifier<Store?>(null);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width, mediaQuery.size.height - 72);
    final physicalSize =
        Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      body: Center(
          child: SizedBox(
              width: mapSize.width,
              height: mapSize.height,
              // color: Colors.greenAccent,
              child: Stack(
                children: [
                  _naverMapSection(),

                  ValueListenableBuilder<Store?>(
                    valueListenable: _selectedStore,
                    builder: (context, store, child) {
                      if (store == null) return SizedBox.shrink();
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildBottomSheet(store),
                      );
                    },
                  ),
                  // if (_selectedStore != null)
                  //   Positioned(
                  //     bottom: 0,
                  //     left: 0,
                  //     right: 0,
                  //     child: _buildBottomSheet(_selectedStore!),
                  //   ),
                ],
              ))),
    );
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Widget _naverMapSection() {
    // List<Store> storeList = widget.storeList;
    List<Store>? storeList =
        Provider.of<StoreProvider>(context, listen: false).getStoreList();

    print("sujin store list");

    storeList?.forEach(
      (element) {
        print(element.store_name);
      },
    );
    return FutureBuilder<Position>(
      future: getLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 인디케이터를 표시합니다.
        } else if (snapshot.hasError) {
          return Text('오류: ${snapshot.error}'); // 오류 메시지를 표시합니다.
        } else {
          final position = snapshot.data!; // 위치 정보를 가져옵니다.
          final lat = position.latitude;
          final lng = position.longitude;
          print("lat ${lat}, lng ${lng}");
          // final marker = NMarker(id: 'test', position: NLatLng(lat, lng));
          final marker =
              NMarker(id: 'test', position: NLatLng(37.5512414, 126.8645132));

          var markerList = [];

          print("store List!!!!");
          storeList?.forEach((element) {
            print(
                "${element.store_name} ${storeList![2].store_lat}, ${storeList![2].store_lng}");
            final marker = NMarker(
                id: element.store_name,
                position: NLatLng(element.store_lat, element.store_lng));

            marker.setOnTapListener((overlay) => {
                  print("marker 터치됨"),
                  if (_selectedStore.value == element)
                    {_selectedStore.value = null}
                  else
                    {_selectedStore.value = element}
                });
            markerList.add(marker);
          });
          return NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                // target: NLatLng(lat, lng), // 초기 카메라 위치를 설정합니다.
                target: NLatLng(37.5512414, 126.8645132), // 등촌역
                zoom: 13,
              ),
              indoorEnable: true,
              locationButtonEnable: true,
              consumeSymbolTapEvents: false,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              // controller.addOverlay(marker);
              // controller.addOverlayAll({marker, marker2});
              markerList.forEach(
                (element) => controller.addOverlay(element),
              );
              mapControllerCompleter.complete(controller);

              log("onMapReady", name: "onMapReady");
              print("onmapready");
            },
            onMapTapped: (point, latLng) async {
              log("onMapTapped: $point, $latLng", name: "onMapTapped");
              final marker = NMarker(id: latLng.toString(), position: latLng);
              // _mapController.addOverlay(marker);

              final infoWindow = NInfoWindow.onMarker(
                id: "$point$latLng",
                text: "$point",
              );
              infoWindow.setOnTapListener((overlay) => overlay.close());

              // await marker.openInfoWindow(infoWindow);
            },
          );
        }
      },
    );
  }

  Widget _buildBottomSheet(Store store) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(store.store_name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(store.store_address),
          SizedBox(height: 8),
          Text('Additional information can be displayed here'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedStore.value = null;
              });
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  // Widget BottomSheet() {
  //   return Container(
  //     width: double.infinity,
  //     height: 200,
  //     child: Column(
  //       children: [
  //         Spacer(),
  //         Container(
  //           color: Colors.white,
  //           child: Text("Bottom sheet"),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
