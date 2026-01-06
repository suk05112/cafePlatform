import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/SignIn/find_password_page.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/api/API.dart';
import 'dart:io';

import 'package:cafeplatform/SignIn/phone_auth_page.dart';
import 'package:cafeplatform/utils/number_formatter.dart';
import 'package:cafeplatform/widget/CommonDialog.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';

class FindUserIDPage extends StatefulWidget {
  const FindUserIDPage({super.key});

  @override
  State<FindUserIDPage> createState() => _FindUserIDPageState();
}

class _FindUserIDPageState extends State<FindUserIDPage> {
  TextEditingController inputIDController = TextEditingController();
  TextEditingController inputPhoneNumbfController = TextEditingController();

  String? phone_number;
  late final PhoneAuthCredential phoneCredential;

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
            body: Container(
                margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text("이름 입력"),
                      // TextFormField(
                      //   controller: inputIDController,
                      //   keyboardType: TextInputType.text,
                      //   decoration: inputDecoration.copyWith(hintText: "이름"),
                      // ),
                      PhoneNumberVerificationWidget(
                          successCallback: (phoneAuthResult) {
                        // 여기서 phoneNumber 변수에 인증된 전화번호가 들어옵니다.
                        if (phoneAuthResult != null) {
                          print(
                              "전화번호 인증 성공: $phoneAuthResult.phoneNumber");
                          setState(() {
                            phone_number = phoneAuthResult.phoneNumber;
                            phoneCredential = phoneAuthResult.credential;
                          });
                        } else {
                          print("전화번호 인증 실패");
                        }
                      }),
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
                            // showRegisteredId(OwnerFind(
                            //     name: inputIDController.text,
                            //     phone_number: inputPhoneNumbfController.text));
                          },
                          child: Text("확인"),
                        ),
                      ),
                      SizedBox(
                        height: 81,
                      ) //전화번호
                    ]))));
  }

  @override
  void dispose() {
    inputIDController.dispose();
    inputPhoneNumbfController.dispose();
    super.dispose();
  }

  //전화번호 인증 성공 후 uid 넘겨 받고, 이름, Uid 담아서 id response 로 받기
  showRegisteredId() async {
    try {
      // var response = await Api().client.findOwnerId(ownerFind);

      final exist = true;

      if (exist) {
        print("결과 값 ");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterdIDPage(
              email: "email",
              created_time: "created_time",
            ),
          ),
        );
      } else {
        CommonDialog.show(
            context: context,
            title: "입력된 정보가 올바르지 않습니다.",
            content: "다시한번 확인해주세요.",
            buttonText: "확인",
            onPressed: () {});
        print("msg");
      }
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
    print("showRegisterdId");
  }
}

class RegisterdIDPage extends StatefulWidget {
  const RegisterdIDPage({super.key, this.email, this.created_time, this.msg});

  final String? email;
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
              const Text("가입 하신 아이디는 아래와 같습니다."),
              Container(
                  // color: ColorAssset.greyBackground,
                  width: double.infinity, // <-- match_parent

                  margin: EdgeInsets.fromLTRB(27, 0, 27, 21),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "아이디 : ${widget.email} \n가입일: ${widget.created_time}"),
                      ])),
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
