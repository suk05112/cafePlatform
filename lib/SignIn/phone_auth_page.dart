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
  const PhoneAuthPage({
    super.key,
    this.isSocialLogin = false,
    this.provider,
  });

  final bool isSocialLogin;
  final String? provider; // SNS provider 또는 "email"

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "전화번호 인증"),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PhoneNumberVerificationWidget(
          isSocialLogin: widget.isSocialLogin,
          provider: widget.provider,
          successCallback: (credential) {
            print("전화번호 인증완료");
            if (credential != null && !_hasNavigated && mounted) {
              _hasNavigated = true;
              print("회원가입 전화번호 인증 성공:");
              Navigator.pop(context, credential);
            } else {
              if (_hasNavigated) {
                print("이미 Navigator.pop이 호출되었습니다.");
              } else {
                print("전화번호 인증 실패 또는 위젯이 dispose되었습니다.");
              }
            }
          },
        ),
      ),
    );
  }
}

class PhoneNumberVerificationWidget extends StatefulWidget {
  const PhoneNumberVerificationWidget({
    super.key,
    required this.successCallback,
    this.isSocialLogin = false,
    this.hideButton = false,
    this.skipRegistrationCheck = false,
    this.provider,
    this.onLoadingChanged,
  });

  final Function(PhoneAuthResult?) successCallback;
  final bool isSocialLogin;
  final bool hideButton;
  final bool skipRegistrationCheck;
  final String? provider;
  final void Function(bool)? onLoadingChanged;

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
  bool _hasCalledSuccessCallback = false;
  bool _handlingAutoVerification = false;
  bool _isLoading = false;

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
    widget.onLoadingChanged?.call(value);
  }

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
          !_hasCalledSuccessCallback &&
          mounted) {
        print("authStateChanges: 자동 인증 완료 감지");
        _handleAutoVerification(user);
      }
    });
  }

  Future<void> _handleAutoVerification(User user) async {
    _handlingAutoVerification = true;
    _setLoading(true);
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

      // 전화번호로 이미 가입된 계정인지 확인 (회원가입 시에만 체크)
      if (!widget.skipRegistrationCheck) {
        await Api().setBaseClient(Api.BASE_URL);
        String e164PhoneNumber = _formatToE164(phoneNumberController.text);

        // provider 정보 가져오기: SNS 로그인일 경우 widget.provider, 이메일 가입일 경우 "email"
        final provider =
            widget.provider ?? (widget.isSocialLogin ? "" : "email");

        final isRegistered = await loginService.isRegisteredUser(null, provider,
            phone: e164PhoneNumber);

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
      }

      // 인증 성공 처리
      // authStateChanges를 통해 감지된 경우, verificationCompleted에서 이미 처리되었을 수 있음
      // 하지만 verificationCompleted가 호출되지 않았을 수도 있으므로 여기서도 처리
      if (mounted) {
        setState(() {
          isVerified = true;
        });

        // verificationId가 있으면 credential 생성하여 successCallback 호출
        if (_verificationId.isNotEmpty && !_hasCalledSuccessCallback) {
          _hasCalledSuccessCallback = true;
          final credential = PhoneAuthProvider.credential(
            verificationId: _verificationId,
            smsCode: validationNumberController.text.isNotEmpty
                ? validationNumberController.text
                : '000000', // 자동 인증의 경우 임시 코드
          );

          widget.successCallback(
            PhoneAuthResult(
              credential: credential,
              phoneNumber: phoneNumberController.text,
              name: name,
            ),
          );
        }

        // 인증 완료 후 로그아웃 (임시 인증이므로)
        await _auth.signOut();
      }
    } on DioException catch (e) {
      // API 호출 실패 처리 - Firebase 계정 롤백
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
      try { await _auth.currentUser?.delete(); } catch (_) {}
      if (mounted) {
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
      try { await _auth.currentUser?.delete(); } catch (_) {}
    } finally {
      _handlingAutoVerification = false;
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
          key: _formKey,
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      foregroundColor: isVerified
                                          ? Colors.grey[600]
                                          : Colors.white,
                                      backgroundColor: isVerified
                                          ? Colors.grey[300]
                                          : ColorAssset.mainColor,
                                      fixedSize: const Size(110, 50)),
                                  onPressed: (isVerified ||
                                          _verificationId.isEmpty ||
                                          _handlingAutoVerification)
                                      ? null
                                      : () async {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            _handlingAutoVerification = true;
                                            _setLoading(true);
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
                                              await _auth.signInWithCredential(
                                                  credential);

                                              // 전화번호로 이미 가입된 계정인지 확인 (회원가입 시에만 체크)
                                              if (!widget
                                                  .skipRegistrationCheck) {
                                                await Api().setBaseClient(
                                                    Api.BASE_URL);
                                                String e164PhoneNumber =
                                                    _formatToE164(
                                                        phoneNumberController
                                                            .text);
                                                final provider =
                                                    widget.provider ??
                                                        (widget.isSocialLogin
                                                            ? ""
                                                            : "email");

                                                bool isRegistered;
                                                try {
                                                  isRegistered =
                                                      await loginService
                                                          .isRegisteredUser(
                                                              null, provider,
                                                              phone:
                                                                  e164PhoneNumber);
                                                } on DioException catch (e) {
                                                  String errorMessage =
                                                      '네트워크 오류가 발생했습니다.';
                                                  if (e.type ==
                                                          DioExceptionType
                                                              .connectionTimeout ||
                                                      e.type ==
                                                          DioExceptionType
                                                              .receiveTimeout ||
                                                      e.type ==
                                                          DioExceptionType
                                                              .sendTimeout) {
                                                    errorMessage =
                                                        '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
                                                  } else if (e.type ==
                                                      DioExceptionType
                                                          .connectionError) {
                                                    errorMessage =
                                                        '인터넷 연결을 확인해주세요.';
                                                  } else if (e.response !=
                                                      null) {
                                                    errorMessage =
                                                        '서버 오류가 발생했습니다.\n(${e.response?.statusCode})';
                                                  }
                                                  // Firebase 계정 롤백 (signOut은 세션만 끊고 계정은 남음)
                                                  try { await _auth.currentUser?.delete(); } catch (_) {}
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content:
                                                          Text(errorMessage),
                                                      duration:
                                                          Duration(seconds: 3),
                                                      backgroundColor:
                                                          Colors.red[700],
                                                    ));
                                                  }
                                                  _handlingAutoVerification =
                                                      false;
                                                  _setLoading(false);
                                                  return;
                                                } catch (e) {
                                                  print(
                                                      "전화번호 가입 확인 오류: $e");
                                                  // Firebase 계정 롤백
                                                  try { await _auth.currentUser?.delete(); } catch (_) {}
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          '서버 오류가 발생했습니다.'),
                                                      duration:
                                                          Duration(seconds: 3),
                                                      backgroundColor:
                                                          Colors.red[700],
                                                    ));
                                                  }
                                                  _handlingAutoVerification =
                                                      false;
                                                  _setLoading(false);
                                                  return;
                                                }

                                                if (isRegistered) {
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
                                              }

                                              // 인증 성공
                                              if (mounted &&
                                                  !_hasCalledSuccessCallback) {
                                                _hasCalledSuccessCallback =
                                                    true;
                                                setState(() {
                                                  isVerified = true;
                                                });

                                                // successCallback 호출
                                                widget.successCallback(
                                                  PhoneAuthResult(
                                                    credential: credential,
                                                    phoneNumber:
                                                        phoneNumberController
                                                            .text,
                                                    name: name,
                                                  ),
                                                );

                                                // 인증 완료 후 로그아웃 (임시 인증이므로)
                                                await _auth.signOut();
                                              }
                                            } on FirebaseAuthException catch (e) {
                                              // 인증 실패
                                              print(
                                                  "Firebase 인증 오류: ${e.code} - ${e.message}");
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
                                            } finally {
                                              _handlingAutoVerification = false;
                                              _setLoading(false);
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
          if (!widget.hideButton)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (isVerified && !_isLoading)
                      ? () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (widget.isSocialLogin &&
                                (name == null || name!.isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("이름을 입력해주세요.")),
                              );
                              return;
                            }

                            if (!mounted) return;

                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId: _verificationId,
                                    smsCode: validationNumberController.text);

                            if (mounted && !_hasCalledSuccessCallback) {
                              _hasCalledSuccessCallback = true;
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
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: ColorAssset.mainColor,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
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

  // 전화번호를 E.164 형식으로 변환 (010-1234-5678 -> +821012345678)
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

  // SMS 인증을 요청합니다.
  void verifyPhoneNumber(String phoneNumber) async {
    // 하이픈 제거 후 E.164 형식으로 변환 (010-1234-5678 -> +821012345678)
    String e164PhoneNumber = _formatToE164(phoneNumber);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: e164PhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android 자동 인증 완료 콜백
        print("verificationCompleted::전화번호 자동 인증 완료");
        // 자동 인증이 완료된 경우 successCallback 호출 (중복 호출 방지)
        if (mounted && !_hasCalledSuccessCallback) {
          _hasCalledSuccessCallback = true;
          setState(() {
            isVerified = true;
          });

          widget.successCallback(
            PhoneAuthResult(
              credential: credential,
              phoneNumber: phoneNumber,
              name: name,
            ),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print("전화번호 인증 실패");
        print(e.code);
        print(e.message);
        if (mounted) {
          String errorMessage = "전화번호 인증에 실패했습니다.";
          if (e.code == 'invalid-phone-number') {
            errorMessage = "유효하지 않은 전화번호입니다.";
          } else if (e.code == 'too-many-requests') {
            errorMessage = "요청이 너무 많습니다. 잠시 후 다시 시도해주세요.";
          } else if (e.code == 'network-request-failed') {
            errorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.";
          } else if (e.message != null) {
            errorMessage = e.message!;
          }

          setState(() {
            isVerified = false;
            isTouched = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 3),
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
