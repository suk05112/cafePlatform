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
    if (this.orderCards != null && this.orderCards!.isNotEmpty) {
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
      setOrderCard([]);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Api().setBaseClient(Api.BASE_URL);
      var response = await Api().client.getOrderList(userId);
      var orderList = response.orderList;

      if (orderList.isNotEmpty) {
      }
      setOrderCard(orderList);
    } catch (error) {
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

    var response = await Api().client.getStoreDetailInfo(storeId);
    // notifyListeners();

    return response.store;
  }
}
