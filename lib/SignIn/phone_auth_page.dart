import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cafeplatform/utils/number_formatter.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:cafeplatform/widget/input_info_widget.dart';

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
  const PhoneAuthPage({super.key});

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
            child: PhoneNumberVerificationWidget(successCallback: (credential) {
              print("전화번호 인증완료");
              // 여기서 phoneNumber 변수에 인증된 전화번호가 들어옵니다.
              if (credential != null) {
                print("회원가입 전화번호 인증 성공:");
                Navigator.pop(context, credential);
              } else {
                print("전화번호 인증 실패");
              }
            })));
  }
}

class PhoneNumberVerificationWidget extends StatefulWidget {
  const PhoneNumberVerificationWidget(
      {super.key, required this.successCallback});

  final Function(PhoneAuthResult?) successCallback;

  @override
  State<PhoneNumberVerificationWidget> createState() =>
      _PhoneNumberVerificationWidgetState();
}

class _PhoneNumberVerificationWidgetState
    extends State<PhoneNumberVerificationWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  bool isTouched = false;
  String? name;
  final _formKey = GlobalKey<FormState>();

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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 이름 입력 필드
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
                        decoration:
                            inputDecoration.copyWith(hintText: "휴대폰 번호를 입력하세요"),
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
                          backgroundColor: Colors.black,
                          fixedSize: const Size(100, 50)),
                      onPressed: () {
                        setState(() {
                          isTouched = true;
                        });
                        verifyPhoneNumber("+821025446458");

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
                                keyboardType: TextInputType.text,
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
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  fixedSize: const Size(100, 50)),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  if (name == null || name!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("이름을 입력해주세요.")),
                                    );
                                    return;
                                  }

                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationId,
                                          smsCode:
                                              validationNumberController.text);

                                  widget.successCallback(
                                    PhoneAuthResult(
                                      credential: credential,
                                      phoneNumber: "+821025446458",
                                      // phoneNumber: phoneNumberController.text,
                                      name: name,
                                    ),
                                  );
                                }

                                // final authCredential = await _auth
                                //     .signInWithCredential(credential);

                                /*
                                try {
                                  if (authCredential.user != null) {
                                    setState(() {
                                      print("인증완료 및 로그인성공");
                                    });
                                    await _auth.currentUser!.delete();
                                    print("auth정보삭제");
                                    _auth.signOut();
                                    print("phone로그인된것 로그아웃");
                                    widget.successCallback(
                                        // "authCredential.user!.phoneNumber");
                                        // widget.successCallback(
                                        authCredential.user!.phoneNumber);
                                  }
                                }

                                // signInWithPhoneAuthCredential(phoneAuthCredential);
                                catch (e) {
                                  print('Error: $e');
                                }
                                ;
                                                                                                  */
                              },
                              child: Text('인증확인'),
                            )
                          ])
                        ]))
              ]),
        ),
      ),
    );
  }

  // SMS 인증을 요청합니다.
  void verifyPhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 인증 완료 콜백 함수
        print("verificationCompleted::전화번호 인증 완료");
        // await FirebaseAuth.instance.signInWithCredential(credential);
        FirebaseAuth.instance.signOut(); // 로그아웃 처리
      },
      verificationFailed: (FirebaseAuthException e) {
        print("전화번호 인증 실패");
        print(e.code);
        // 인증 실패 콜백 함수
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        print("코드 보내짐");
        print(verificationId);
        // 코드가 성공적으로 보내진 경우
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("타임아웃");

        // 타임아웃 콜백 함수
        _verificationId = verificationId;
      },
    );
  }
}
