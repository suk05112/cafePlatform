import 'package:flutter/material.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              userProvider.isLoggedIn ? TabPage() : LoginPage(),
        ),
      );
    });
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
              'Gfinut',
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
