import 'package:flutter/material.dart';
import 'package:my_app/MenuForStore.dart';
import 'package:my_app/Style/TextAsset.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/cafe_list_map_view.dart';
import 'package:my_app/menu_page.dart';
import 'package:my_app/model/CafeBasicInfo.dart';
import 'package:my_app/model/Store.dart';
import 'package:my_app/provider/store_provider.dart';
import 'package:provider/provider.dart';

class CafeList extends StatefulWidget {
  const CafeList({Key? key}) : super(key: key);

  @override
  State<CafeList> createState() => _CafeListState();
}

class _CafeListState extends State<CafeList>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final _selectedColor = Color(0xff9D9BFF);
  final _unselectedColor = Color(0xffCAC9FF);
  final c = [
    Tab(text: '리스트로 보기'),
    Tab(text: '지도로 보기'),
  ];
  // Future<List<CafeBasicInfo>>? cafeList;
  List<Store> storeList = [];

  @override
  void initState() {
    print("init state 호출");
    super.initState();
    Provider.of<StoreProvider>(context, listen: false).fetchStoreList();
    _tabController = TabController(length: 2, vsync: this);

    print("init state:: StoreProvider.fetchStoreList 호출 후 ");

    // _initRetrieval();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("매장 목록"), // 타이틀 이름 지정
          foregroundColor: Colors.black,
          // titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: false, // 타이틀 이름을 가운데 정렬
          elevation: 0.0, //elevation 속성을 통해 그림자 효과 제어
          backgroundColor: Colors.redAccent.withOpacity(0.0),
        ),
        body: SafeArea(
            // child: Expanded(
            // child: Container(
            // margin: EdgeInsets.fromLTRB(10, 20, 10, 21),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Container(
                height: kToolbarHeight - 8.0,
                decoration: BoxDecoration(
                  color: Color(0xffCAC9FF),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: getTabBarWidget(),
              ),
              // getTabBarWidget(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(2, 20, 2, 20),
                      child: getList(context),
                    ),
                    CafeListMapView(
                      storeList: storeList,
                    )
                  ],
                ),
              ),
            ]))
        // )
        // )
        );
  }

  Widget getTabBarWidget() {
    return TabBar(
      controller: _tabController,
      // isScrollable: true,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), color: _selectedColor),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      tabs: [
        Container(
          alignment: Alignment.center,
          // width: (MediaQuery.of(context).size.width) / 2,
          child: Tab(text: '리스트로 보기'),
        ),
        Container(
            alignment: Alignment.center,
            // width: (MediaQuery.of(context).size.width),
            child: Text(
              "지도로 보기",
            )),
      ],
      // tabs: _tabs,
    );
  }

  Widget getList(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Consumer<StoreProvider>(
          builder: (context, storeProvider, child) {
            List<Store> storeList = storeProvider.storeCards ?? [];
            print("cafe_list_builder:: ${storeList}");
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    itemCount: storeList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == storeList.length) {
                        return Column(
                          children: <Widget>[
                            // storeCard(null),
                            Text("검색된 매장이 없습니다.")
                          ],
                        );
                      } else {
                        return storeCard(storeList[index]);
                      }
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      if (index == 0) return SizedBox.shrink();
                      return const Divider();
                    },
                  ),
                )
              ],
            );
          },
        ));
  }

  void showModalDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Text("dialog");
          // return LoplatDialogCenterConfirm(
          //   children: [
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Expanded(
          //           child : Padding(
          //             padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
          //             child: Center(
          //               child: Text(message, textAlign: TextAlign.center,
          //               style: const TextStyle(
          //                   color: Colors.black,
          //                   fontSize: 18,
          //                   fontFamily: 'AppleSDGothicNeo',
          //                     fontWeight: FontWeight.w700,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          //   confirmLabel: '확인',
          // );
        });
  }

  GestureDetector storeCard(Store? store) {
    return GestureDetector(
        onTap: () {
          print("item 선택됨");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MenuPage(
                        storeId: store.store_id,
                        storeName: store.store_name,
                      )));
        },
        child: SizedBox(
          height: 130,
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(5),
            // decoration: BoxDecoration(
            //   border: Border.all(color: Color.fromARGB(255, 0, 0, 0)),
            //   borderRadius: BorderRadius.all(Radius.circular(5.0)),
            // ),
            width: 400,
            child: Row(children: [
              Expanded(
                  child: Image.network(store!.store_logo,
                      width: 90, height: 90, fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                return Image(
                    image: AssetImage('assets/coffee.jpeg'),
                    width: 90,
                    height: 90,
                    fit: BoxFit.fill);
              })),
              Spacer(),
              Text("${store.store_name}"),
            ]),
          ),
        ));
  }
}
