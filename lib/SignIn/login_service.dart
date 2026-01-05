import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cafeplatform/model/user.dart' as my_app;

class LoginService {
  static final LoginService _instance = LoginService._internal();
  factory LoginService() => _instance;
  LoginService._internal();

  final _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ]);

  Future<UserCredential?> phoneAuth(
      {required AuthCredential phoneCredential,
      required AuthCredential snsCredential,
      required Function(AuthError error) onError}) async {
    try {
      final phoneLogin = await _auth.signInWithCredential(phoneCredential);

      final fbUser = phoneLogin.user;
      print(
          "providerId: ${phoneCredential.providerId}, signInMethod: ${phoneCredential.signInMethod}");
      print(
          "providerId: ${snsCredential.providerId}, signInMethod: ${snsCredential.signInMethod}");

      if (fbUser != null) {
        print("link시도");
        await fbUser.linkWithCredential(snsCredential);
      }

      return phoneLogin;

      // phoneLogin.credential = snsCredential;
      // 3) 최종 로그인은 SNS로 다시 해야 provider가 SNS로 찍힘
    } on FirebaseAuthException catch (e) {
      print(
          "Firebase Auth 에러: ${e.code} / ${e.message} ${e.credential?.providerId}");
    } catch (e) {
      print("알 수 없는 에러: $e");
      onError(AuthErrorHandler.handle(e));
    }
    return null;
  }

  Future<bool> isRegistered(String email) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: "password",
      );
      // User created successfully
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('The email address is already in use by another account.');
        return true;
      } else {
        // Handle other FirebaseAuthException errors
        print('Firebase Auth Error: ${e.message} ${e.code}');
      }
    } catch (e) {
      // Handle any other unexpected errors
      print('General Error: $e');
    }

    return false;
  }

// 이메일/비밀번호로 Firebase에 회원가입
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // if (userCredential.user != null) {
      //   // 인증 메일 발송
      //   // userCredential.user.sendEmailVerification();
      //   // 새로운 계정 생성이 성공하였으므로 기존 계정이 있을 경우 로그아웃 시킴
      //   return true;
      // }
      return true;
    } on Exception catch (e) {
      List<String> result = e.toString().split(", ");
      return false;
    }
  }

  Future<void> signInEmail(
    email,
    password, {
    required Function(AuthCredential credential, String email, String name)
        onSuccess,
    required Function(AuthError error) onError,
  }) async {
    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // return true;
    } catch (error) {
      print("google error catch $error");
      onError(AuthErrorHandler.handle(e));
    }
  }

  Future<void> signInGoogle({
    required Function(AuthCredential credential, String email, String name,
            String provider)
        onSuccess,
    required Function(AuthError error) onError,
  }) async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        print(
            "google email: ${googleSignInAccount.email}, ${googleSignInAccount.displayName}");

        onSuccess(credential, googleSignInAccount.email,
            googleSignInAccount.displayName ?? "name", credential.providerId);
      }
    } catch (error) {
      print("google error catch $error");
      onError(AuthErrorHandler.handle(e));
    }
  }

  Future<void> signInKakao({
    required Function(AuthCredential credential, String email, String name,
            String provider)
        onSuccess,
    required Function(AuthError error) onError,
  }) async {
    kakao.OAuthToken? token;
    if (await kakao.isKakaoTalkInstalled()) {
      print("isKakaoTalkInstalled 여기 탐");
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          print('카카오톡으로 로그인 실패 $error with CANCELED');
        }
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
          onError(AuthErrorHandler.handle(e));
        }
      }
    } else {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        onError(AuthErrorHandler.handle(e));
      }
    }
// 계정 가리기 -> 삭제 -> 계정보이고 로그인 : 새로운 유저 -> 전화번호 인증 -> 재검사
    try {
      var provider = OAuthProvider('oidc.kakao'); // 제공업체 id
      var credential = provider.credential(
        idToken: token?.idToken,
        accessToken: token?.accessToken, // 카카오 로그인에서 발급된 accessToken
      );

      kakao.User kakaoUser = await kakao.UserApi.instance.me();
      print(
          "kakaoemail: ${kakaoUser.kakaoAccount?.email} ${kakaoUser.kakaoAccount?.profile?.nickname ?? ""}");

      onSuccess(
          credential,
          kakaoUser.kakaoAccount?.email ?? "email",
          kakaoUser.kakaoAccount?.profile?.nickname ?? "name",
          credential.providerId);
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
      onError(AuthErrorHandler.handle(e));
    }
    return;
  }

  Future<void> signInApple({
    required Function(AuthCredential credential, String? email, String? name)
        onSuccess,
    required Function(AuthError error) onError,
  }) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // firebase를 이용한 로그인 정보 추출
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      print(
          "appel id token: ${oauthCredential.providerId}, ${oauthCredential.idToken}");
      print(
          "appel id email: ${credential.email} ${credential.familyName}${credential.givenName} ${oauthCredential.appleFullPersonName}");
      final name = "${credential.familyName}${credential.givenName}";

      onSuccess(oauthCredential, credential.email, name);
    } catch (error) {
      print('애플계정으로 로그인 실패 $error');
      onError(AuthErrorHandler.handle(e));
      return;
    }
    return;
  }

  Future<bool> isRegisteredUser(email, provider) async {
    print("register 확인할 email $email");
    final response = await Api().client.getIsRegisteredUser(email, provider);
    print(" isRegisteredUser$response");
    return response.isRegistered;
  }

  Future<bool> isRegisteredAppleUser(phoneNumber) async {
    print("apple register 확인할 phoneNumber $phoneNumber");
    try {
      final response = await Api().client.getIsRegisteredAppleUser(phoneNumber);
      print(" isRegisteredUser$response");
      return response.isRegistered;
    } catch (e) {
      print("❌ Error: $e");
      return false;
    }
  }

  Future<bool> isRegisteredUserByPhone(String phoneNumber) async {
    print("register 확인할 phoneNumber $phoneNumber");
    try {
      final response = await Api().client.getIsRegisteredAppleUser(phoneNumber);
      print(" isRegisteredUserByPhone $response");
      return response.isRegistered;
    } catch (e) {
      print("❌ Error: $e");
      return false;
    }
  }
}

enum AuthError {
  cancelled,
  network,
  accountNotFound,
  firebase,
  server,
  unknown,
}

extension AuthErrorMessage on AuthError {
  String get message {
    switch (this) {
      case AuthError.cancelled:
        return "로그인이 취소되었습니다.";
      case AuthError.network:
        return "네트워크 연결을 확인해주세요.";
      case AuthError.accountNotFound:
        return "가입되지 않은 사용자입니다.";
      case AuthError.firebase:
        return "Firebase 로그인 중 문제가 발생했습니다.";
      case AuthError.server:
        return "서버 처리 중 문제가 발생했습니다.";
      default:
        return "알 수 없는 오류가 발생했습니다.";
    }
  }
}

class AuthErrorHandler {
  static AuthError handle(Object e) {
    if (e is FirebaseAuthException) {
      if (e.code == "network-request-failed") return AuthError.network;
      if (e.code == "user-not-found") return AuthError.accountNotFound;
      return AuthError.firebase;
    }

    if (e.toString().contains("CANCELED")) return AuthError.cancelled;

    return AuthError.unknown;
  }
}
