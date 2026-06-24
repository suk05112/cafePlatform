import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cafeplatform/main.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cafeplatform/api/API.dart';
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

      await userProvider.fetchUser();

      final firebaseUser = fb.FirebaseAuth.instance.currentUser;
      debugPrint('[Splash] firebaseUser=${firebaseUser?.uid}, isLoggedIn=${userProvider.isLoggedIn}');

      if (firebaseUser != null &&
          userProvider.isLoggedIn &&
          userProvider.user != null) {
        try {
          debugPrint('[Splash] getIdToken 시작');
          await firebaseUser.getIdToken().timeout(const Duration(seconds: 8));
          debugPrint('[Splash] getIdToken 완료, setBaseClient 시작');
          await Api().setBaseClient(Api.BASE_URL, quickStart: true);
          debugPrint('[Splash] setBaseClient 완료 (로그인)');

          final prefs = await SharedPreferences.getInstance();
          final pendingGifticonId = prefs.getInt('pending_gifticon_id');

          if (mounted && pendingGifticonId != null) {
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
        } catch (e) {
          debugPrint('[Splash] 로그인 오류: $e');
          await fb.FirebaseAuth.instance.signOut();
          await userProvider.clearUser();
        }
      } else {
        debugPrint('[Splash] 비로그인, setBaseClient 시작');
        await Api().setBaseClient(Api.BASE_URL, quickStart: true);
        debugPrint('[Splash] setBaseClient 완료 (비로그인)');
      }

      unawaited(storeProvider.fetchAvailableRegions());

      if (!mounted) return;

      debugPrint('[Splash] TabPage로 이동');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TabPage(initialIndex: 0),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Splash] 전체 오류: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TabPage(initialIndex: 0)),
        );
      }
    }
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
