import 'package:flutter/material.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/api/business_info_response.dart';
import 'package:cafeplatform/setting/inquiry_page.dart';
import 'package:cafeplatform/SignIn/login_page.dart';
import 'package:cafeplatform/model/user.dart';
import 'package:cafeplatform/order/order_list.dart';
import 'package:cafeplatform/provider/user_provider.dart';
import 'package:cafeplatform/setting/faq_page.dart';
import 'package:cafeplatform/setting/notice_page.dart';
import 'package:cafeplatform/setting/user_info_page.dart';
import 'package:cafeplatform/widget/common_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/setting/oss_licenses.dart';
import 'package:cafeplatform/setting/notification_setting_page.dart';
import 'package:cafeplatform/setting/terms_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cafeplatform/utils/kakao_share_helper.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late Future<String> _version;

  @override
  void initState() {
    super.initState();
    _version = getVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(title: "더보기"),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 20),
                    getUserInfo(),
                    SizedBox(height: 24),
                    // 카카오 공유 테스트 버튼 (테스트용 - 주석처리로 쉽게 제거 가능)
                    // _buildKakaoShareTestButton(),
                    SizedBox(height: 16),
                    getsettingListView(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              businessInformation(),
              SizedBox(height: 20),
            ],
          ),
        )));
  }

  List dataListItem() {
    var items = [
      "알림 설정",
      "공지사항",
      "자주묻는 질문",
      "문의하기",
      "결제내역",
      "약관 보기",
      // "카카오 공유 테스트",
      "라이선스",
      "버전",
    ];
    return items;
  }

  List<IconData> getIcons() {
    return [
      Icons.notifications_active_outlined,
      Icons.notifications_outlined,
      Icons.help_outline,
      Icons.contact_support_outlined,
      Icons.receipt_long_outlined,
      Icons.description_outlined,
      // Icons.share_outlined,
      Icons.description_outlined,

      Icons.info_outline,
    ];
  }

  List getSelectedPage() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      const NotificationSettingPage(),
      const NoticePage(),
      const FAQPage(),
      const InquiryPage(),
      OrderListPage(),
      const TermsPage(),
      // null, // 카카오 공유 테스트는 별도 처리
      // const LicensePage(),
      OssLicensesPage(),
    ];

    return items;
  }

  Widget getUserInfo() {
    User? user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(returnToPrevious: true),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(20),
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
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "로그인 & 가입하기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "로그인 후 서비스 이용이 가능합니다.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserInfoPage()),
            );
          },
          child: Container(
            padding: EdgeInsets.all(20),
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
            child: Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatEmailToId(user.email),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ]),
          ));
    }
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

  Widget getsettingListView() {
    var allItems = dataListItem();
    var selectedPage = getSelectedPage();
    var icons = getIcons();

    return Container(
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
        children: [
          for (int index = 0; index < allItems.length; index++)
            if (index == 7)
              version()
            // else if (index == 6)
            /*
              // 카카오 공유 테스트 버튼
              GestureDetector(
                onTap: () => _testKakaoShare(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icons[index],
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          allItems[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              )
            */
            else
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => selectedPage[index]),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icons[index],
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          allItems[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget version() {
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "버전",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  "v ${snapshot.data}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// 카카오 공유 테스트 버튼 위젯 (독립적으로 주석처리 가능)
  Widget _buildKakaoShareTestButton() {
    // 이 전체 블록을 주석처리하면 테스트 버튼이 사라집니다
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _testKakaoShare,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '카카오 공유 테스트',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[900],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '테스트용 버튼',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.orange[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // 주석처리 예시:
    // return SizedBox.shrink();
  }

  /// 카카오톡 공유 테스트 함수
  void _testKakaoShare() {
    // 테스트용 Gifticon 객체 생성
    final testGifticon = Gifticon(
      gifticon_id: 999,
      order_id: 1,
      name: '테스트 기프티콘',
      sender: '테스트 보낸사람',
      receiver: '테스트 받는사람',
      receiver_phone_number: '01012345678',
      store_name: '테스트 매장',
      menu_url: null, // 테스트용으로 null
      total_price: 5000,
      description: '카카오 공유 테스트용 기프티콘입니다',
      validity: DateTime.now().add(Duration(days: 30)),
      status: 'ACTIVE',
      type: 1,
      store_id: 1,
      store_lat: 37.5665,
      store_lng: 126.9780,
    );

    // 카카오톡 공유 실행
    KakaoShareHelper.shareGifticon(
      testGifticon,
      onSuccess: () {
        Fluttertoast.showToast(
          msg: '카카오톡 공유 테스트 완료',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      },
      onError: (error) {
        Fluttertoast.showToast(
          msg: '카카오톡 공유 실패: $error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      },
    );
  }

  Future<BusinessInfoResponse> getBusinessInfo() async {
    try {
      // SharedPreferences에서 캐시된 데이터와 마지막 업데이트 시간 확인
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('business_info_cache');
      final lastUpdateTimeStr = prefs.getString('business_info_last_update');

      // 캐시가 있고 오늘 날짜면 캐시된 데이터 반환
      if (cachedJson != null && lastUpdateTimeStr != null) {
        try {
          final lastUpdateTime = DateTime.parse(lastUpdateTimeStr);
          final now = DateTime.now();

          // 같은 날이면 캐시된 데이터 반환
          if (lastUpdateTime.year == now.year &&
              lastUpdateTime.month == now.month &&
              lastUpdateTime.day == now.day) {
            print('사업자 정보 캐시 사용 (마지막 업데이트: $lastUpdateTime)');
            final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
            return BusinessInfoResponse.fromJson(jsonMap);
          } else {
            print('캐시 만료됨 (마지막 업데이트: $lastUpdateTime, 현재: $now)');
          }
        } catch (e) {
          print('캐시 파싱 오류: $e, API 호출로 재시도');
        }
      }

      // 캐시가 없거나 오래되었으면 API 호출
      print('사업자 정보 API 호출');
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getBusinessInfo();
      print('사업자 정보 조회 성공: ${response.toJson()}');

      // 캐시에 저장 (JSON으로 직렬화)
      final now = DateTime.now();
      await prefs.setString('business_info_last_update', now.toIso8601String());
      await prefs.setString(
          'business_info_cache', jsonEncode(response.toJson()));

      return response;
    } catch (error) {
      print('사업자 정보 조회 오류: $error');

      // 에러 발생 시 캐시된 데이터가 있으면 사용
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString('business_info_cache');
        if (cachedJson != null && cachedJson.isNotEmpty) {
          print('에러 발생, 캐시된 사업자 정보 사용');
          final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
          return BusinessInfoResponse.fromJson(jsonMap);
        }
      } catch (e) {
        print('캐시 조회 오류: $e');
      }

      // 캐시도 없으면 기본값 반환
      return BusinessInfoResponse(
        business_number: '479-03-03427',
        online_sales_number: '2025-서울강서-3226',
        address: '서울특별시 강서구 공항대로 543',
        telephone: '02-1111-1111',
      );
    }
  }

  Widget businessInformation() {
    return FutureBuilder<BusinessInfoResponse>(
      future: getBusinessInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "502 Company \n대표: 한수진 \n사업자등록번호: 479-03-03427",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "주소: 서울특별시 강서구 공항대로 543 \n이메일: service@502company.com \n고객센터: 02-1111-1111",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        final businessInfo = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "502 Company \n대표: 한수진 \n사업자등록번호: ${businessInfo.business_number}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "통신판매업신고번호: ${businessInfo.online_sales_number}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "주소: ${businessInfo.address}\n이메일: service@502company.com\n고객센터: ${businessInfo.telephone}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Container(
              margin: EdgeInsets.fromLTRB(21, 0, 21, 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CommonSection.getHeader("라이선스"),
                  const Text("this is license page")
                ],
              ))
        ]))));
  }
}

