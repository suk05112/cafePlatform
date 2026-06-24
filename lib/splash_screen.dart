import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/provider/store_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cafeplatform/api/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/Payment/register_gifticon_page.dart';
import 'package:geolocator/geolocator.dart';

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
    if (!mounted) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);

      await userProvider.fetchUser();

      final firebaseUser = fb.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null &&
          userProvider.isLoggedIn &&
          userProvider.user != null) {
        try {
          await firebaseUser.getIdToken().timeout(const Duration(seconds: 8));
          await Api().setBaseClient(Api.BASE_URL, quickStart: true);

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
          await fb.FirebaseAuth.instance.signOut();
          await userProvider.clearUser();
        }
      } else {
        await Api().setBaseClient(Api.BASE_URL, quickStart: true);
      }

      // setBaseClient 완료 후 최소 노출 시간 + 데이터 프리패치 동시 대기
      // 둘 다 완료되어야 화면 전환 (프리패치가 더 오래 걸리면 프리패치 기준)
      await Future.wait<void>([
        Future.delayed(const Duration(milliseconds: 1500)),
        _prefetchHomeData(storeProvider),
      ]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TabPage(initialIndex: 0),
        ),
      );
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

  Future<void> _prefetchHomeData(StoreProvider storeProvider) async {
    try {
      await storeProvider.fetchAvailableRegions();

      // 권한 요청 없이 이미 허용된 경우에만 현재 위치 사용
      Position? pos;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          try {
            pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 5),
            );
          } catch (_) {
            pos = await Geolocator.getLastKnownPosition();
          }
        }
      } catch (_) {}

      if (pos != null) {
        // 위치 권한 있으면 위치 기반 매장 + 추천 메뉴
        await Future.wait<void>([
          storeProvider.fetchListViewStoresByDistrict("01", limit: 10),
          Api().client
              .getRecommendMenus(lat: pos.latitude, lng: pos.longitude, limit: 100)
              .then<void>((_) {})
              .catchError((_) {}),
        ]);
      } else {
        // 위치 권한 없으면 기본 지역("01") 기반
        await Future.wait<void>([
          storeProvider.fetchListViewStoresByDistrict("01", limit: 10),
          Api().client
              .getRecommendMenus(districtCode: "01", limit: 100)
              .then<void>((_) {})
              .catchError((_) {}),
        ]);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorAssset.mainColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '우리동네 선물하기 플랫폼',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gifnut',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
