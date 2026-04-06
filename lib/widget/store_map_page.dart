import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

/// 매장 위치 전체 화면 지도
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
      body: StoreLocationNaverMap(
        latitude: latitude,
        longitude: longitude,
        fullScreen: true,
      ),
    );
  }
}

class StoreLocationNaverMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final bool fullScreen;

  const StoreLocationNaverMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.fullScreen = false,
  });

  @override
  State<StoreLocationNaverMap> createState() => _StoreLocationNaverMapState();
}

class _StoreLocationNaverMapState extends State<StoreLocationNaverMap>
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
    if (_isMapReady && mapControllerCompleter.isCompleted) {
      try {
        _mapController.dispose();
      } catch (e) {
        // ignore
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
          final marker = NMarker(
            id: 'store',
            position: NLatLng(widget.latitude, widget.longitude),
          );
          try {
            marker.setIcon(NOverlayImage.fromAssetImage("assets/pin.png"));
          } catch (_) {}
          controller.addOverlay(marker);
        },
      );
    }
    return Container(
      margin: const EdgeInsets.all(15),
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
            final marker = NMarker(
              id: 'store',
              position: NLatLng(widget.latitude, widget.longitude),
            );
            try {
              marker.setIcon(NOverlayImage.fromAssetImage("assets/pin.png"));
            } catch (_) {}
            controller.addOverlay(marker);
          },
        ),
      ),
    );
  }
}
