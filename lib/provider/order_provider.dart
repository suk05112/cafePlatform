import 'package:flutter/foundation.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/order.dart';

class OrderProvider extends ChangeNotifier {
  late List<Order>? orderCards = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setOrderCard(List<Order>? orderCards) {
    this.orderCards = orderCards ?? [];
    print("order_provider::setOrderCard:: 주문 개수: ${this.orderCards?.length ?? 0}");
    if (this.orderCards != null && this.orderCards!.isNotEmpty) {
      print("order_provider::setOrderCard:: 첫 번째 주문: ${this.orderCards!.first.toJson()}");
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

    _isLoading = true;
    notifyListeners();

    try {
      print("order_provider::fetchOrderList:: fetch 호출, user_id: $userId");
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getOrderList(userId);
      var orderList = response.orderList;

      print("order_provider::fetchOrderList:: 응답 받음, 주문 개수: ${orderList.length}");
      if (orderList.isNotEmpty) {
        print("order_provider::fetchOrderList:: 첫 번째 주문 정보: ${orderList.first.toJson()}");
      }
      setOrderCard(orderList);
    } catch (error) {
      print("order_provider::fetchOrderList:: fetch 오류: $error");
      print("order_provider::fetchOrderList:: 스택 트레이스: ${error.toString()}");
      setOrderCard([]);
    } finally {
      _isLoading = false;
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
    print("store_provider::getDetailStore:: fetch 호출");

    var response = await Api().client.getStoreDetailInfo(storeId);
    print("provider store2 ${response.store.store_photo_urls}");
    // notifyListeners();

    return response.store;
  }
}
