import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/utils/number_formatter.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/widget/input_info_widget.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/SignIn/login_service.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class PhoneAuthResult {
  final PhoneAuthCredential credential;
  final String phoneNumber;
  final String? name;

  PhoneAuthResult({
    required this.credential,
    required this.phoneNumber,
    this.name,
  });
}

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key, this.isSocialLogin = false});

  final bool isSocialLogin;

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Scaffold 추가
        appBar: const CommonAppBar(title: "전화번호 인증"),
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PhoneNumberVerificationWidget(
              isSocialLogin: widget.isSocialLogin,
              successCallback: (credential) {
                print("전화번호 인증완료");
                // 여기서 phoneNumber 변수에 인증된 전화번호가 들어옵니다.
                if (credential != null) {
                  print("회원가입 전화번호 인증 성공:");
                  Navigator.pop(context, credential);
                } else {
                  print("전화번호 인증 실패");
                }
              },
            )));
  }
}

class PhoneNumberVerificationWidget extends StatefulWidget {
  const PhoneNumberVerificationWidget(
      {super.key, required this.successCallback, this.isSocialLogin = false});

  final Function(PhoneAuthResult?) successCallback;
  final bool isSocialLogin;

  @override
  State<PhoneNumberVerificationWidget> createState() =>
      _PhoneNumberVerificationWidgetState();
}

