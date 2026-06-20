import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/utils/fcm_token_util.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class NotificationPermissionPage extends StatelessWidget {
  final VoidCallback onDone;

  const NotificationPermissionPage({super.key, required this.onDone});

  Future<void> _onAllow(BuildContext context) async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('service_push_enabled', granted);

    if (granted) {
      await _syncToServer(context);
    }

    onDone();
  }

  Future<void> _onLater(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('service_push_enabled', false);
    onDone();
  }

  Future<void> _syncToServer(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString('fcm_token');
      if (fcmToken == null || fcmToken.isEmpty) {
        fcmToken = await fetchFcmTokenRespectingIosApns();
        if (fcmToken != null) {
          await prefs.setString('fcm_token', fcmToken);
        }
      }
      if (fcmToken == null || fcmToken.isEmpty) return;

      final deviceType = Platform.isIOS ? 'ios' : 'android';
      final allowMarketingPush = prefs.getBool('marketing_push_enabled') ?? false;

      await Api().setBaseClient(Api.BASE_URL);
      await Api().client.registerPushToken(
        user.user_id,
        PushTokenRequest(
          fcmToken: fcmToken,
          deviceType: deviceType,
          allowServicePush: true,
          allowMarketingPush: allowMarketingPush,
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ColorAssset.mainColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 32,
                  color: ColorAssset.mainColor,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '알림을 허용하시겠어요?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '주문 완료, 선물 도착 등\n중요한 소식을 놓치지 않도록\n알림을 보내드릴게요.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorAssset.mainColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _onAllow(context),
                  child: const Text(
                    '알림 받기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _onLater(context),
                  child: Text(
                    '나중에',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
