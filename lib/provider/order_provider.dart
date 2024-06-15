import 'package:flutter/foundation.dart';
import 'package:my_app/api/API.dart';
import 'package:my_app/model/Store.dart';
import 'package:my_app/model/order.dart';

class OrderProvider extends ChangeNotifier {
  late Order? _order;
  late List<Order>? orderCards = [];

  void setOrderCard(List<Order>? orderCards) {
    // if ((storeCards?.length ?? 0) > 0) {
    //     slotCardsListVisible = true;
    // } else {
    //     slotCardsListVisible = false;
    // }

    this.orderCards = orderCards;
    if (this.orderCards == null || this.orderCards!.isEmpty) {
      print("여기 탐");
      this.orderCards = [Order(store_id: -1)];
    } else {
      print("여기 안탐");
    }
    notifyListeners();
  }

  // Future<void> fetchStoreList() async {
  //   try {
  //     print("store_provider::fetchStoreList:: fetch 호출");
  //     var response = await Api().client.getStoreList(1);
  //     var orderList = response.body.store;
  //     orderList.forEach(
  //       (element) {
  //         print(
  //             "${element.store_name} ${element.store_lat} ${element.store_lng} ");
  //       },
  //     );
  //     setOrderCard(orderList);
  //   } catch (error) {
  //     print("store_provider::fetchStoreList:: fetch 오류: $error");
  //     setOrderCard(null);
  //   }
  // }

  List<Order>? getStoreList() {
    return orderCards;
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
    print("store_provider::getDetailStore:: fetch 호출");

    var response = await Api().client.getStoreDetailInfo(storeId);
    print("provider store2 ${response.store.store_photo_urls}");
    // notifyListeners();

    return response.store;
  }
}
