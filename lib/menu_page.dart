import 'package:flutter/material.dart';
import 'package:cafeplatform/Payment/select_gift_type_page.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:provider/provider.dart';
import 'package:cafeplatform/dummyData.dart';

class MenuPage extends StatefulWidget {
  MenuPage({super.key, required this.storeId, required this.storeName});

  int storeId;
  String storeName;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("_MenuPageState init state 호출");
    super.initState();
    if (widget.storeId < 0) {
      // setState(() {
      //   store = StoreDummyRepository.stores[0];
      // });
      return;
    }
    Provider.of<MenuProvider>(context, listen: false)
        .fetchMenuList(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    print("_MenuPageState build 호출 ${widget.storeId}");
    if (widget.storeId < 0) {
      // storeId가 0보다 작으면 더미 데이터
      final menuList = MenuDummyRepository.menus;
      return _buildMenuGrid(menuList);
    } else {
      return Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          List<Menu> menuList = menuProvider.menuCards ?? [];
          return _buildMenuGrid(menuList);
        },
      );
    }
  }

  Widget _buildMenuGrid(List<Menu> menuList) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: ListView.builder(
          itemCount: menuList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildMenuCard(menuList[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    return GestureDetector(
      onTap: () {
        Provider.of<MenuProvider>(context, listen: false).setSelectedMenu(menu);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectGiftPage(menu: menu),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                menu.menu_image_url ?? "",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset('assets/menu.png',
                    width: 80, height: 80, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 18),
            // 오른쪽 텍스트 영역 (세로정렬)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.name ?? "",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('${menu.price}원',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  SizedBox(height: 8),
                  Text(menu.description ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
