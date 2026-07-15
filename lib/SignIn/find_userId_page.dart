import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/SignIn/find_password_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/find_account_request.dart';

import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

class FindUserIDPage extends StatefulWidget {
  const FindUserIDPage({super.key});

  @override
  State<FindUserIDPage> createState() => _FindUserIDPageState();
}

class _FindUserIDPageState extends State<FindUserIDPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController inputPhoneNumbfController = TextEditingController();

  String? verifiedPhoneNumber;
  bool _isLoading = false;
  PhoneAuthCredential? phoneCredential;

  final inputDecoration = const InputDecoration(
      border: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(8.0),
          // borderSide: const BorderSide(
          //   color: Colors.redAccent,
          //   width: 2,
          ));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: const CommonAppBar(title: "아이디 찾기"),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(27, 20, 27, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "이름",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            decoration: inputDecoration.copyWith(
                              hintText: "이름을 입력해주세요",
                            ),
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 30),
                          PhoneNumberVerificationWidget(
                            hideButton: true,
                            skipRegistrationCheck: true,
                            successCallback: (phoneAuthResult) {
                              if (phoneAuthResult != null) {
                                setState(() {
                                  verifiedPhoneNumber =
                                      phoneAuthResult.phoneNumber;
                                  phoneCredential = phoneAuthResult.credential;
                                  _isLoading = false;
                                });
                              } else {
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(27, 0, 27, 20),
                    width: double.infinity,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: ColorAssset.mainColor,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        onPressed: (_isLoading ||
                                nameController.text.isEmpty ||
                                verifiedPhoneNumber == null)
                            ? null
                            : () async {
                                await _findAccountId();
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text("확인"),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  @override
  void dispose() {
    nameController.dispose();
    inputPhoneNumbfController.dispose();
    super.dispose();
  }

  Future<void> _findAccountId() async {
    if (nameController.text.isEmpty || verifiedPhoneNumber == null) {
      CommonDialog.show(
        context: context,
        title: "입력 오류",
        content: "이름과 전화번호 인증을 완료해주세요.",
        buttonText: "확인",
        onPressed: () {},
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Api().setBaseClient(Api.BASE_URL);

      // 전화번호를 서버 형식으로 변환 (010-1234-5678 -> +821012345678)
      final phoneDigits = verifiedPhoneNumber!.replaceAll(RegExp(r'[^\d]'), '');
      String formattedPhone;
      if (phoneDigits.startsWith('0')) {
        // 010으로 시작하면 0을 제거하여 +8210... 형식으로 변환
        formattedPhone = '+82${phoneDigits.substring(1)}';
      } else if (phoneDigits.startsWith('82')) {
        formattedPhone = '+$phoneDigits';
      } else {
        formattedPhone = '+82$phoneDigits';
      }

      final request = FindAccountRequest(
        name: nameController.text.trim(),
        phoneNumber: formattedPhone,
        type: 'find_id',
      );

      final response = await Api().client.findAccount(request);

      if (response.success && response.type == 'find_id') {
        // 아이디 찾기 성공
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterdIDPage(
                email: response.email ?? '',
                fullEmail: response.fullEmail ?? '',
                created_time: null,
              ),
            ),
          );
        }
      } else {
        CommonDialog.show(
          context: context,
          title: "아이디 찾기 실패",
          content: response.message,
          buttonText: "확인",
          onPressed: () {},
        );
      }
    } on DioException catch (e) {
      String errorMsg = "오류가 발생했습니다.";
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          final detail = e.response?.data?['detail'];
          errorMsg = (detail is String && detail.isNotEmpty)
              ? detail
              : "입력하신 정보와 일치하는 계정을 찾을 수 없습니다.";
        } else if (e.response!.statusCode == 404) {
          errorMsg = "입력하신 정보와 일치하는 계정을 찾을 수 없습니다.";
        } else if (e.response!.statusCode == 500) {
          errorMsg = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
        } else {
          errorMsg = e.response?.data?['message'] ?? "오류가 발생했습니다.";
        }
      } else {
        errorMsg = "네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
      }

      CommonDialog.show(
        context: context,
        title: "아이디 찾기 실패",
        content: errorMsg,
        buttonText: "확인",
        onPressed: () {},
      );
    } catch (e) {
      CommonDialog.show(
        context: context,
        title: "오류",
        content: "알 수 없는 오류가 발생했습니다: $e",
        buttonText: "확인",
        onPressed: () {},
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class RegisterdIDPage extends StatefulWidget {
  const RegisterdIDPage({
    super.key,
    required this.email,
    this.fullEmail,
    this.created_time,
    this.msg,
  });

  final String email; // 마스킹된 이메일
  final String? fullEmail; // 전체 이메일
  final String? created_time;
  final String? msg;

  @override
  State<RegisterdIDPage> createState() => _RegisterdIDPageState();
}

class _RegisterdIDPageState extends State<RegisterdIDPage> {
  TextEditingController inputIDController = TextEditingController();

  @override
  void dispose() {
    inputIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("아이디 찾기"),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
          child: Column(
            // 세로 컬럼 생성
            mainAxisAlignment: MainAxisAlignment.center, // 새로축 가운데 정렬
            children: <Widget>[
              Spacer(),
              // 컬럼에 들어갈 위젯들
              const Text(
                "가입하신 아이디는 아래와 같습니다.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "아이디: ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.fullEmail ?? widget.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.created_time != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        "가입일: ${widget.created_time}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FindPasswordPage()),
                    );
                  },
                  child: Text("비밀번호 재설정하기"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: double.infinity, // <-- match_parent
                height: 50, // <-- match-parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: ColorAssset.mainColor,
                    // minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text("로그인 하러 가기"),
                ),
              )
            ],
          ),
        ));
  }
}