class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

  static Future<List<String>> loadLicenses() async {
    final ossKeys = List<String>.from(ossLicenses);
    return ossKeys..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CommonAppBar(title: "라이선스"),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (var i = 0; i < ossLicenses.length; i++)
                ListTile(
                  title: Text(ossLicenses[i].name),
                  // subtitle: ossLicenses[i].description != null ? Text(ossLicenses[i].description!) : null,
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // 클릭하면 해당 오픈소스 라이선스 페이지로 이동
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MiscOssLicenseSingle(
                            name: ossLicenses[i].name ?? '',
                            version: ossLicenses[i].version ?? '',
                            description: ossLicenses[i].description ?? '',
                            licenseText: ossLicenses[i].license ?? '',
                            homepage: ossLicenses[i].homepage ?? '')));
                  },
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MiscOssLicenseSingle(name: ossLicenses[i].name, json: ossLicenses[i])))
                )
            ],
          ),
        ));
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final String name;
  final String version;
  final String description;
  final String licenseText;
  final String homepage;

  const MiscOssLicenseSingle({
    super.key,
    required this.name,
    required this.version,
    required this.description,
    required this.licenseText,
    required this.homepage,
  });

  String _bodyText() {
    return licenseText.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("라이선스"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(name),
              subtitle: Text('version : $version'),
            ),
            if (description.isNotEmpty)
              Padding(
                  padding:
                      const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: Text(description)),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
              child: Text(_bodyText()),
            ),
            const Divider(),
            ListTile(
              title: Text('Homepage'),
              subtitle: Text(homepage),
              // onTap: () async {
              //   if (await canLaunch(homepage)) {
              //     await launch(homepage);
              //   } else {
              //     throw 'Could not launch $homepage';
              //   }
              // }
            ),
          ],
        ),
      ),
    );
  }
}