class _PhoneNumberVerificationWidgetState
    extends State<PhoneNumberVerificationWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final loginService = LoginService();
  String _verificationId = "";
  bool isTouched = false;
  bool isVerified = false; // 인증 완료 여부
  String? name;
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<User?>? _authStateSubscription;
  bool _handlingAutoVerification = false; // 자동 인증 처리 중 플래그

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController validationNumberController = TextEditingController();

  final inputDecoration = InputDecoration(
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
  );

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "이름을 입력해주세요.";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Firebase Auth 상태 변경 리스너 설정 (자동 인증 처리용)
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null &&
          !_handlingAutoVerification &&
          !isVerified &&
          mounted) {
        // 자동 인증이 완료된 경우 (Android SMS 자동 인증)
        print("authStateChanges: 자동 인증 완료 감지");
        _handleAutoVerification(user);
      }
    });
  }

  Future<void> _handleAutoVerification(User user) async {
    _handlingAutoVerification = true;
    try {
      // 인증번호 입력 필드가 비어있으면 자동 인증을 무시 (수동 입력을 기다림)
      if (validationNumberController.text.trim().isEmpty) {
        print("자동 인증 감지되었으나 인증번호 입력 필드가 비어있어 무시");
        if (mounted) {
          await _auth.signOut();
        }
        _handlingAutoVerification = false;
        return;
      }

      // 전화번호로 이미 가입된 계정인지 확인
      await Api().setBaseClient(Api.BASE_URL);
      String digitsOnly =
          phoneNumberController.text.replaceAll(RegExp(r'[^\d]'), '');
      String e164PhoneNumber = '+82$digitsOnly';

      final isRegistered =
          await loginService.isRegisteredUserByPhone(e164PhoneNumber);

      if (isRegistered) {
        // 이미 가입된 계정
        if (mounted) {
          await _auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('이미 가입된 전화번호입니다.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red[700],
            ),
          );
        }
        _handlingAutoVerification = false;
        return;
      }

      // 인증 성공 처리
      if (mounted) {
        setState(() {
          isVerified = true;
        });
        // 인증 완료 후 로그아웃 (임시 인증이므로)
        await _auth.signOut();
      }
    } on DioException catch (e) {
      // API 호출 실패 처리
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
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      print("자동 인증 처리 오류: $e");
      if (mounted) {
        await _auth.signOut();
      }
    } finally {
      _handlingAutoVerification = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 이름 입력 필드 (간편로그인일 때만 노출)
                      if (widget.isSocialLogin) ...[
                        InputInfoWidget(
                          title: "이름",
                          hintText: "이름을 입력해주세요",
                          validator: _validateName,
                          onChanged: (newName) {
                            setState(() {
                              name = newName;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text(
                        "전화번호",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      // const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // FilteringTextInputFormatter.digitsOnly, //숫자만!
                                NumberFormatter(), // 자동하이픈
                                LengthLimitingTextInputFormatter(13)
                              ],
                              decoration: inputDecoration.copyWith(
                                  hintText: "휴대폰 번호를 입력하세요"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "잘못된 전화번호입니다. 다시 입력하세요";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: ColorAssset.mainColor,
                                fixedSize: const Size(110, 50)),
                            onPressed: () {
                              final phoneNumber = phoneNumberController.text;
                              // 전화번호 형식 검증 (3-4-4 형식: 010-1234-5678)
                              final phonePattern = RegExp(r'^010-\d{4}-\d{4}$');
                              if (!phonePattern.hasMatch(phoneNumber)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '전화번호 형식이 올바르지 않습니다. (예: 010-1234-5678)'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.grey[800],
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isTouched = true;
                              });
                              verifyPhoneNumber(phoneNumberController.text);
                              // verifyPhoneNumber("+821025446458");
                              // verifyPhoneNumber("+821012345678");
                            },
                            child: isTouched ? Text('재전송') : Text('인증'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Visibility(
                          visible: isTouched,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "인증번호",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      controller: validationNumberController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: inputDecoration.copyWith(
                                        hintText: "인증번호를 입력하세요",
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "잘못된 인증번호입니다. 다시 입력하세요";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        foregroundColor: isVerified
                                            ? Colors.grey[600]
                                            : Colors.white,
                                        backgroundColor: isVerified
                                            ? Colors.grey[300]
                                            : ColorAssset.mainColor,
                                        fixedSize: const Size(110, 50)),
                                    onPressed: (isVerified ||
                                            _verificationId.isEmpty)
                                        ? null
                                        : () async {
                                            if (_formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              // 실제 Firebase 인증 검증
                                              try {
                                                PhoneAuthCredential credential =
                                                    PhoneAuthProvider.credential(
                                                        verificationId:
                                                            _verificationId,
                                                        smsCode:
                                                            validationNumberController
                                                                .text);

                                                // 인증번호 검증
                                                await _auth
                                                    .signInWithCredential(
                                                        credential);

                                                // 전화번호로 이미 가입된 계정인지 확인
                                                try {
                                                  await Api().setBaseClient(
                                                      Api.BASE_URL);
                                                  // 전화번호를 E.164 형식으로 변환 (010-1234-5678 -> +821012345678)
                                                  String digitsOnly =
                                                      phoneNumberController.text
                                                          .replaceAll(
                                                              RegExp(r'[^\d]'),
                                                              '');
                                                  String e164PhoneNumber =
                                                      '+82$digitsOnly';

                                                  final isRegistered =
                                                      await loginService
                                                          .isRegisteredUserByPhone(
                                                              e164PhoneNumber);

                                                  if (isRegistered) {
                                                    // 이미 가입된 계정
                                                    if (mounted) {
                                                      await _auth.signOut();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              '이미 가입된 전화번호입니다.'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                          backgroundColor:
                                                              Colors.red[700],
                                                        ),
                                                      );
                                                    }
                                                    return;
                                                  }
                                                } on DioException catch (e) {
                                                  // API 호출 실패 시에도 인증은 진행 (서버 오류일 수 있음)
                                                  print(
                                                      "전화번호 가입 확인 API 오류: $e");
                                                } catch (e) {
                                                  print("전화번호 가입 확인 오류: $e");
                                                }

                                                // 인증 성공
                                                if (mounted) {
                                                  setState(() {
                                                    isVerified = true;
                                                  });
                                                  // 인증 완료 후 로그아웃 (임시 인증이므로)
                                                  await _auth.signOut();
                                                }
                                              } on FirebaseAuthException catch (e) {
                                                // 인증 실패
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '인증번호가 올바르지 않습니다.'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                      backgroundColor:
                                                          Colors.red[700],
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                // 기타 오류
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '인증 중 오류가 발생했습니다.'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                      backgroundColor:
                                                          Colors.red[700],
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                    child: Text(
                                      isVerified ? '인증완료' : '인증확인',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ])
                              ])),
                    ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isVerified
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (widget.isSocialLogin &&
                              (name == null || name!.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("이름을 입력해주세요.")),
                            );
                            return;
                          }

                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                                  verificationId: _verificationId,
                                  smsCode: validationNumberController.text);

                          widget.successCallback(
                            PhoneAuthResult(
                              credential: credential,
                              // phoneNumber: "+821025446458",
                              phoneNumber: phoneNumberController.text,
                              name: name,
                            ),
                          );
                        }
                      }
                    : null,
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
                child: const Text(
                  '다음',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    phoneNumberController.dispose();
    validationNumberController.dispose();
    super.dispose();
  }

  // SMS 인증을 요청합니다.
  void verifyPhoneNumber(String phoneNumber) async {
    // 하이픈 제거 후 E.164 형식으로 변환 (010-1234-5678 -> +821012345678)
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    String e164PhoneNumber = '+82$digitsOnly';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: e164PhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android 자동 인증 완료 콜백
        // 사용자가 인증번호를 수동으로 입력하도록 하기 위해 자동 인증을 무시
        print("verificationCompleted::전화번호 자동 인증 완료 (무시 - 수동 입력 필요)");
        // 자동 인증을 무시하고 사용자가 수동으로 인증번호를 입력하도록 함
        // await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("전화번호 인증 실패");
        print(e.code);
        // 인증 실패 콜백 함수
        print(e.message);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('인증 실패: ${e.message ?? "전화번호 인증에 실패했습니다."}'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        print("코드 보내짐");
        print(verificationId);
        // 코드가 성공적으로 보내진 경우
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
          // 토스트 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('인증번호가 전송되었습니다.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.grey[800],
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("SMS 자동 인식 타임아웃 (수동 입력 가능)");
        // 타임아웃 콜백 함수 - SMS 자동 인식이 타임아웃되었지만,
        // verificationId는 여전히 유효하므로 수동으로 인증번호를 입력하여 인증할 수 있습니다.
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
    );
  }
}
