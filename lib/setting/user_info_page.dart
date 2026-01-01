import "package:flutter/material.dart";
import 'package:cafeplatform/main.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return "phone";
    }
    // +82를 0101로 변환
    if (phoneNumber.startsWith("+82")) {
      String number = phoneNumber.substring(3);
      if (number.startsWith("10")) {
        return "010${number.substring(2)}";
      } else if (number.startsWith("1")) {
        return "010${number.substring(1)}";
      }
      return "010$number";
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;

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
                      _buildInfoRow("이메일", user?.email ?? "email"),
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
      // Firebase Auth 로그아웃
      await firebase_auth.FirebaseAuth.instance.signOut();

      // UserProvider에서 사용자 정보 삭제
      await Provider.of<UserProvider>(context, listen: false).clearUser();

      // SharedPreferences에서 FCM 토큰 삭제 (선택사항)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');

      // 모든 스택을 제거하고 TabPage(매장 리스트)로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TabPage(initialIndex: 0)),
        (route) => false,
      );
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }

  Future<void> _handleWithdrawal(BuildContext context) async {
    try {
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.delete();
        } catch (e) {
          print('파베 회원 탈퇴 처리 오류: $e');
        }
      }
      // Firebase Auth 로그아웃
      await firebase_auth.FirebaseAuth.instance.signOut();
      // UserProvider에서 사용자 정보 삭제
      await Provider.of<UserProvider>(context, listen: false).clearUser();

      // SharedPreferences에서 FCM 토큰 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');

      // 모든 스택을 제거하고 TabPage(매장 리스트)로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TabPage(initialIndex: 0)),
        (route) => false,
      );
    } catch (e) {
      print('회원 탈퇴 처리 오류: $e');
    }
  }
}
