import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeplatform/SignIn/login_service.dart';
import 'package:cafeplatform/SignIn/singUp_completed_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/model/user.dart' as my_app;
import 'package:cafeplatform/widget/input_info_widget.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:dio/dio.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.phoneAuthResult});

  final PhoneAuthResult phoneAuthResult;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //FocusManager.instance.primaryFocus?.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BasicInfoFormWidget(
                            phoneAuthResult: widget.phoneAuthResult)
                      ])),
            )));
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

  final loginService = LoginService();
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  String? name;
  String? email; // 이메일 값을 저장
  late final String phoneNumber;
  late final PhoneAuthCredential phoneCredential;

  String? password;
  String? confirmPassword; // 비밀번호 확인 값

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
                      Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 40),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: Text(
                          phoneNumber,
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
                      SizedBox(height: 50),
                      // 확인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
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

                              signUpWithEmail(email ?? "", password ?? "");
                            } else {
                              return;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // 로그인 페이지로 이동
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                    ]))));
  }

  // 이메일과 비밀번호를 사용하여 Firebase Authentication에 새 사용자를 만듭니다.
  void signUpWithEmail(String email, String password) async {
    try {
      // 이름과 전화번호 검증
      if (name == null || name!.isEmpty) {
        CommonDialog.show(
            context: context,
            title: "입력 오류",
            content: "이름을 입력해주세요.",
            buttonText: "확인",
            onPressed: () {});
        return;
      }

      if (phoneNumber.isEmpty) {
        CommonDialog.show(
            context: context,
            title: "입력 오류",
            content: "전화번호가 없습니다.",
            buttonText: "확인",
            onPressed: () {});
        return;
      }

      final emailCredential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final phoneLogin = await FirebaseAuth.instance.signInWithCredential(
        phoneCredential,
      );

      final fbUser = phoneLogin.user;

      if (fbUser == null) {
        CommonDialog.show(
            context: context,
            title: "오류",
            content: "전화번호 인증 실패",
            buttonText: "확인",
            onPressed: () {});
        return null;
      }

      final linkResult = await fbUser.linkWithCredential(emailCredential);

      if (linkResult.user != null) {
        // 회원가입 API 호출 - 이름과 전화번호를 서버에 전달
        try {
          final registerUser = my_app.User(
            user_id: 0, // 회원가입 시에는 0으로 설정 (서버에서 생성)
            name: name!,
            email: email,
            phone_number: phoneNumber,
          );

          final registerResponse =
              await Api().client.registerUser(registerUser);
          print("회원가입 API 호출 후 response $registerResponse");

          // 회원가입 성공 후 로그인 API 호출
          var response = await Api().client.loginUser(email);
          print("로그인 api 호출후 response $response");

          final user = my_app.User(
            user_id: response.user_id ?? -1,
            name: response.name ?? name!,
            email: response.email ?? email,
            phone_number: response.phone_number ?? phoneNumber,
          );
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SignUpCompletePage()));
        } on DioException catch (e) {
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
          CommonDialog.show(
              context: context,
              title: "회원가입 오류",
              content: errorMessage,
              buttonText: "확인",
              onPressed: () {});
        } catch (e) {
          print("회원가입 API 오류: $e");
          CommonDialog.show(
              context: context,
              title: "오류",
              content: "회원가입 중 오류가 발생했습니다.",
              buttonText: "확인",
              onPressed: () {});
        }
      }
    } on FirebaseAuthException catch (e) {
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
          errorMessage = "이미 이메일 로그인 방법이 연결된 계정입니다.";
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
      print('errorMessage: $errorMessage');

      CommonDialog.show(
          context: context,
          title: "회원가입 오류",
          content: errorMessage,
          buttonText: "확인",
          onPressed: () {});
    } catch (e) {
      print(e);
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
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "이메일",
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
                  hintText: "이메일을 입력하세요",
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
                  print("id validator 호출");
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

  final inputDecoration = InputDecoration(
    // isDense: true,
    border: UnderlineInputBorder(
        // borderRadius: BorderRadius.circular(8.0),
        // borderSide: const BorderSide(
        //   color: Colors.redAccent,
        //   width: 2,
        // )
        ),
  );
}
