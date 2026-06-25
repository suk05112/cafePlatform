import 'package:flutter/material.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  bool _servicePushEnabled = true;
  bool _marketingPushEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _servicePushEnabled = prefs.getBool('service_push_enabled') ?? true;
      _marketingPushEnabled = prefs.getBool('marketing_push_enabled') ?? true;
    });
  }

  Future<void> _saveServicePushSetting(bool value) async {
    if (value) {
      // 토글 ON: 시스템 권한 상태 먼저 확인
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final status = settings.authorizationStatus;

      if (status == AuthorizationStatus.notDetermined) {
        // 권한 미결정 → 시스템 권한 요청
        final result = await FirebaseMessaging.instance.requestPermission(
          alert: true, badge: true, sound: true,
        );
        if (result.authorizationStatus != AuthorizationStatus.authorized &&
            result.authorizationStatus != AuthorizationStatus.provisional) {
          // 거부됨 → 토글 변경 없이 종료
          return;
        }
      } else if (status == AuthorizationStatus.denied) {
        // 영구 거부 → 설정 앱으로 유도
        if (mounted) {
          _showGoToSettingsDialog();
        }
        return;
      }
    }

    final bool marketingValue = value ? _marketingPushEnabled : false;

    setState(() {
      _servicePushEnabled = value;
      _marketingPushEnabled = marketingValue;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('service_push_enabled', value);
    await prefs.setBool('marketing_push_enabled', marketingValue);

    await _updatePushTokenSettings(
      allowServicePush: value,
      allowMarketingPush: marketingValue,
    );
  }

  void _showGoToSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '알림 권한 필요',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '알림을 받으려면 설정에서 알림 접근을 허용해주세요.',
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('취소',
                          style:
                              TextStyle(color: Colors.black54, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ColorAssset.mainColor,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        openAppSettings();
                      },
                      child: const Text('설정으로 이동',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMarketingPushSetting(bool value) async {
    // 마케팅 푸시가 켜지면 서비스 푸시도 같이 켜지게
    bool serviceValue = value ? true : _servicePushEnabled;

    // UI를 먼저 업데이트하여 토글 버튼이 즉시 움직이도록
    setState(() {
      _marketingPushEnabled = value;
      _servicePushEnabled = serviceValue;
    });

    // 그 다음 저장 및 서버 업데이트
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('marketing_push_enabled', value);
    await prefs.setBool('service_push_enabled', serviceValue);

    // 서버에 푸시 토큰 설정 업데이트
    await _updatePushTokenSettings(
      allowServicePush: serviceValue,
      allowMarketingPush: value,
    );
  }

  Future<void> _updatePushTokenSettings({
    bool? allowServicePush,
    bool? allowMarketingPush,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token') ?? '';

      final pushTokenUpdateRequest = PushTokenUpdateRequest(
        allowServicePush: allowServicePush,
        allowMarketingPush: allowMarketingPush,
      );

      await Api().setBaseClient(Api.BASE_URL);
      await Api().client.updatePushToken(
            user.user_id,
            pushTokenUpdateRequest,
            fcmToken.isNotEmpty ? fcmToken : null,
          );
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "알림 설정"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          '푸시 알림',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildNotificationToggle(
                        title: '서비스 푸시알림',
                        subtitle: '주문, 결제 등 서비스 관련 알림을 받습니다',
                        value: _servicePushEnabled,
                        onChanged: _saveServicePushSetting,
                      ),
                      _buildNotificationToggle(
                        title: '마케팅 푸시알림',
                        subtitle: '이벤트, 할인 등 마케팅 정보를 받습니다',
                        value: _marketingPushEnabled,
                        onChanged: _saveMarketingPushSetting,
                      ),
                      SizedBox(height: 8),
                    ],
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

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ColorAssset.mainColor,
          ),
        ],
      ),
    );
  }
}
