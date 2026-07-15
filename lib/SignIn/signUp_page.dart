import 'dart:async';

import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/utils/analytics_service.dart';
import 'package:cafeplatform/utils/meta_analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeplatform/SignIn/login_service.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/model/user.dart' as my_app;
import 'package:cafeplatform/widget/input_info_widget.dart';
import 'package:dio/dio.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/utils/fcm_token_util.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:cafeplatform/SignIn/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.phoneAuthResult});

  final PhoneAuthResult phoneAuthResult;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // 뒤로가기 시 전화번호 인증 페이지로 돌아가기
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneAuthPage(
                isSocialLogin: false,
                provider: "email",
              ),
            ),
          );
        }
      },
      child: GestureDetector(
          onTap: () {
            //FocusManager.instance.primaryFocus?.unfocus();
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: const CommonAppBar(title: "회원가입"),
              body: SafeArea(
                child: BasicInfoFormWidget(
                    phoneAuthResult: widget.phoneAuthResult),
              ))),
    );
  }
}

class BasicInfoFormWidget extends StatefulWidget {
  const BasicInfoFormWidget({super.key, required this.phoneAuthResult});

  final PhoneAuthResult phoneAuthResult;

  @override
  State<BasicInfoFormWidget> createState() => _BasicInfoFormWidgetState();
}

