import 'package:flutter/material.dart';
import 'package:my_app/setting/faq_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final int _storeId = 1;
  @override
  void initState() {
    // _initRetrieval();
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
                    // CommonSection.getHeader("설정"),
                    SizedBox(height: 13),
                    getsettingListView()
                  ]))
        ]))));
  }

  List dataListItem() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      "내 정보",
      "공지사항",
      "고객센터",
      "정산계좌 관리",
      "자주묻는 질문",
      "알림",
      "버전",
      "라이선스"
    ];
    return items;
  }

  List getSelectedPage() {
    // var items = List.generate(5, (i) => "Item $i");
    var items = [
      const LicensePage(),
      const LicensePage(),
      const LicensePage(),
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
      itemExtent: 46.0,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 6) {
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
    return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("버전"), Spacer(), Text("v 1.0.0"), Divider()])
        ]);
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
