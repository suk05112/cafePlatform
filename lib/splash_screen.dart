import 'dart:async';
import 'dart:io';

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
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/utils/cached_image.dart';
import 'package:cafeplatform/utils/version_compare.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final forceUpdateShown = await _checkForceUpdate();
    if (forceUpdateShown) return;
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

          try {
            await Api().client.pingUser(userProvider.user!.user_id);
          } catch (e) {
            debugPrint('[Ping] 실패(무시): $e');
          }

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

  /// 서버에 등록된 강제 업데이트 버전을 체크하고, 대상이면 다이얼로그를 띄운다.
  /// 다이얼로그를 띄운 경우(이후 로직 중단이 필요한 경우) true를 반환한다.
  Future<bool> _checkForceUpdate() async {
    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : null;
    if (platform == null) return false;

    try {
      final response = await Api().client.getAppVersion(platform, 'user');
      if (response.version == null || !response.isForceUpdate) {
        return false;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      if (!isNewerVersion(response.version!, packageInfo.version)) {
        return false;
      }

      if (!mounted) return true;
      CommonDialog.show(
        context: context,
        title: '최신 버전 업데이트',
        content: '최신버전 앱으로 업데이트를 위해\n스토어로 이동합니다.',
        buttonText: '확인',
        cancel: false,
        preventPop: true,
        filledButton: true,
        onPressed: () {
          _openStore(platform);
        },
      );
      return true;
    } catch (e) {
      debugPrint('[ForceUpdate] 체크 실패(무시): $e');
      return false;
    }
  }

  Future<void> _openStore(String platform) async {
    if (platform == 'android') {
      final marketUri = Uri.parse('market://details?id=com.gifnut.cafeplatform');
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(
        Uri.parse(
            'https://play.google.com/store/apps/details?id=com.gifnut.cafeplatform'),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    await launchUrl(
      Uri.parse('https://apps.apple.com/app/id6757492323'),
      mode: LaunchMode.externalApplication,
    );
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

      // 매장 목록 + 추천 메뉴를 병렬로 로드하고, 추천 메뉴 결과는 provider에 저장
      await Future.wait<void>([
        storeProvider.fetchListViewStoresByDistrict("01", limit: 10),
        pos != null
            ? storeProvider
                .fetchRecommendMenus(lat: pos.latitude, lng: pos.longitude)
                .then<void>((_) {})
            : storeProvider
                .fetchRecommendMenus(districtCode: "01")
                .then<void>((_) {}),
      ]);

      // 첫 화면에 보일 이미지를 미리 다운로드해 홈 진입 시 프로그레스바를 없앤다.
      // 첫 화면 분량(앞 6개)만 프리캐시하고, 과도한 대기를 막기 위해 상한을 둔다.
      await _precacheFirstScreenImages(storeProvider);
    } catch (_) {}
  }

  Future<void> _precacheFirstScreenImages(StoreProvider storeProvider) async {
    if (!mounted) return;
    const prefetchCount = 6;

    final storeUrls = (storeProvider.listViewStores ?? [])
        .take(prefetchCount)
        .map(_storeImageUrl)
        .where((u) => u.isNotEmpty);
    final menuUrls = storeProvider.recommendMenus
        .take(prefetchCount)
        .map((m) => m.menuPhoto ?? '')
        .where((u) => u.isNotEmpty);

    try {
      await prefetchCachedImages(context, [...storeUrls, ...menuUrls])
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  // _CafeDiscoveryStoreRow._imageUrl과 동일 규칙: 로고 우선, 없으면 첫 사진
  String _storeImageUrl(Store store) {
    final logo = store.store_logo.trim();
    if (logo.startsWith('http://') || logo.startsWith('https://')) return logo;
    if (store.store_photo_urls.isNotEmpty) {
      final photo = store.store_photo_urls[0].trim();
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return photo;
      }
    }
    return '';
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
