import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final bool showErrorScreen;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.onRetry,
    this.showErrorScreen = true,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hasInternet = true;
  bool _isChecking = false;

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
    final hasConnection =
        result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);

    if (mounted) {
      final wasOffline = !_hasInternet;
      setState(() {
        _hasInternet = hasConnection;
      });

      // 인터넷이 재연결되면 자동으로 onRetry 호출 (전체 새로고침 방지)
      if (wasOffline && hasConnection && widget.onRetry != null) {
        // 약간의 딜레이를 주어 네트워크가 안정화되도록 함
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _hasInternet) {
            widget.onRetry!();
          }
        });
      }
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isChecking = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      if (_hasInternet && widget.onRetry != null) {
        widget.onRetry!();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet && widget.showErrorScreen) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                '인터넷 연결 없음',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                '인터넷에 연결되어 있지 않습니다.\n네트워크 연결을 확인해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _retry,
                icon: _isChecking
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.refresh),
                label: Text(
                  _isChecking ? '확인 중...' : '다시 시도',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
