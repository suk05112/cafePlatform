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
  final _tabs = [
    Tab(text: '리스트로 보기'),
    Tab(text: '지도로 보기'),
  ];
  Future<List<CafeBasicInfo>>? cafeList;
  List<Store>? storeList;

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
        body: SafeArea(
            child: SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 21),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "cafe",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: kToolbarHeight - 8.0,
                            decoration: BoxDecoration(
                              color: Color(0xffCAC9FF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: getTabBarWidget(),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(2, 20, 2, 20),
                            height: MediaQuery.of(context).size.height -
                                kToolbarHeight -
                                50,
                            width: double.infinity,
                            child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                Container(
                                  height: 500,
                                  child: getList(context),
                                ),
                                // getList(context),
                                CafeListMapView()
                              ],
                            ),
                          ),
                        ])))));
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
          width: (MediaQuery.of(context).size.width - 80) / 2,
          child: Tab(text: '리스트로 보기'),
        ),
        Container(
            width: (MediaQuery.of(context).size.width - 80) / 2,
            child: Text(
              "지도로 보기",
              style: TextAssset.body2,
            )
            // Tab(text: '평일/주말 달라요'),
            ),
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
                ),
              ],
            );
          },
        ));
  }

  void getStoreList(BuildContext context) async {
    final currentContext = scaffoldKey.currentContext;

    try {
      final response = await Api().client.getStoreList(1);
      currentContext?.read<StoreProvider>().setStoreCard(response.body.store);
      print("get store list");
      print(response);
      // _isFirstSlotLoaded = true;
    } catch (error) {
      // stopLoading();
      currentContext?.read<StoreProvider>().setStoreCard(null);
      // _isFirstSlotLoaded = true;
      showModalDialog(context,
          "서버에서 오류가 발생하였습니다.\n앱 종료 후 다시 접속해 주세요.\n문제가 지속될 경우, 고객센터(service@loplat.com)로 문의부탁드립니다.");
      rethrow;
    }
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
              context, MaterialPageRoute(builder: (context) => MenuPage()));
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
                  child:
                      // Image(
                      //     image: AssetImage('assets/coffee.png'),
                      //     width: 90,
                      //     height: 90,
                      //     fit: BoxFit.fill)
                      Image.network(store!.store_logo,
                          width: 90, height: 90, fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                return Image(
                    image: AssetImage('assets/coffee.jpeg'),
                    width: 90,
                    height: 90,
                    fit: BoxFit.fill);
              })),
              Spacer(),
              Text("${store?.store_name}"),
            ]),
          ),
        ));
  }
}
