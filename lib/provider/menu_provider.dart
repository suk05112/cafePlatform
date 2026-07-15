import 'package:flutter/foundation.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/menu.dart';

class MenuProvider extends ChangeNotifier {
  late Menu? _menu;
  late Menu? _selectedMenu;

  late List<Menu>? menuCards = [];
  bool isLoading = false;

  // 메뉴 목록 메모리 캐시 (storeId → (menus, 캐시 시각))
  final Map<int, ({List<Menu> menus, DateTime cachedAt})> _menuCache = {};
  static const Duration _cacheTtl = Duration(minutes: 1);

  void setSelectedMenu(Menu menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  Menu getSelectedMenu() {
    return _selectedMenu!;
  }

  void setMenuCard(List<Menu>? menuCards) {
    // if ((storeCards?.length ?? 0) > 0) {
    //     slotCardsListVisible = true;
    // } else {
    //     slotCardsListVisible = false;
    // }

    this.menuCards = menuCards;
    if (this.menuCards == null) {
      // || this.menuCards!.isEmpty) {
      this.menuCards = [
        // Menu(
        //   menu_id: -1,
        //   store_id: -1,
        //   name: 'test Menu',
        //   price: 100,
        //   menu_image_url: '',
        //   description: 'test desc',
        //   status: "ACTIVE",
        // )
      ];
    } else {
    }
    notifyListeners();
  }

  Future<void> fetchMenuList(int storeId) async {
    final cached = _menuCache[storeId];
    if (cached != null && DateTime.now().difference(cached.cachedAt) < _cacheTtl) {
      menuCards = cached.menus;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    try {
      var response = await Api().client.getMenuList(storeId);
      var menuList = response.menuList ?? [];
      _menuCache[storeId] = (menus: menuList, cachedAt: DateTime.now());
      setMenuCard(menuList);
    } catch (error) {
      setMenuCard(null);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<List<Store>> getStoreList() async {
  //   print("store_provider::getStoreList:: fetch 호출");
  //   Api().client.getStoreList(2).then((response) => {
  //         for (var res in response.body.store) {print(res.toString())}
  //       });
  //   var response = await Api().client.getStoreList(2);
  //   notifyListeners();

  //   return response.body.store;
  // }

  Future<Store> getDetailStore(int storeId) async {

    var response = await Api().client.getStoreDetailInfo(storeId);
    // notifyListeners();

    return response.store;
  }
}
