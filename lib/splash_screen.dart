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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/Payment/register_gifticon_page.dart';
import 'package:cafeplatform/setting/notification_permission_page.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationPermissionPage(onDone: _navigateToMain),
        ),
      );
    } else {
      _navigateToMain();
    }
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
