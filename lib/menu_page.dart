import 'package:flutter/material.dart';
import 'package:my_app/Payment/select_gift_type_page.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/model/menu.dart';
import 'package:my_app/provider/menu_provider.dart';
import 'package:my_app/provider/store_provider.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("init state 호출");
    super.initState();
    Provider.of<MenuProvider>(context, listen: false).fetchMenuList();
  }

  // Future<void> fetchMenuList() async {
  //   try {
  //     print("store_provider::fetchStoreList:: fetch 호출");
  //     var response = await Api().client.getMenuList(1);
  //     var menuList = response.menuList;
  //     setStoreCard(storeList);
  //   } catch (error) {
  //     print("store_provider::fetchStoreList:: fetch 오류: $error");
  //     setStoreCard(null);
  //   }
  // }

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
                          Text("store 이름"),
                          Container(
                            height: 500,
                            child: getList(context),
                          ),
                          // GridView.count(
                          //   shrinkWrap: true,
                          //   physics: NeverScrollableScrollPhysics(),
                          //   crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                          //   childAspectRatio: 1 / 1.7, //item 의 가로 1, 세로 2 의 비율
                          //   mainAxisSpacing: 5, //수평 Padding
                          //   crossAxisSpacing: 2, //수직 Padding
                          //   children:
                          //   getList(context);
                          // List.generate(12, (index) {
                          //   //item 의 반목문 항목 형성
                          //   return getList(context);
                          // }
                          // ),
                          // ),
                        ])))));
  }

  Widget getList(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Consumer<MenuProvider>(
          builder: (context, menuProvider, child) {
            List<Menu> menuList = menuProvider.menuCards ?? [];
            print("menu_list_builder:: ${menuList}");
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    itemCount: menuList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == menuList.length) {
                        return Column(
                          children: <Widget>[
                            // storeCard(null),
                            Text("등록된 없습니다.")
                          ],
                        );
                      } else {
                        return getMenu(menuList[index]);
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

  Widget getMenu(Menu? menu) {
    double widgetWidth = MediaQuery.of(context).size.width / 2;

    return GestureDetector(
        onTap: () {
          print("item 선택됨");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SelectGiftPage()));
        },
        child: Container(
          // color: Colors.white,
          padding: EdgeInsets.fromLTRB(10, 20, 10, 21),
          // decoration: BoxDecoration(
          //     color: Colors.blue,
          //     borderRadius: BorderRadius.circular(5), //모서리를 둥글게
          //     border: Border.all(color: Colors.black12, width: 3)),
          child: Column(children: [
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image(
                  image: AssetImage('assets/menu.png'),
                  width: widgetWidth,
                  height: widgetWidth,
                  fit: BoxFit.fill),
            ),
            //         Image.network(store!.store_logo,
            //             width: 90, height: 90, fit: BoxFit.fill,
            //             errorBuilder: (context, error, stackTrace) {
            //   return Image(
            //       image: AssetImage('assets/logo.jpeg'),
            //       width: 90,
            //       height: 90,
            //       fit: BoxFit.fill);
            // })
            Spacer(),
            Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${menu?.name}"),
                  Text("부드러운 디저트 아이스 카페 아메리카노T 2잔"),
                  Text("12000원")
                ])

            // Text("${store?.store_name}"),
          ]),
        ));
  }
}
