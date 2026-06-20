import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cafeplatform/main.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/Payment/register_gifticon_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);

      unawaited(storeProvider.fetchAvailableRegions());
      await userProvider.fetchUser();

      final firebaseUser = fb.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null &&
          userProvider.isLoggedIn &&
          userProvider.user != null) {
        try {
          await firebaseUser.getIdToken().timeout(const Duration(seconds: 8));
          unawaited(Api().setBaseClient(Api.BASE_URL, quickStart: true));

          final prefs = await SharedPreferences.getInstance();
          final pendingGifticonId = prefs.getInt('pending_gifticon_id');

          if (mounted) {
            if (pendingGifticonId != null) {
              await prefs.remove('pending_gifticon_id');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RegisterGifticonPage(gifticon_id: pendingGifticonId),
                ),
              );
              return;
            }
          }
        } catch (e) {
          print("Firebase Auth 세션 만료: $e");
          await fb.FirebaseAuth.instance.signOut();
          await userProvider.clearUser();
        }
      } else {
        unawaited(Api().setBaseClient(Api.BASE_URL, quickStart: true));
      }

      if (!mounted) return;
      await _checkNotificationPermissionThenNavigate();
    } catch (e) {
      print("자동 로그인 확인 오류: $e");
      if (mounted) _navigateToMain();
    }
  }

  Future<void> _checkNotificationPermissionThenNavigate() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final status = settings.authorizationStatus;

    if (!mounted) return;

    if (status == AuthorizationStatus.notDetermined) {
      await _showNotificationPermissionSheet();
    }

    if (mounted) _navigateToMain();
  }

  Future<void> _showNotificationPermissionSheet() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NotificationPermissionSheet(
        onAllow: () async {
          Navigator.pop(ctx);
          final result = await FirebaseMessaging.instance.requestPermission(
            alert: true, badge: true, sound: true,
          );
          final granted =
              result.authorizationStatus == AuthorizationStatus.authorized ||
              result.authorizationStatus == AuthorizationStatus.provisional;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('service_push_enabled', granted);
          if (granted && mounted) {
            await _syncNotificationToServer();
          }
        },
        onLater: () async {
          Navigator.pop(ctx);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('service_push_enabled', false);
        },
      ),
    );
  }

  Future<void> _syncNotificationToServer() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString('fcm_token');
      if (fcmToken == null || fcmToken.isEmpty) return;

      await Api().client.registerPushToken(
        user.user_id,
        PushTokenRequest(
          fcmToken: fcmToken,
          deviceType: 'ios',
          allowServicePush: true,
          allowMarketingPush: prefs.getBool('marketing_push_enabled') ?? false,
        ),
      );
    } catch (_) {}
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TabPage(initialIndex: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gifnut',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 32),
            SvgPicture.asset(
              'assets/gifnut_logo.svg',
              height: 120,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPermissionSheet extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onLater;

  const _NotificationPermissionSheet({
    required this.onAllow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '주문 완료 소식을 받아보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '선물 도착, 주문 완료 등\n중요한 알림을 놓치지 마세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: onLater,
                  child: const Text(
                    '다음에 하기',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: onAllow,
                  child: const Text(
                    '알림 켜기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
