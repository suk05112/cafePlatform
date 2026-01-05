import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/widget/input_info_widget.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({super.key});

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  TextEditingController inputIDController = TextEditingController();
  TextEditingController inputPhoneNumbfController = TextEditingController();
  String? phone_number;
  late final PhoneAuthCredential phoneCredential;
  String? password;
  String? inputId;

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
    inputIDController.dispose();
    inputPhoneNumbfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: const CommonAppBar(title: "비밀번호 찾기"),
            backgroundColor: Colors.white,
            body: SafeArea(
                child: SingleChildScrollView(
                    reverse: true,
                    padding:
                        const EdgeInsets.only(left: 27, right: 27, bottom: 10),
                    child: Form(
                        key: formKey,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InputInfoWidget(
                                title: "아이디 입력",
                                hintText: "아이디를 입력해주세요",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "아이디를 입력해주세요";
                                  }
                                  return null;
                                },
                                onChanged: (id) {
                                  setState(() {
                                    inputId = id;
                                  });
                                },
                              ),
                              PhoneNumberVerificationWidget(
                                  successCallback: (phoneAuthResult) {
                                if (phoneAuthResult != null) {
                                  print(
                                      "전화번호 인증 성공: $phoneAuthResult.phoneNumber");
                                  setState(() {
                                    phone_number = phoneAuthResult.phoneNumber;
                                    phoneCredential =
                                        phoneAuthResult.credential;
                                  });
                                } else {
                                  print("전화번호 인증 실패");
                                }
                              }),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: ColorAssset.mainColor,
                                  ),
                                  onPressed: () async {
                                    bool emailExists = await checkEmailExists(
                                        inputIDController.text + "@gifnut.com",
                                        inputPhoneNumbfController.text);

                                    if (emailExists) {
                                      if (formKey.currentState!.validate()) {
                                        final phoneLogin =
                                            await _auth.signInWithCredential(
                                                phoneCredential);

                                        if (phoneLogin.user != null) {
                                          if (password != null) {
                                            phoneLogin.user!
                                                .updatePassword(password!);
                                            print(
                                                "success update pw $password");
                                            CommonDialog.show(
                                                context: context,
                                                title: "비밀번호가 변경되었습니다.",
                                                content: "로그인해주세요.",
                                                buttonText: "확인",
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                });
                                          } else {
                                            CommonDialog.show(
                                                context: context,
                                                title: "비밀번호를 다시 확인해주세요.",
                                                content: "다시한번 확인해주세요.",
                                                buttonText: "확인",
                                                onPressed: () {});
                                          }
                                        } else {
                                          print("phoneLogin.user null");
                                        }
                                      } else {
                                        return;
                                      }
                                    }
                                  },
                                  child: const Text("확인"),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ]))))));
  }

  Future<bool> checkEmailExists(String email, String phoneNumber) async {
    try {
      final response = await Api().client.getIsRegisteredUser(email, "email");

      // final response = await Api().client.findOwnerPw(
      //       OwnerFindPw(email: email, phone_number: phone_number),
      //     );
      // final Map<String, dynamic> data = jsonDecode(response);
      // if (data['msg'] == "success") {
      //   return true;
      // } else {
      //   return false;
      // }
      return response.isRegistered;
    } on DioException catch (e) {
      String errorMsg = "";
      if (e.response != null) {
        // 서버에서 받은 상태 코드에 따른 처리
        if (e.response!.statusCode == 401) {
          // 인증 실패
          print("인증 실패: ${e.response!.data}");
          errorMsg = "[401]인증에 실패했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else if (e.response!.statusCode == 500) {
          // 서버 오류
          print("서버 오류: ${e.response!.data}");
          errorMsg =
              "[500]서버에 오류가 발행했습니다.잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        } else {
          // 기타 오류
          print("기타 오류: ${e.response!.data}");
          errorMsg = "오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.response!.data}";
        }
      } else {
        // 네트워크 연결 실패 등
        print("네트워크 오류: ${e.message}");
        errorMsg = "네트워크 오류가 발생했습니다. 잠시 후 다시 실행해주세요.\n ${e.message}";
      }

      CommonDialog.show(
          context: context,
          title: "아이디 찾기 실패",
          content: errorMsg,
          buttonText: "확인",
          onPressed: () {});
    }
    return false;
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
