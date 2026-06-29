import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  // 전화번호로 signIn 후 SNS credential link
  Future<UserCredential?> phoneAuth(
      {required AuthCredential phoneCredential,
      required AuthCredential snsCredential,
      required Function(Future<AuthError> error) onError}) async {
    try {
      debugPrint('[Firebase] 전화번호 signIn 시도');
      final phoneLogin = await _auth.signInWithCredential(phoneCredential);
      final fbUser = phoneLogin.user;
      debugPrint('[Firebase] 전화번호 signIn 성공 - uid: ${fbUser?.uid}');

      if (fbUser != null) {
        debugPrint('[Firebase] SNS credential link 시도 - provider: ${snsCredential.providerId}');
        try {
          await fbUser.linkWithCredential(snsCredential);
          debugPrint('[Firebase] SNS link 성공');
        } on FirebaseAuthException catch (linkError) {
          debugPrint('[Firebase] SNS link 실패: ${linkError.code}');
          if (linkError.code == 'provider-already-linked' ||
              linkError.code == 'credential-already-in-use') {
            return phoneLogin;
          } else {
            rethrow;
          }
        }
      }

      return phoneLogin;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Firebase] phoneAuth 오류: ${e.code}');
      onError(Future.value(AuthError.firebase));
    } catch (e) {
      debugPrint('[Firebase] phoneAuth 알 수 없는 오류: $e');
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
        return true;
      } else {
        // Handle other FirebaseAuthException errors
      }
    } catch (e) {
      // Handle any other unexpected errors
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
      onError(await AuthErrorHandler.handle(e));
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

        onSuccess(credential, googleSignInAccount.email,
            googleSignInAccount.displayName ?? "name", credential.providerId);
      }
    } catch (error) {
      onError(await AuthErrorHandler.handle(e));
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
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
        }
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        } catch (error) {
          onError(await AuthErrorHandler.handle(e));
        }
      }
    } else {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      } catch (error) {
        onError(await AuthErrorHandler.handle(e));
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

      onSuccess(
          credential,
          kakaoUser.kakaoAccount?.email ?? "email",
          kakaoUser.kakaoAccount?.profile?.nickname ?? "name",
          credential.providerId);
    } catch (error) {
      onError(await AuthErrorHandler.handle(e));
    }
    return;
  }

  Future<void> signInApple({
    required Function(AuthCredential credential, String? email, String? name)
        onSuccess,
    required Function(Future<AuthError> error) onError,
  }) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final familyName = appleCredential.familyName ?? "";
      final givenName = appleCredential.givenName ?? "";
      final name = (familyName + givenName).isNotEmpty ? familyName + givenName : null;

      onSuccess(oauthCredential, appleCredential.email, name);
    } catch (error) {
      onError(AuthErrorHandler.handle(error));
      return;
    }
    return;
  }

  Future<RegistrationStatus> isRegisteredUser(String? email, String provider,
      {String? phone, String? uid}) async {
    try {
      final response = await Api().client.getIsRegisteredUser(
            email,
            provider,
            phone,
            uid: uid,
          );
      return response.registrationStatus;
    } on DioException {
      rethrow;
    } catch (e) {
      return RegistrationStatus.newUser;
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
  static Future<AuthError> handle(Object e) async {
    if (e is FirebaseAuthException) {
      if (e.code == "network-request-failed") return AuthError.network;
      if (e.code == "user-not-found") return AuthError.accountNotFound;
      return AuthError.firebase;
    }

    if (e.toString().contains("CANCELED")) return AuthError.cancelled;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      await currentUser.delete();
      auth.signOut();
    }
    return AuthError.unknown;
  }
}
