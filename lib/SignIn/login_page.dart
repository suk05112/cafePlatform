import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cafeplatform/SignIn/login_service.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/Extension/scaffold_messenger_extension.dart';
import 'package:cafeplatform/model/user.dart' as my_app;
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/SignIn/signUp_page.dart';
import 'package:cafeplatform/SignIn/find_password_page.dart';
import 'package:cafeplatform/SignIn/find_userId_page.dart';
import 'package:dio/dio.dart';
import 'package:cafeplatform/SignIn/terms_agreement_page.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:cafeplatform/Payment/register_gifticon_page.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/utils/fcm_token_util.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class LoginPage extends StatefulWidget {
  final bool returnToPrevious;

  const LoginPage({super.key, this.returnToPrevious = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// 테스트용: true면 아이디 로그인 버튼만 눌러도 인증 없이 다음 화면으로 이동합니다.
  static const bool _kBypassEmailLoginForTest = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  bool _loading = false;

  final loginService = LoginService();

  // Firebase provider ID를 서버 API provider 형식으로 변환
  String _convertProviderToServerFormat(String firebaseProviderId) {
    switch (firebaseProviderId) {
      case 'google.com':
        return 'google.com';
      case 'apple.com':
        return 'apple.com';
      case 'oidc.kakao':
        return 'oidc.kakao';
      case 'password':
        return 'email';
      default:
        // 그 외의 경우는 그대로 반환 (oidc.로 시작하는 경우 등)
        return firebaseProviderId;
    }
  }

  // 전화번호를 E.164 형식(+82)으로 변환
  String _formatToE164(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.startsWith('0')) {
      return '+82${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('82')) {
      return '+$digitsOnly';
    } else {
      return '+82$digitsOnly';
    }
  }

  // 이메일/비밀번호 로그인을 위한 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // 비밀번호 숨김/표시

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signOut() async {
    //자동로그인 해제
  }

  Future<void> _handleEmailLogin() async {
    if (_kBypassEmailLoginForTest) {
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(
        my_app.User(
          user_id: 0,
          name: '테스트',
          email: 'test@gifnut.com',
          phone_number: '',
          uid: 'test_bypass',
        ),
      );
      if (widget.returnToPrevious && Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TabPage(initialIndex: 0),
          ),
        );
      }
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showUniqueSnackBar(
        SnackBar(content: Text("이메일과 비밀번호를 입력해주세요.")),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final emailInput = _emailController.text.trim();
    final emailWithDomain = emailInput + "@gifnut.com";
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailWithDomain,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (userCredential.user != null) {
        try {
          await Api().setBaseClient(Api.BASE_URL, quickStart: true);
          if (!mounted) return;
          var response = await Api().client.loginUser(emailWithDomain, 'email');

          if (!mounted) return;

          if (response.user_id != null) {
            final user = my_app.User(
              user_id: response.user_id ?? -1,
              name: response.name ?? "name",
              email: response.email ?? "email",
              phone_number: response.phone_number ?? "",
              uid: userCredential.user?.uid ?? "",
            );
            Provider.of<UserProvider>(context, listen: false).setUser(user);

            // 푸시 토큰 등록
            _registerPushToken(response.user_id ?? -1);

            // 딥링크로 들어온 기프티콘 등록이 있는지 확인
            final prefs = await SharedPreferences.getInstance();
            final pendingGifticonId = prefs.getInt('pending_gifticon_id');

            if (!mounted) return;

            if (pendingGifticonId != null) {
              // 딥링크로 들어온 기프티콘 등록이 있으면 등록 페이지로 이동
              await prefs.remove('pending_gifticon_id');
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RegisterGifticonPage(gifticon_id: pendingGifticonId),
                ),
              );
            } else {
              // 로그인 성공 시 처리
              // returnToPrevious가 true면 이전 페이지로 돌아가기, false면 TabPage로 이동
              if (widget.returnToPrevious && Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TabPage(initialIndex: 0)),
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showUniqueSnackBar(
              SnackBar(
                content: Text(response.msg ?? "로그인 정보를 가져오는데 실패했습니다."),
              ),
            );
          }
        } on DioException catch (e) {
          String errorMessage = "서버와 통신 중 오류가 발생했습니다.";

          if (e.response != null) {
            // 서버에서 응답을 받았지만 오류 상태 코드인 경우
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = "사용자를 찾을 수 없습니다.";
            } else if (statusCode == 500) {
              errorMessage = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
            } else {
              errorMessage = "로그인 정보를 가져오는데 실패했습니다. ($statusCode)";
            }
          } else if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage = "서버 연결 시간이 초과되었습니다. 네트워크를 확인해주세요.";
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = "서버에 연결할 수 없습니다. 네트워크를 확인해주세요.";
          }

          ScaffoldMessenger.of(context).showUniqueSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showUniqueSnackBar(
            SnackBar(content: Text("로그인 정보를 가져오는 중 오류가 발생했습니다.")),
          );
        }
      }
    } on fb.FirebaseAuthException catch (e) {
      String errorMessage = "로그인에 실패했습니다.";
      if (e.code == 'user-not-found') {
        errorMessage = "등록되지 않은 이메일입니다.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "비밀번호가 잘못되었습니다.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "이메일 형식이 올바르지 않습니다.";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "아이디 또는 비밀번호가 잘못되었습니다.";
      }
      ScaffoldMessenger.of(context).showUniqueSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showUniqueSnackBar(
          SnackBar(content: Text("로그인 중 오류가 발생했습니다.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 40),

                          SizedBox(height: 50),
                          // 상단 제목 영역
                          // Text.rich(
                          //   TextSpan(
                          //     children: const [
                          //       TextSpan(text: '이 부분은 굵지 않고, '),
                          //       TextSpan(
                          //         text: '이 부분만 굵게',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //       TextSpan(text: ' 표시됩니다.'),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(height: 8),
                          Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 40),
                          // 이메일 입력 필드
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: '아이디를 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // 비밀번호 입력 필드
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '비밀번호를 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 50),
                          // 이메일로 로그인 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleEmailLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorAssset.mainColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      '아이디로 로그인',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // 회원가입 | 이메일 찾기
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _startEmailSignUpFlow();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => FindUserIDPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '아이디 찾기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => FindPasswordPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '비밀번호 찾기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          // 간편로그인 섹션
                          Center(
                            child: Text(
                              '간편로그인',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // SNS 로그인 버튼들
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 카카오 로그인 버튼
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    await loginService.signInKakao(
                                        onSuccess: loginSuccess,
                                        onError: loginFail);
                                  },
                                  child: SvgPicture.asset(
                                    'assets/kakao_login.svg',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 20),
                                // 구글 로그인 버튼
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    loginService.signInGoogle(
                                        onSuccess: loginSuccess,
                                        onError: loginFail);
                                  },
                                  child: SvgPicture.asset(
                                    'assets/google_login.svg',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 20),
                                // 애플 로그인 버튼
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    await loginService.signInApple(
                                        onSuccess: appleLoginSuccess,
                                        onError: loginFail);
                                  },
                                  child: SvgPicture.asset(
                                    'assets/apple_login.svg',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 전체 화면 프로그레스바 (SNS 로그인 시 폰 인증 대기 중)
              if (_loading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: ColorAssset.mainColor),
                  ),
                ),
            ],
          ),
        ));
  }

  void loginFail(dynamic error) {
    String errorMessage = "로그인 중 오류가 발생했습니다.";
    if (error is AuthError) {
      errorMessage = error.message;
    } else if (error is Exception) {
      errorMessage = error.toString();
    }
    ScaffoldMessenger.of(context).showUniqueSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  void loginSuccess(credential, email, name, provider) async {
    // SNS 로그인 후 신규/기존 판단
    fb.UserCredential? userCredential;

    // 로딩 인디케이터 표시
    setState(() {
      _loading = true;
    });

    try {
// 메일이 같아도 최초한번은 번호인증 하도록
      bool needPhoneAuth;
      try {
        final regStatus =
            await loginService.isRegisteredUser(email, provider);
        needPhoneAuth = regStatus != RegistrationStatus.registered;
      } on DioException catch (e) {
        // isRegisteredUser API 호출 실패 시 alert 표시하고 중단
        String errorMessage = '네트워크 오류가 발생했습니다.';
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = '인터넷 연결을 확인해주세요.';
        } else if (e.response != null) {
          errorMessage = '서버 오류가 발생했습니다.\n(${e.response?.statusCode})';
        }

        if (mounted) {
          setState(() {
            _loading = false;
          });
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text('오류'),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        }
        return; // 에러 발생 시 함수 종료
      }

      if (needPhoneAuth) {
        // 폰 인증 페이지로 이동 (로딩은 계속 표시)
        // 프로그레스바는 _loading이 true일 때 자동으로 표시됨

        // SNS provider를 서버 형식으로 변환
        final serverProvider =
            _convertProviderToServerFormat(credential.providerId);

        // 약관동의 페이지 먼저 보여주기 (약관동의 후 전화번호 인증까지 처리됨)
        PhoneAuthResult? phoneAuthResult = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TermsAgreementPage(
                    isSocialLogin: true,
                    provider: serverProvider,
                  )),
        );

        if (phoneAuthResult == null) {
          // 약관동의를 취소한 경우
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
          return;
        }

        final finalPhoneAuthResult = phoneAuthResult;

        userCredential = await loginService.phoneAuth(
            phoneCredential: finalPhoneAuthResult.credential,
            snsCredential: credential,
            onError: (error) async {
              final authError = await error;
              if (mounted) {
                setState(() => _loading = false);
                ScaffoldMessenger.of(context).showUniqueSnackBar(
                  SnackBar(content: Text(authError.message), backgroundColor: Colors.red),
                );
              }
              loginFail(authError);
            });

        if (userCredential == null || userCredential.user == null) {
          if (mounted) setState(() => _loading = false);
          return;
        }

        await Api().setBaseClient(Api.BASE_URL, quickStart: true);

        // new / phone_exists 모두 서버 회원가입 후 로그인
        final userName = finalPhoneAuthResult.name ?? name;
        await userCredential.user?.updateDisplayName(userName);

        try {
          final formattedPhoneNumber = _formatToE164(finalPhoneAuthResult.phoneNumber);
          final registerUser = my_app.User(
            user_id: 0,
            name: userName,
            email: email,
            phone_number: formattedPhoneNumber,
            uid: userCredential.user?.uid ?? "",
            provider: provider,
          );
          await Api().client.registerUser(registerUser);
        } on DioException catch (e) {
          String errorMessage = '회원가입 중 오류가 발생했습니다.';
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = '인터넷 연결을 확인해주세요.';
          } else if (e.response != null) {
            errorMessage = '서버 오류가 발생했습니다.\n(${e.response?.statusCode})';
          }
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('오류'),
                content: Text(errorMessage),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
              ),
            );
          }
          return;
        } catch (e) {
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('오류'),
                content: const Text('회원가입 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.'),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
              ),
            );
          }
          return;
        }

        if (!mounted) return;
        await _loginAndNavigate(email, serverProvider, userCredential.user!.uid);
        return;
      } else {
        // registered: SNS credential로 직접 로그인
        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user == null) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(context).showUniqueSnackBar(
            const SnackBar(
              content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await Api().setBaseClient(Api.BASE_URL, quickStart: true);

      try {
        // SNS provider를 서버 형식으로 변환
        final serverProvider =
            _convertProviderToServerFormat(credential.providerId);
        var response = await Api().client.loginUser(email, serverProvider);

        if (response.user_id == null) {
          if (mounted) {
            setState(() {
              _loading = false;
            });
            ScaffoldMessenger.of(context).showUniqueSnackBar(
              SnackBar(
                content: Text(response.msg ?? "로그인 정보를 가져오는데 실패했습니다."),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // 비동기 작업 후 위젯이 dispose되었는지 확인
        if (!mounted) {
          return;
        }

        // userCredential과 uid 확인
        final uid = userCredential.user?.uid;
        if (uid == null || uid.isEmpty) {
        }

        final user = my_app.User(
          user_id: response.user_id ?? -1,
          name: response.name ?? "name",
          email: response.email ?? "email",
          phone_number: response.phone_number ?? "",
          uid: uid ?? "",
        );


        // context가 유효한지 확인 후 UserProvider 업데이트
        if (!mounted) {
          return;
        }

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        // 푸시 토큰 등록 (비동기로 실행하되, 실패해도 로그인은 계속 진행)
        _registerPushToken(response.user_id ?? -1).catchError((error) {
        });

        // 로그인 성공 시 처리
        if (mounted) {
          setState(() {
            _loading = false;
          });

          // returnToPrevious가 true면 이전 페이지로 돌아가기, false면 TabPage로 이동
          if (widget.returnToPrevious && Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TabPage(initialIndex: 0)),
            );
          }
        }
      } on DioException catch (e) {
        String errorMessage = '서버 오류가 발생했습니다.';
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = '인터넷 연결을 확인해주세요.';
        } else if (e.response != null) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 500) {
            errorMessage = '서버 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
          } else if (statusCode == 404) {
            errorMessage = '사용자를 찾을 수 없습니다.';
          } else {
            errorMessage = '서버 오류가 발생했습니다.\n($statusCode)';
          }
        }

        if (mounted) {
          setState(() {
            _loading = false;
          });
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('오류'),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(context).showUniqueSnackBar(
            SnackBar(
              content: Text('로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void appleLoginSuccess(fb.AuthCredential appleCredential, String? email, String? name) async {
    setState(() => _loading = true);

    try {
      const provider = "apple.com";
      final emailForCheck = email ?? "apple";

      // 1단계: Firebase signIn으로 uid 획득 (email 없이도 uid로 isRegistered 판단 가능)
      final tempCredential = await _auth.signInWithCredential(appleCredential);
      if (tempCredential.user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final appleUid = tempCredential.user!.uid;

      // 2단계: uid + provider로 기존 유저 여부 확인
      RegistrationStatus regStatus;
      try {
        await Api().setBaseClient(Api.BASE_URL, quickStart: true);
        regStatus = await loginService.isRegisteredUser(null, provider, uid: appleUid);
      } on DioException catch (e) {
        await _auth.signOut();
        String errorMessage = '네트워크 오류가 발생했습니다.';
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = '인터넷 연결을 확인해주세요.';
        } else if (e.response != null) {
          errorMessage = '서버 오류가 발생했습니다.\n(${e.response?.statusCode})';
        }
        if (mounted) {
          setState(() => _loading = false);
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('오류'),
              content: Text(errorMessage),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
            ),
          );
        }
        return;
      }

      if (regStatus == RegistrationStatus.registered) {
        // 기존 유저: 이미 signIn된 상태로 바로 서버 로그인
        if (!mounted) return;
        await _loginAndNavigate(emailForCheck, provider, appleUid);
        return;
      }

      // new / phone_exists: Firebase signOut 후 약관동의 + 전화번호 인증 플로우
      // (phoneAuth에서 전화번호 credential로 재로그인 + Apple credential link)
      await _auth.signOut();

      PhoneAuthResult? phoneAuthResult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TermsAgreementPage(
                  isSocialLogin: true,
                  provider: provider,
                  prefilledName: (name != null && name.isNotEmpty) ? name : null,
                  hideNameField: true,
                )),
      );

      if (phoneAuthResult == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // new / phone_exists 모두 전화번호 인증 후 서버 회원가입
      final userCredential = await loginService.phoneAuth(
        phoneCredential: phoneAuthResult.credential,
        snsCredential: appleCredential,
        onError: (error) async {
          final authError = await error;
          if (mounted) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showUniqueSnackBar(
              SnackBar(content: Text(authError.message), backgroundColor: Colors.red),
            );
          }
        },
      );
      if (userCredential == null || userCredential.user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // phoneAuth 완료 후 Firebase currentUser가 있는 상태에서 토큰 획득
      await Api().setBaseClient(Api.BASE_URL, quickStart: true);

      final firebaseUser = userCredential.user!;
      final rawName = phoneAuthResult.name ?? name ?? "";
      final userName = rawName.isNotEmpty ? rawName : "사용자";
      await firebaseUser.updateDisplayName(userName);

      final registerUser = my_app.User(
        user_id: 0,
        name: userName,
        email: emailForCheck,
        phone_number: _formatToE164(phoneAuthResult.phoneNumber),
        uid: firebaseUser.uid,
        provider: provider,
      );

      try {
        await Api().client.registerUser(registerUser);
      } catch (e) {
        // 회원가입 실패 시 Firebase 좀비계정 삭제
        await firebaseUser.delete();
        if (!mounted) return;
        setState(() => _loading = false);

        String errorMessage = '회원가입 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = '인터넷 연결을 확인해주세요.';
          } else if (e.response != null) {
            errorMessage = '서버 오류가 발생했습니다.\n(${e.response?.statusCode})';
          }
        }
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('오류'),
            content: Text(errorMessage),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
          ),
        );
        return;
      }

      if (!mounted) return;
      await _loginAndNavigate(emailForCheck, provider, firebaseUser.uid);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginAndNavigate(String emailForCheck, String provider, String uid) async {
    try {
      final response = await Api().client.loginUser(emailForCheck, provider);

      if (!mounted) return;

      if (response.user_id == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showUniqueSnackBar(
          SnackBar(content: Text(response.msg ?? "로그인 정보를 가져오는데 실패했습니다."), backgroundColor: Colors.red),
        );
        return;
      }

      final user = my_app.User(
        user_id: response.user_id ?? -1,
        name: response.name ?? "name",
        email: response.email ?? "email",
        phone_number: response.phone_number ?? "",
        uid: uid,
      );

      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      _registerPushToken(response.user_id ?? -1).catchError((_) {});

      if (!mounted) return;
      setState(() => _loading = false);

      final prefs = await SharedPreferences.getInstance();
      final pendingGifticonId = prefs.getInt('pending_gifticon_id');
      if (!mounted) return;
      if (pendingGifticonId != null) {
        await prefs.remove('pending_gifticon_id');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegisterGifticonPage(gifticon_id: pendingGifticonId)));
      } else if (widget.returnToPrevious && Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TabPage(initialIndex: 0)));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String errorMessage = '서버 오류가 발생했습니다.';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = '인터넷 연결을 확인해주세요.';
      } else if (e.response != null) {
        final statusCode = e.response?.statusCode;
        errorMessage = statusCode == 404 ? '사용자를 찾을 수 없습니다.' : '서버 오류가 발생했습니다.\n($statusCode)';
      }
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('오류'),
          content: Text(errorMessage),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showUniqueSnackBar(
        const SnackBar(content: Text('로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _registerPushToken(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString('fcm_token');

      // SharedPreferences에 토큰이 없으면 Firebase Messaging에서 직접 가져오기
      if (fcmToken == null || fcmToken.isEmpty) {
        try {
          fcmToken = await fetchFcmTokenRespectingIosApns();
          if (fcmToken != null) {
            await prefs.setString('fcm_token', fcmToken);
          }
        } catch (e) {
        }
      }

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      final deviceType = Platform.isIOS ? 'ios' : 'android';
      final allowServicePush = prefs.getBool('service_push_enabled') ?? false;
      final allowMarketingPush =
          prefs.getBool('marketing_push_enabled') ?? false;

      final pushTokenRequest = PushTokenRequest(
        fcmToken: fcmToken,
        deviceType: deviceType,
        allowServicePush: allowServicePush,
        allowMarketingPush: allowMarketingPush,
      );

      await Api().client.registerPushToken(userId, pushTokenRequest);
    } catch (e) {
    }
  }

  Future<void> _startEmailSignUpFlow() async {
    final PhoneAuthResult? phoneAuthResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsAgreementPage()),
    );

    if (phoneAuthResult != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignUpPage(phoneAuthResult: phoneAuthResult),
        ),
      );
    }
  }
}
