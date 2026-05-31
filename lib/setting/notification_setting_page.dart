import 'package:flutter/material.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/user_response.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

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
    // 서비스 푸시가 꺼지면 마케팅 푸시도 같이 꺼지게
    bool marketingValue = value ? _marketingPushEnabled : false;

    // UI를 먼저 업데이트하여 토글 버튼이 즉시 움직이도록
    setState(() {
      _servicePushEnabled = value;
      _marketingPushEnabled = marketingValue;
    });

    // 그 다음 저장 및 서버 업데이트
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('service_push_enabled', value);
    await prefs.setBool('marketing_push_enabled', marketingValue);

    // 서버에 푸시 토큰 설정 업데이트
    _updatePushTokenSettings(
      allowServicePush: value,
      allowMarketingPush: marketingValue,
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
    _updatePushTokenSettings(
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
        print('사용자 정보가 없어 푸시 토큰 설정 업데이트를 건너뜁니다.');
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
      print('푸시 토큰 설정 업데이트 성공: userId=${user.user_id}');
    } catch (e) {
      print('푸시 토큰 설정 업데이트 실패: $e');
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
