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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("store 이름"),
                      Expanded(
                        child: getList(context),
                      ),
                    ]))));
  }

  Widget getList(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        List<Menu> menuList = menuProvider.menuCards ?? [];
        return Expanded(
            child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2, // 한 줄에 두 개의 항목을 표시
          childAspectRatio: 0.6, // 각 항목의 가로 세로 비율 설정
          mainAxisSpacing: 10, // 수직 간격 설정
          crossAxisSpacing: 20, // 수평 간격 설정
          children: List.generate(menuList.length, (index) {
            return getMenu(menuList[index]);
          }),
        ));
      },
    );
  }

  Widget getMenu(Menu? menu) {
    double widgetWidth = MediaQuery.of(context).size.width / 2;

    return GestureDetector(
      onTap: () {
        print("item 선택됨");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SelectGiftPage()));
      },
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${menu?.name}"),
          Text("${menu?.description}"),
          Text("${menu?.price}"),
        ])
      ]),
    );
  }
}
