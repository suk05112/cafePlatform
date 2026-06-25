import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cafeplatform/widget/no_internet_screen.dart';

class NetworkChecker extends StatefulWidget {
  final Widget child;

  const NetworkChecker({
    super.key,
    required this.child,
  });

  @override
  State<NetworkChecker> createState() => _NetworkCheckerState();
}

class _NetworkCheckerState extends State<NetworkChecker> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hasInternet = true;
  int _refreshKey = 0; // 인터넷 재연결 시 child를 새로고침하기 위한 key

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // iOS 등에서 빈 리스트가 나오면 "오프라인"으로 오인해 전체 앱이 막히지 않도록 함
    final hasConnection = result.isEmpty ||
        result.any((r) => r != ConnectivityResult.none);

    if (mounted) {
      final wasOffline = !_hasInternet;
      setState(() {
        _hasInternet = hasConnection;
        // 인터넷이 다시 연결되었을 때 key를 변경하여 child를 새로고침
        if (wasOffline && hasConnection) {
          _refreshKey++;
        }
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return NoInternetScreen(
        onReconnect: () {
          if (!mounted) return;
          setState(() {
            _hasInternet = true;
            _refreshKey++;
          });
        },
      );
    }
    // key를 변경하여 인터넷 재연결 시 child를 새로고침
    return KeyedSubtree(
      key: ValueKey('network_refresh_$_refreshKey'),
      child: widget.child,
    );
  }
}
