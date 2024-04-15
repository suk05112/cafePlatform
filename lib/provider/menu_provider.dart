import 'package:flutter/foundation.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/model/Store.dart';
import 'package:my_app/model/menu.dart';

class MenuProvider extends ChangeNotifier {
  late Menu? _menu;
  late Menu? _selectedMenu;

  late List<Menu>? menuCards = [];

  void setSelectedMenu(Menu menu) {
    this._selectedMenu = menu;
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
    if (this.menuCards == null || this.menuCards!.isEmpty) {
      print("여기 탐");
      this.menuCards = [
        Menu(
          menu_id: -1,
          store_id: -1,
          name: 'test Menu',
          price: 100,
          menu_image_url: '',
          description: 'test desc',
          status: 0,
        )
      ];
    } else {
      print("여기 안탐");
    }
    notifyListeners();
  }

  Future<void> fetchMenuList() async {
    try {
      print("store_provider::fetchStoreList:: fetch 호출");
      var response = await Api().client.getMenuList(1);
      var menuList = response.menuList;
      setMenuCard(menuList);
    } catch (error) {
      print("store_provider::fetchStoreList:: fetch 오류: $error");
      setMenuCard(null);
    }
  }

  Future<List<Store>> getStoreList() async {
    print("store_provider::getStoreList:: fetch 호출");
    Api().client.getStoreList(2).then((response) => {
          for (var res in response.body.store) {print(res.toString())}
        });
    var response = await Api().client.getStoreList(2);
    notifyListeners();

    return response.body.store;
  }

  Future<Store> getDetailStore(int storeId) async {
    print("store_provider::getDetailStore:: fetch 호출");

    var response = await Api().client.getStoreDetailInfo(storeId);
    print("provider store2 ${response.store.store_photo_urls}");
    // notifyListeners();

    return response.store;
  }
}
