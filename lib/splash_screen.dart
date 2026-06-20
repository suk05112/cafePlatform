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

      // 지역 목록을 백그라운드에서 미리 로드 (바텀시트 지연 방지)
      unawaited(storeProvider.fetchAvailableRegions());

      // UserProvider에서 로그인 상태를 먼저 확인 (비동기 로드 완료 대기)
      await userProvider.fetchUser();

      final firebaseUser = fb.FirebaseAuth.instance.currentUser;

      // Firebase Auth 세션이 있고, UserProvider에도 사용자 정보가 있으면 자동 로그인
      if (firebaseUser != null &&
          userProvider.isLoggedIn &&
          userProvider.user != null) {
        // Firebase Auth 세션이 유효한지 확인
        try {
          await firebaseUser
              .getIdToken()
              .timeout(const Duration(seconds: 8));
          unawaited(Api().setBaseClient(Api.BASE_URL, quickStart: true));

          // pending_gifticon_id가 있는지 확인
          final prefs = await SharedPreferences.getInstance();
          final pendingGifticonId = prefs.getInt('pending_gifticon_id');

          if (mounted) {
            if (pendingGifticonId != null) {
              // 딥링크로 들어온 기프티콘 등록이 있으면 등록 페이지로 이동
              await prefs.remove('pending_gifticon_id');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RegisterGifticonPage(gifticon_id: pendingGifticonId),
                ),
              );
            } else {
              // 자동 로그인 성공 - 메인 화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const TabPage(initialIndex: 0)),
              );
            }
            return;
          }
        } catch (e) {
          print("Firebase Auth 세션 만료: $e");
          // 세션이 만료되었으면 로그아웃 처리
          await fb.FirebaseAuth.instance.signOut();
          await userProvider.clearUser();
        }
      }

      // 로그인 안됨 - App Check 토큰 세팅은 백그라운드로, 즉시 홈화면으로 이동
      unawaited(Api().setBaseClient(Api.BASE_URL, quickStart: true));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TabPage(initialIndex: 0)),
        );
      }
    } catch (e) {
      print("자동 로그인 확인 오류: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TabPage(initialIndex: 0)),
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
