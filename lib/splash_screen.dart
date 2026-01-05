import 'package:flutter/material.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cafeplatform/api/API.dart';

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
    // 스플래시 화면 표시 시간 (최소 1초)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final firebaseUser = fb.FirebaseAuth.instance.currentUser;

      // Firebase Auth 세션이 있고, UserProvider에도 사용자 정보가 있으면 자동 로그인
      if (firebaseUser != null && userProvider.user != null) {
        // Firebase Auth 세션이 유효한지 확인
        try {
          await firebaseUser.getIdToken();
          // 세션이 유효하면 API 클라이언트 설정
          await Api().setBaseClient(Api.BASE_URL);
          // 자동 로그인 성공 - 메인 화면으로 이동
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TabPage(initialIndex: 0)),
            );
            return;
          }
        } catch (e) {
          print("Firebase Auth 세션 만료: $e");
          // 세션이 만료되었으면 로그아웃 처리
          await fb.FirebaseAuth.instance.signOut();
          await userProvider.clearUser();
        }
      }

      // 자동 로그인 실패 또는 로그인 안됨 - 로그인 페이지로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print("자동 로그인 확인 오류: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
            Image.asset(
              'assets/gifnut_logo.png',
              height: 120,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }
}