class _BasicInfoFormWidgetState extends State<BasicInfoFormWidget> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  final loginService = LoginService();
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  String? name;
  String? email; // 이메일 값을 저장
  late final String phoneNumber;
  late final PhoneAuthCredential phoneCredential;

  String? password;
  String? confirmPassword; // 비밀번호 확인 값
  bool _loading = false; // 로딩 상태

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phoneAuthResult.phoneNumber;
    phoneCredential = widget.phoneAuthResult.credential;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 0),
                child: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            // 상단 제목 영역
                            // Text(
                            //   '회원가입',
                            //   style: TextStyle(
                            //     fontSize: 24,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.black,
                            //   ),
                            // ),
                            // SizedBox(height: 40),
                            InputInfoWidget(
                              title: "이름",
                              hintText: "이름을 입력해주세요",
                              validator: validateName,
                              onChanged: (newName) {
                                setState(() {
                                  name = newName;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              "전화번호",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                              ),
                              child: Text(
                                _formatPhoneNumber(phoneNumber),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 28),
                            IDVerificationWidget(
                              formKey: formKey2,
                              onEmailChanged: (newEmail) {
                                setState(() {
                                  email = newEmail; // 이메일 값 업데이트
                                });
                              },
                            ), //아이디
                            SizedBox(height: 20),
                            InputInfoWidget(
                              title: "비밀번호",
                              hintText: "비밀번호를 입력해주세요",
                              hidePassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "비밀번호를 입력해주세요";
                                }
                                return null;
                              },
                              onChanged: (newPassword) {
                                setState(() {
                                  password = newPassword;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            InputInfoWidget(
                              title: "비밀번호 확인",
                              hintText: "비밀번호를 입력해주세요",
                              hidePassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "비밀번호를 입력해주세요";
                                }
                                return null;
                              },
                              onChanged: (newConfirmPassword) {
                                setState(() {
                                  confirmPassword = newConfirmPassword;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                          ])),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            if (password != confirmPassword) {
                              CommonDialog.show(
                                context: context,
                                title: "비밀번호 확인",
                                content: "비밀번호가 일치하지 않습니다.",
                                buttonText: "확인",
                                onPressed: () {},
                              );
                              return;
                            }

                            setState(() {
                              _loading = true;
                            });
                            signUpWithEmail(email ?? "", password ?? "");
                          } else {
                            return;
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorAssset.mainColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
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
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ));
  }

  // 이메일과 비밀번호를 사용하여 Firebase Authentication에 새 사용자를 만듭니다.
  void signUpWithEmail(String email, String password) async {
    debugPrint('[SignUp] signUpWithEmail 시작 email=$email phone=$phoneNumber name=$name');
    try {
      if (name == null || name!.isEmpty) {
        setState(() { _loading = false; });
        CommonDialog.show(
            context: context,
            title: "입력 오류",
            content: "이름을 입력해주세요.",
            buttonText: "확인",
            onPressed: () {});
        return;
      }

      if (phoneNumber.isEmpty) {
        setState(() { _loading = false; });
        CommonDialog.show(
            context: context,
            title: "입력 오류",
            content: "전화번호가 없습니다.",
            buttonText: "확인",
            onPressed: () {});
        return;
      }

      final emailCredential = EmailAuthProvider.credential(
        email: email + "@gifnut.com",
        password: password,
      );
      debugPrint('[SignUp] phoneCredential로 signInWithCredential 호출 전 currentUser=${FirebaseAuth.instance.currentUser?.uid}');
      final phoneLogin = await FirebaseAuth.instance.signInWithCredential(
        phoneCredential,
      );
      debugPrint('[SignUp] signInWithCredential 완료 uid=${phoneLogin.user?.uid} phone=${phoneLogin.user?.phoneNumber} providers=${phoneLogin.user?.providerData.map((p) => p.providerId).toList()} isNew=${phoneLogin.additionalUserInfo?.isNewUser}');

      final fbUser = phoneLogin.user;

      if (fbUser == null) {
        debugPrint('[SignUp] fbUser null → 전화번호 인증 실패');
        if (mounted) {
          setState(() { _loading = false; });
        }
        CommonDialog.show(
            context: context,
            title: "오류",
            content: "전화번호 인증 실패",
            buttonText: "확인",
            onPressed: () {});
        return;
      }

      UserCredential? linkResult;
      User? linkedUser;

      debugPrint('[SignUp] linkWithCredential(email) 시도 email=${email}@gifnut.com');
      try {
        linkResult = await fbUser.linkWithCredential(emailCredential);
        linkedUser = linkResult.user;
        debugPrint('[SignUp] linkWithCredential 성공 uid=${linkedUser?.uid} providers=${linkedUser?.providerData.map((p) => p.providerId).toList()}');
      } on FirebaseAuthException catch (linkError) {
        debugPrint('[SignUp] linkWithCredential 실패 code=${linkError.code} msg=${linkError.message}');
        if (linkError.code == 'provider-already-linked') {
          linkedUser = fbUser;
          debugPrint('[SignUp] provider-already-linked → 기존 fbUser 사용 uid=${fbUser.uid}');
        } else {
          rethrow;
        }
      }

      if (linkedUser != null) {
        debugPrint('[SignUp] registerUser API 호출 uid=${linkedUser.uid}');
        try {
          final formattedPhoneNumber = _formatToE164(phoneNumber);
          final emailWithDomain = email + "@gifnut.com";

          final registerUser = my_app.User(
            user_id: 0,
            name: name!,
            email: emailWithDomain,
            phone_number: formattedPhoneNumber,
            uid: linkedUser.uid,
            provider: "email",
            agreements: widget.phoneAuthResult.agreements,
          );

          await Api().setBaseClient(Api.BASE_URL);
          final registerResponse =
              await Api().client.registerUser(registerUser);
          debugPrint('[SignUp] registerUser 성공 userId=${registerResponse.userId}');

          AnalyticsService.instance.logSignUp();
          MetaAnalyticsService.instance.logStartTrial();

          _registerPushToken(registerResponse.userId).catchError((error) { debugPrint('[SignUp] registerPushToken 실패: $error'); });

          debugPrint('[SignUp] Firebase signOut 호출');
          await FirebaseAuth.instance.signOut();
          debugPrint('[SignUp] Firebase signOut 완료');

          if (mounted) {
            setState(() {
              _loading = false;
            });

            // 가입 완료 메시지 표시
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    '가입 완료',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    '가입이 완료되었습니다.\n다시 로그인해주세요.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // 다이얼로그 닫은 후 로그인 페이지로 이동
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        } on DioException catch (e) {
          debugPrint('[SignUp] registerUser DioException: ${e.type} status=${e.response?.statusCode} body=${e.response?.data}');
          try { await linkedUser!.delete(); debugPrint('[SignUp] Firebase 계정 rollback 완료'); } catch (de) { debugPrint('[SignUp] rollback 실패: $de'); }
          String errorMessage = "회원가입 중 서버 오류가 발생했습니다.";
          if (e.response != null) {
            final statusCode = e.response?.statusCode;
            if (statusCode == 400) {
              errorMessage = "입력 정보가 올바르지 않습니다.";
            } else if (statusCode == 409) {
              errorMessage = "이미 등록된 사용자입니다.";
            } else if (statusCode == 500) {
              errorMessage = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
            }
          }
          if (mounted) {
            setState(() { _loading = false; });
            CommonDialog.show(
                context: context,
                title: "회원가입 오류",
                content: errorMessage,
                buttonText: "확인",
                onPressed: () {});
          }
        } catch (e) {
          debugPrint('[SignUp] registerUser 기타 예외: $e');
          try { await linkedUser!.delete(); debugPrint('[SignUp] Firebase 계정 rollback 완료'); } catch (de) { debugPrint('[SignUp] rollback 실패: $de'); }
          if (mounted) {
            setState(() { _loading = false; });
            CommonDialog.show(
                context: context,
                title: "오류",
                content: "회원가입 중 오류가 발생했습니다.",
                buttonText: "확인",
                onPressed: () {});
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[SignUp] FirebaseAuthException code=${e.code} msg=${e.message}');
      if (mounted) {
        setState(() { _loading = false; });
      }
      String errorMessage = "회원가입 중 오류가 발생했습니다.";
      switch (e.code) {
        case 'weak-password':
          errorMessage = ("비밀번호가 너무 약합니다. 더 강한 비밀번호를 설정해주세요.");
          break;

        case 'email-already-in-use':
          errorMessage = "이미 사용 중인 이메일입니다. 다른 이메일을 입력해주세요.";
          break;

        case 'invalid-email':
          errorMessage = "잘못된 이메일 형식입니다.";
          break;

        case 'credential-already-in-use':
          errorMessage = "이미 다른 계정에 연결된 자격증명입니다.";
          break;

        case 'provider-already-linked':
          // 이미 링크되어 있는 경우는 위에서 처리되므로 여기서는 일반 오류 처리
          errorMessage = "이미 가입된 계정입니다.";
          break;

        case 'requires-recent-login':
          errorMessage = "보안상 재로그인이 필요합니다. 다시 로그인 후 시도해주세요.";
          break;

        case 'invalid-credential':
          errorMessage = "잘못된 인증정보입니다.";
          break;

        default:
          errorMessage = "알 수 없는 오류가 발생했습니다: ${e.code}";
      }

      CommonDialog.show(
          context: context,
          title: "회원가입 오류",
          content: errorMessage,
          buttonText: "확인",
          onPressed: () {});
    } catch (e) {
      debugPrint('[SignUp] 최상단 catch 예외: $e');
      if (mounted) {
        setState(() { _loading = false; });
      }
      CommonDialog.show(
          context: context,
          title: "오류",
          content: "예기치 않은 오류가 발생했습니다.",
          buttonText: "확인",
          onPressed: () {});
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "이름을 입력해주세요.";
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "빈 문자열";
    }
    return null;
  }

  String _formatPhoneNumber(String phoneNumber) {
    // +82 형식을 010 형식으로 변환
    if (phoneNumber.startsWith('+82')) {
      String number = phoneNumber.substring(3); // +82 제거
      if (number.startsWith('10')) {
        return '0$number';
      } else if (number.startsWith('1')) {
        return '0$number';
      }
      return '0$number';
    }
    return phoneNumber;
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

      await Api().setBaseClient(Api.BASE_URL);
      await Api().client.registerPushToken(userId, pushTokenRequest);
    } catch (e) {
    }
  }
}

class IDVerificationWidget extends StatefulWidget {
  final Function(String) onEmailChanged; // 이메일 변경 시 호출되는 콜백
  final GlobalKey<FormState> formKey;
  const IDVerificationWidget(
      {super.key, required this.onEmailChanged, required this.formKey});

  @override
  State<IDVerificationWidget> createState() => _IDVerificationWidgetState();
}

class _IDVerificationWidgetState extends State<IDVerificationWidget> {
  TextEditingController idController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  var hasRecipe = false;

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "아이디",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: idController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "아이디 입력하세요",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                onChanged: (text) async {
                  final check = await checkEmail(text);
                  setState(() => hasRecipe = check);
                  widget.onEmailChanged(text); // 부모에게 이메일 값 전달
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "이메일을 입력해주세요.";
                  }

                  // if (hasRecipe == false) {
                  //   return "중복된 이메일 입니다. 다른 이메일을 입력해주세요.";
                  // }

                  if (isValidEmail(value) == false) {
                    return "이메일 형식이 올바르지 않습니다. 올바른 이메일을 입력해주세요.\n Ex) example123@naver.com";
                  }

                  return null;
                },
              ),
            ]));
  }

  bool isValidEmail(String email) {
    const pattern = r'^[A-Za-z0-9_\.\-]+@[A-Za-z0-9\-]+\.[A-za-z0-9\-]+';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<bool> checkEmail(String email) async {
    return Future<bool>.value(true);
  }
}
