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
  const CafeListMapView({Key? key}) : super(key: key);

  @override
  State<CafeListMapView> createState() => _CafeListMapViewState();
}

class _CafeListMapViewState extends State<CafeListMapView> {
  // late NaverMapController _mapController;
  // final Completer<NaverMapController> mapControllerCompleter = Completer();

  // List<Store>? storeList =

  bool isBottomSheetShowing = false;
  @override
  void initState() {
    super.initState();

    // storeList =
    // Provider.of<StoreProvider>(context, listen: false).getStoreList();

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
                  isBottomSheetShowing
                      ? BottomSheet()
                      : SizedBox(
                          height: 0,
                        )
                ],
              ))),
    );
  }
  // Widget build(BuildContext context) {
  //   final mediaQuery = MediaQuery.of(context);
  //   final pixelRatio = mediaQuery.devicePixelRatio;
  //   final mapSize =
  //       Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
  //   final physicalSize =
  //       Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);
  //   return Scaffold(
  //       backgroundColor: const Color(0xFF343945),
  //       body: Center(
  //           child: Container(
  //               width: mapSize.width,
  //               height: mapSize.height,
  //               // color: Colors.greenAccent,
  //               child: Text(""))),
  //   );

  // }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Widget _naverMapSection() {
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

          // marker.performClick();
          marker.setOnTapListener((overlay) => {
                print("marker 터치됨"),
                setState(() {
                  isBottomSheetShowing = !isBottomSheetShowing;
                })
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
              mapControllerCompleter.complete(controller);
              controller.addOverlay(marker);
              log("onMapReady", name: "onMapReady");
              print("onmapready");
            },
            onMapTapped: (point, latLng) async {
              log("onMapTapped: $point, $latLng", name: "onMapTapped");
              final marker = NMarker(id: latLng.toString(), position: latLng);
              _mapController.addOverlay(marker);

              final infoWindow = NInfoWindow.onMarker(
                id: "$point$latLng",
                text: "$point",
              );
              infoWindow.setOnTapListener((overlay) => overlay.close());

              await marker.openInfoWindow(infoWindow);
            },
          );
        }
      },
    );
  }

  Widget BottomSheet() {
    return Container(
      width: double.infinity,
      height: 200,
      child: Column(
        children: [Text("Bottom sheet")],
      ),
    );
  }
}
