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
              child: _naverMapSection())),
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
          final marker = NMarker(id: 'test', position: NLatLng(lat, lng));

          return NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(lat, lng), // 초기 카메라 위치를 설정합니다.
                zoom: 10,
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

/*
  Widget _naverMapSection() {
    final storeList = Provider.of<StoreProvider>(context)
        .getStoreList(); // 변경된 부분: build() 메서드 내에서 storeList를 가져옴
    final lat = storeList![0].store_lat;
    final lng = storeList![0].store_lng;
    // final marker = NMarker(id: 'test', position: NLatLng(lat, lng));
    final marker =
        NMarker(id: 'test', position: NLatLng(37.5512414, 126.8645132));


    return Consumer<StoreProvider>(builder: (context, storeProvider, child) {
      List<Store> storeList = storeProvider.storeCards ?? [];
      final store = storeProvider.getStoreList()![0];

      // double lat = store.store_lat;
      // double lng = store.store_lng;
    final location = getLocation();

      print("cafe_list_builder:: ${storeList}");
      return NaverMap(
        options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
                              target: NLatLng(location.longtitude, 126.8645132), zoom: 10),

                // target: NLatLng(37.5512414, 126.8645132), zoom: 10),
            indoorEnable: true,
            locationButtonEnable: true,
            consumeSymbolTapEvents: false),
        onMapReady: (controller) async {
          _mapController = controller;
          mapControllerCompleter.complete(controller);
          controller.addOverlay(marker);
          log("onMapReady", name: "onMapReady");
        },
        onMapTapped: (point, latLng) async {
          log("onMapTapped: $point, $latLng", name: "onMapTapped");
          final marker = NMarker(id: latLng.toString(), position: latLng);
          _mapController.addOverlay(marker);

          final infoWindow =
              NInfoWindow.onMarker(id: "$point$latLng", text: "$point");
          infoWindow.setOnTapListener((overlay) => overlay.close());

          await marker.openInfoWindow(infoWindow);
        },
      );
    });
  }
*/
}
