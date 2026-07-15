import "package:flutter/material.dart";
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:dio/dio.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = context.read<UserProvider>();
  }

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return "phone";
    }

    // 숫자만 추출
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // +82로 시작하면 0으로 변환
    if (phoneNumber.startsWith("+82")) {
      digitsOnly = phoneNumber.substring(3).replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.startsWith("10")) {
        digitsOnly = "0${digitsOnly}";
      } else if (digitsOnly.startsWith("1")) {
        digitsOnly = "0${digitsOnly}";
      } else {
        digitsOnly = "0$digitsOnly";
      }
    }

    // 010으로 시작하는 11자리 번호를 010-1234-1234 형식으로 변환
    if (digitsOnly.length == 11 && digitsOnly.startsWith("010")) {
      return "${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}";
    }

    // 다른 형식은 그대로 반환
    return phoneNumber;
  }

  String _formatEmailToId(String? email) {
    if (email == null || email.isEmpty) {
      return "id";
    }
    // @gifnut.com 부분 제거
    if (email.contains("@gifnut.com")) {
      return email.replaceAll("@gifnut.com", "");
    }

    return email;
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: const CommonAppBar(title: "내정보"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                // 프로필 이미지
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // 사용자 정보 카드
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("이름", user?.name ?? ""),
                      SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey[200]),
                      SizedBox(height: 16),
                      _buildInfoRow("아이디", _formatEmailToId(user?.email)),
                      SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey[200]),
                      SizedBox(height: 16),
                      _buildInfoRow(
                          "전화번호", _formatPhoneNumber(user?.phone_number)),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // 로그아웃 버튼
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.black87,
                    ),
                    title: Text(
                      "로그아웃",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                    onTap: () async {
                      await _handleLogout(context);
                    },
                  ),
                ),
                SizedBox(height: 12),
                // 회원탈퇴 버튼
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.person_remove_outlined,
                      color: Colors.red[400],
                    ),
                    title: Text(
                      "회원탈퇴",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[400],
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                    onTap: () {
                      _showWithdrawalDialog();
                    },
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // 회원탈퇴 위젯
  void _showWithdrawalDialog() {
    TextEditingController inputController = TextEditingController();
    bool showingFail = false;
    showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아이콘
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 36,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 20),
                    // 제목
                    Text(
                      "회원탈퇴",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "정말 탈퇴하시겠습니까?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "탈퇴 후 모든 데이터가 삭제되며\n복구할 수 없습니다.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    // 입력 필드
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "'회원탈퇴'를 입력해주세요",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: inputController,
                          decoration: InputDecoration(
                            hintText: '회원탈퇴',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: showingFail
                                    ? Colors.red
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: showingFail
                                    ? Colors.red
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    showingFail ? Colors.red : Colors.red[400]!,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        if (showingFail) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "'회원탈퇴'를 정확히 입력해주세요",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 24),
                    // 버튼
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '취소',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red[400],
                              padding: EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              if (inputController.text == '회원탈퇴') {
                                // 미사용 기프티콘 체크
                                final userId = userProvider.user?.user_id;
                                if (userId != null) {
                                  try {
                                    await Api().setBaseClient(Api.BASE_URL);
                                    final response = await Api().client.getGifticonList(userId);
                                    final hasUnused = response.gifticonList.any((g) =>
                                        g.status == 'UNUSED' &&
                                        (g.validity == null || !g.validity!.isBefore(DateTime.now())));
                                    if (hasUnused && context.mounted) {
                                      await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          title: const Text(
                                            '미사용 기프티콘 있음',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text(
                                            '미사용 된 기프티콘이 있습니다. 환불 혹은 사용 완료 후 탈퇴가 가능합니다. 환불 문의는 \'더보기>문의하기\' 로 남겨주세요',
                                            style: TextStyle(fontSize: 14, height: 1.5),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(),
                                              child: const Text('확인'),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }
                                  } catch (_) {}
                                }
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                await _handleWithdrawal(context);
                              } else {
                                setState(() {
                                  showingFail = true;
                                });
                              }
                            },
                            child: Text(
                              '탈퇴하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // 서버 FCM 토큰 삭제
      final userId = userProvider.user?.user_id;
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      if (userId != null && fcmToken != null) {
        try {
          await Api().setBaseClient(Api.BASE_URL);
          await Api().client.deleteUserPushToken(userId, fcmToken);
        } catch (e) {
        }
      }

      // Firebase Auth 로그아웃
      await firebase_auth.FirebaseAuth.instance.signOut();

      // UserProvider에서 사용자 정보 삭제
      await userProvider.clearUser();

      // SharedPreferences에서 FCM 토큰 삭제
      await prefs.remove('fcm_token');

      // // 모든 스택을 제거하고 TabPage(매장 리스트)로 이동
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const TabPage(initialIndex: 0)),
      //   (route) => false,
      // );

      if (!mounted) return;
      Future.microtask(() {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TabPage(initialIndex: 0)),
          (route) => false,
        );
      });
    } catch (e) {
    }
  }

  Future<void> _handleWithdrawal(BuildContext context) async {
    // 로딩 다이얼로그 표시
    if (!mounted) return;

    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogBuilderContext) {
        dialogContext = dialogBuilderContext;
        return Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: ColorAssset.mainColor),
                  SizedBox(height: 16),
                  Text(
                    '회원 탈퇴 처리 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // UserProvider에서 사용자 정보 가져오기 (캐싱된 userProvider 사용)
      final appUser = userProvider.user;
      final userId = appUser?.user_id;

      // Firebase 사용자 확인 (애플 계정 확인 및 authorizationCode 가져오기)
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;
      String? appleAuthorizationCode;
      bool hasAppleProvider = false;

      if (user != null) {
        final providerData = user.providerData;
        hasAppleProvider =
            providerData.any((info) => info.providerId == 'apple.com');

        if (hasAppleProvider) {
          // 회원 탈퇴를 위해 Apple 로그인을 다시 요청하여 authorizationCode 받기 및 Firebase 재인증
          try {
            final appleCredential = await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
            );
            appleAuthorizationCode = appleCredential.authorizationCode;

            // Firebase 재인증 (requires-recent-login 오류 방지)
            try {
              final oauthCredential =
                  firebase_auth.OAuthProvider('apple.com').credential(
                idToken: appleCredential.identityToken,
                accessToken: appleCredential.authorizationCode,
              );
              await user.reauthenticateWithCredential(oauthCredential);
            } catch (reAuthError) {
              // 재인증 실패해도 authorizationCode는 전달 가능 (서버에서 처리)
            }
          } catch (e) {
            // 애플 로그인 실패 시 null로 전달 (서버에서 처리 불가)
            appleAuthorizationCode = null;
            // 사용자에게 오류 메시지 표시
            if (mounted &&
                dialogContext != null &&
                Navigator.canPop(dialogContext!)) {
              Navigator.of(dialogContext!).pop();
            }
            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext errorContext) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('애플 로그인 필요'),
                    content: const Text(
                      '회원 탈퇴를 위해 애플 로그인이 필요합니다.\n'
                      '다시 시도해주세요.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(errorContext).pop();
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  );
                },
              );
            }
            // 애플 로그인 실패 시 탈퇴 프로세스 중단 (로딩은 이미 닫았으므로 setState 불필요)
            return;
          }
        }
      }

      // 서버에서 사용자 삭제 API 호출
      if (userId != null) {
        try {
          await Api().setBaseClient(Api.BASE_URL);
          final deleteResponse =
              await Api().client.deleteUser(userId, appleAuthorizationCode);
        } on DioException catch (e) {
          // 서버 삭제 실패해도 Firebase 삭제는 시도
        } catch (e) {
          // 서버 삭제 실패해도 Firebase 삭제는 시도
        }
      } else {
      }

      // Firebase 사용자 삭제
      if (user != null) {
        try {
          await user.delete();
          if (hasAppleProvider) {
          } else {
          }
        } on firebase_auth.FirebaseAuthException catch (e) {

          // requires-recent-login 오류인 경우 특별 처리
          if (e.code == 'requires-recent-login') {
            // 로딩 다이얼로그 닫기
            if (mounted &&
                dialogContext != null &&
                Navigator.canPop(dialogContext!)) {
              Navigator.of(dialogContext!).pop();
            }

            // 사용자에게 재인증이 필요하다는 메시지 표시
            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext alertContext) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('재인증 필요'),
                    content: const Text(
                      '회원 탈퇴를 위해 다시 로그인해주세요.\n'
                      '보안상 최근 인증이 필요합니다.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(alertContext).pop();
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  );
                },
              );
            }
            return; // 재인증이 필요한 경우 탈퇴 프로세스 중단
          }

          // 다른 Firebase 오류인 경우에도 계속 진행 (서버 데이터는 이미 삭제됨)
        } catch (e) {
          // 기타 오류인 경우에도 계속 진행
        }
      }

      // Firebase Auth 로그아웃 (Firebase 계정이 삭제되지 않았어도 로그아웃)
      try {
        await firebase_auth.FirebaseAuth.instance.signOut();
      } catch (e) {
        // 로그아웃 실패해도 계속 진행
      }

      // SharedPreferences에서 FCM 토큰 삭제
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('fcm_token');
      } catch (e) {
        // 오류가 발생해도 계속 진행
      }

      // 로딩 다이얼로그 닫기 (clearUser 호출 전에 닫기)
      if (mounted &&
          dialogContext != null &&
          Navigator.canPop(dialogContext!)) {
        Navigator.of(dialogContext!).pop();
        dialogContext = null;
      }

      // UserProvider에서 사용자 정보 삭제 (캐싱된 userProvider 사용)
      try {
        await userProvider.clearUser();
      } catch (e, stackTrace) {
        // 오류가 발생해도 계속 진행
      }

      // 탈퇴 완료 메시지 표시
      // mounted와 context.mounted를 모두 체크
      if (mounted && context.mounted) {
        try {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext successContext) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  '탈퇴 완료',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  '회원 탈퇴가 완료되었습니다.\n이용해주셔서 감사합니다.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(successContext).pop();
                      if (context.mounted) {
                        Navigator.of(context).pop();
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
        } catch (dialogError) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e, stackTrace) {

      // 로딩 다이얼로그 닫기
      if (mounted &&
          dialogContext != null &&
          Navigator.canPop(dialogContext!)) {
        Navigator.of(dialogContext!).pop();
      }

      // 오류 메시지 표시
      if (mounted) {
        String errorMessage = '회원 탈퇴 중 오류가 발생했습니다.';
        if (e is firebase_auth.FirebaseAuthException) {
          if (e.code == 'requires-recent-login') {
            errorMessage = '보안상 재인증이 필요합니다.\n다시 로그인 후 탈퇴를 시도해주세요.';
          } else {
            errorMessage = 'Firebase 오류: ${e.message ?? e.code}';
          }
        } else if (e.toString().contains('Null check operator')) {
          errorMessage = '시스템 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
        } else if (e is DioException) {
          errorMessage = '서버 오류가 발생했습니다.\n네트워크 연결을 확인해주세요.';
        }

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext alertContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('오류'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(alertContext).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
