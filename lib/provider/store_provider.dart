import 'package:flutter/foundation.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/model/Store.dart';

class StoreProvider extends ChangeNotifier {
  late Store? _store;
  late List<Store>? storeCards = [];

  void setStoreCard(List<Store>? storeCards) {
    // if ((storeCards?.length ?? 0) > 0) {
    //     slotCardsListVisible = true;
    // } else {
    //     slotCardsListVisible = false;
    // }

    this.storeCards = storeCards;
    if (this.storeCards == null || this.storeCards!.isEmpty) {
      print("여기 탐");
      this.storeCards = [
        Store(owner_id: -1, store_id: -1, store_name: "test store")
      ];
    } else {
      print("여기 안탐");
    }
    notifyListeners();
  }

  Future<void> fetchStoreList() async {
    try {
      print("store_provider::fetchStoreList:: fetch 호출");
      var response = await Api().client.getStoreList(1);
      var storeList = response.body.store;
      setStoreCard(storeList);
    } catch (error) {
      print("store_provider::fetchStoreList:: fetch 오류: $error");
      setStoreCard(null);
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
