import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final int _storeId = 1;

  final firebaseAuth = FirebaseAuth.instance;

  google.GoogleSignIn _googleSignIn = google.GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    _initRetrieval();
  }

  Future _initRetrieval() async {}

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  void signOut() async {
    await _googleSignIn.signOut();
    print("User signed out.");
  }

  Future<dynamic> handleGoogleSignInProvider() async {
    try {
      await _googleSignIn
          .signIn()
          .then((google.GoogleSignInAccount? googleSignInAccount) async {
        if (googleSignInAccount == null) {
          print('구글 데이터를 가져오지 못했습니다');

          return null;
        }

        google.GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential authResult =
            await firebaseAuth.signInWithCredential(credential);
        fb.User? user = authResult.user;

        if (user == null) {
          print('구글 유저 데이터를 가져오지 못했습니다');

          return null;
        }

        return {
          'type': 'google',
          'user_uuid': user.uid,
          'email': user.email,
          'profile': user.photoURL,
        };
      });
    } catch (error) {
      return null;
    }
  }

  Future kakaoLogin() async {
    if (await kakao.isKakaoTalkInstalled()) {
      try {
        await kakao.UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        getKakaoEmail();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          getKakaoEmail();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<String?> getKakaoEmail() async {
    try {
      kakao.User user = await UserApi.instance.me();
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
          '\n이메일: ${user.kakaoAccount?.email}');

      return user.kakaoAccount?.email;
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Container(
              margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 13),
                    IconButton(
                      icon: Image.asset('assets/kakao_login.png'),
                      iconSize: 50,
                      onPressed: () {
                        kakaoLogin();
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/google_login.png'),
                      iconSize: 50,
                      onPressed: () {
                        handleGoogleSignInProvider();
                      },
                    )
                  ]))
        ]))));
  }
}
