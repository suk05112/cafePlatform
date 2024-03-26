import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class CafeListMapView extends StatefulWidget {
  const CafeListMapView({Key? key}) : super(key: key);

  @override
  State<CafeListMapView> createState() => _CafeListMapViewState();
}

class _CafeListMapViewState extends State<CafeListMapView> {
  // late NaverMapController _mapController;
  // final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
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
    final mapSize =
        Size(mediaQuery.size.width, mediaQuery.size.height - 72);
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

  Widget _naverMapSection() => NaverMap(
        options: const NaverMapViewOptions(
            indoorEnable: true,
            locationButtonEnable: true,
            consumeSymbolTapEvents: false),
        onMapReady: (controller) async {
          _mapController = controller;
          mapControllerCompleter.complete(controller);
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
}


