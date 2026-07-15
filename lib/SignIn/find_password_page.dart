import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/find_account_request.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({super.key});

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController inputIDController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? verifiedPhoneNumber;
  PhoneAuthCredential? phoneCredential;
  bool _isLoading = false;
  bool _showPasswordReset = false; // 비밀번호 재설정 화면 표시 여부

  bool _obscurePassword = true; // 비밀번호 숨김/표시
  bool _obscureConfirmPassword = true; // 비밀번호 확인 숨김/표시

  final inputDecoration = InputDecoration(
      border: UnderlineInputBorder(
          // borderRadius: BorderRadius.circular(8.0),
          // borderSide: const BorderSide(
          //   color: Colors.redAccent,
          //   width: 2,
          // )
          ));

  @override
  void dispose() {
    nameController.dispose();
    inputIDController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 비밀번호 재설정 화면
    if (_showPasswordReset) {
      return _buildPasswordResetScreen();
    }

    // 이름, 전화번호 입력 화면
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: const CommonAppBar(title: "비밀번호 찾기"),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(27, 20, 27, 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "이름을 입력해주세요";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "아이디 입력",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: inputIDController,
                              keyboardType: TextInputType.text,
                              decoration: inputDecoration.copyWith(
                                hintText: "아이디를 입력해주세요",
                              ),
                              enabled: !_isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "아이디를 입력해주세요";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            PhoneNumberVerificationWidget(
                              hideButton: true,
                              skipRegistrationCheck: true,
                              successCallback: (phoneAuthResult) {
                                if (phoneAuthResult != null) {
                                  print(
                                      "전화번호 인증 성공: ${phoneAuthResult.phoneNumber}");
                                  setState(() {
                                    verifiedPhoneNumber =
                                        phoneAuthResult.phoneNumber;
                                    phoneCredential =
                                        phoneAuthResult.credential;
                                  });
                                } else {
                                  print("전화번호 인증 실패");
                                }
                              },
                            ),
                          ],
                        ),
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
                                inputIDController.text.isEmpty ||
                                verifiedPhoneNumber == null)
                            ? null
                            : () async {
                                await _verifyAccount();
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

  Widget _buildPasswordResetScreen() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CommonAppBar(title: "비밀번호 재설정"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(27, 20, 27, 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "새 비밀번호",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "새 비밀번호를 입력해주세요",
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
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "비밀번호를 입력해주세요";
                            }
                            if (value.length < 6) {
                              return "비밀번호는 6자 이상이어야 합니다";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "비밀번호 확인",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: "비밀번호를 다시 입력해주세요",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "비밀번호를 다시 입력해주세요";
                            }
                            if (value != newPasswordController.text) {
                              return "비밀번호가 일치하지 않습니다";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await _resetPassword();
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("비밀번호 변경"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyAccount() async {
    if (!formKey.currentState!.validate()) return;
    if (nameController.text.isEmpty ||
        inputIDController.text.isEmpty ||
        verifiedPhoneNumber == null) {
      CommonDialog.show(
        context: context,
        title: "입력 오류",
        content: "모든 정보를 입력해주세요.",
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
        type: 'find_password',
      );

      final response = await Api().client.findAccount(request);

      if (response.success &&
          response.type == 'find_password' &&
          response.verified == true) {
        // Firebase 전화번호 인증으로 로그인
        if (phoneCredential != null) {
          final phoneLogin = await _auth.signInWithCredential(phoneCredential!);
          if (phoneLogin.user != null) {
            // 비밀번호 재설정 화면 표시
            if (mounted) {
              setState(() {
                _showPasswordReset = true;
                _isLoading = false;
              });
            }
          } else {
            throw Exception("Firebase 로그인 실패");
          }
        } else {
          throw Exception("전화번호 인증이 완료되지 않았습니다");
        }
      } else {
        CommonDialog.show(
          context: context,
          title: "인증 실패",
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
        title: "인증 실패",
        content: errorMsg,
        buttonText: "확인",
        onPressed: () {},
      );
    } catch (e) {
      CommonDialog.show(
        context: context,
        title: "오류",
        content: "오류가 발생했습니다: $e",
        buttonText: "확인",
        onPressed: () {},
      );
    } finally {
      if (mounted && !_showPasswordReset) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      CommonDialog.show(
        context: context,
        title: "비밀번호 오류",
        content: "비밀번호가 일치하지 않습니다.",
        buttonText: "확인",
        onPressed: () {},
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase에 현재 로그인된 사용자가 있는지 확인
      // 로그인되어 있지 않으면 전화번호 인증으로 다시 로그인
      if (phoneCredential != null) {
        await _auth.signInWithCredential(phoneCredential!);
      } else {
        throw Exception("인증 정보가 없습니다");
      }

      // 비밀번호 업데이트
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPasswordController.text);

        if (mounted) {
          CommonDialog.show(
            context: context,
            title: "비밀번호 변경 완료",
            content: "비밀번호가 변경되었습니다. 로그인해주세요.",
            buttonText: "확인",
            onPressed: () {
              Future.microtask(() {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              });
            },
          );
        }
      } else {
        throw Exception("사용자 정보를 찾을 수 없습니다");
      }
    } catch (e) {
      CommonDialog.show(
        context: context,
        title: "오류",
        content: "비밀번호 변경 중 오류가 발생했습니다: $e",
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

//   Future<void> checkEmailExists(String emailAddress) async {
//     try {
//       final list =
//           await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);
//       print(list);
//       setState(() {
//         _emailExists = list.isNotEmpty;
//         print("여기 탐");
//         print(_emailExists);
//       });
//     } catch (error) {
//       print("catch 탐");

//       setState(() {
//         _emailExists = false; // Assume it exists to avoid any UI confusion
//       });
//     }
//   }
}

//아이디 입력 -> 전화번호 인증 완료 -> 확인 버튼 -> complete Phoneverification&checkEmail -> alert

class SuccessResetPWPage extends StatelessWidget {
  const SuccessResetPWPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Text("비밀번호 재발급을 위한 메일이 전송되었습니다. \n메일을 확인해 주세요."),
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
                                    builder: (context) => LoginPage()));
                          },
                          child: Text("로그인 하러가기"),
                        ),
                      ),
                      SizedBox(
                        height: 81,
                      )
                    ]))));
  }
}
