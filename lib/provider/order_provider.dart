import 'package:flutter/foundation.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/order.dart';

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
      this.orderCards = [
        Order(
            order_id: 1,
            store_id: 1,
            order_number: 1,
            sender: "홍길동",
            created_time: DateTime(2025, 4, 1),
            price: 5000,
            menu_name: "아메리카노",
            status: 'COMPLETED'),
        Order(
            order_id: 2,
            store_id: 1,
            order_number: 1,
            sender: "김철수",
            created_time: DateTime(2025, 4, 3),
            price: 5000,
            menu_name: "카페라떼",
            status: 'COMPLETED')
      ];
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

  Future<void> fetchOrderList(int? userId) async {
    if (userId == null || userId <= 0) {
      print("order_provider::fetchOrderList:: 유효하지 않은 user_id");
      setOrderCard([]);
      return;
    }

    try {
      print("order_provider::fetchOrderList:: fetch 호출, user_id: $userId");
      var response = await Api().client.getOrderList(userId);
      var orderList = response.orderList;

      print("order_provider::fetchOrderList:: 주문 개수: ${orderList.length}");
      setOrderCard(orderList);
    } catch (error) {
      print("order_provider::fetchOrderList:: fetch 오류: $error");
      setOrderCard([]);
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
    print("store_provider::getDetailStore:: fetch 호출");

    var response = await Api().client.getStoreDetailInfo(storeId);
    print("provider store2 ${response.store.store_photo_urls}");
    // notifyListeners();

    return response.store;
  }
}
