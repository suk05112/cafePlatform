import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_app/Style/CommonSection.dart';
import 'package:my_app/setting/faq_page.dart';
import 'package:my_app/setting/notice_page.dart';
import 'package:my_app/setting/user_info_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final int _storeId = 1;
  late Future<String> _version;

  @override
  void initState() {
    super.initState();
    _version = getVersion();
  }

  Future _initRetrieval() async {}

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
                    CommonSection.getHeader2(context, "더보기"),
                    SizedBox(height: 13),
                    getsettingListView(),
                    Spacer(),
                    Text("사업자 정보 쓸거임")
                  ]))
        ]))));
  }

  List dataListItem() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = ["내 정보", "공지사항", "자주묻는 질문", "알림설정", "버전", "라이선스"];
    return items;
  }

  List getSelectedPage() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      const UserInfoPage(),
      const NoticePage(),
      const LicensePage(),
      const FAQPage(),
      const LicensePage(),
      const LicensePage(),
      const LicensePage()
    ];

    return items;
  }

//Converting the dataSources as a widget
  Widget getsettingListView() {
    var allItems = dataListItem();
    var selectedPage = getSelectedPage();
    // var listView = ListView.separated(
    var listView = ListView.builder(
      itemCount: allItems.length,
      itemExtent: 50.0,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 4) {
          return Version();
        } else {
          return GestureDetector(
              //You need to make my child interactive
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => selectedPage[index])),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${allItems[index]}"),
                    const Divider()
                  ]));
          // return ListTile(title: Text(allItems[index]));
        }
      },
    );
    return listView;
  }

  Widget Version() {
    print("version: ${_version}");
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 인디케이터를 표시합니다.
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text('Error: ${snapshot.error}'); // 오류가 발생하면 오류 메시지를 표시합니다.
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("버전"),
                  Spacer(),
                  Text("v ${snapshot.data}"), // 앱의 버전을 표시합니다.
                ],
              ),
              Divider(),
            ],
          );
        }
      },
    );
  }

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}

class LicensePage extends StatelessWidget {
  const LicensePage({Key? key}) : super(key: key);

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
