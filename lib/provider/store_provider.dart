import 'package:flutter/foundation.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/dummyData.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/region.dart';

class StoreProvider extends ChangeNotifier {
  Store? _store;
  late List<Store>? storeCards = [];
  List<Region> _availableRegions = [];
  String? _selectedRegionCode;

  Store? get store => _store;
  List<Region> get availableRegions => _availableRegions;
  String? get selectedRegionCode => _selectedRegionCode;

  void setStoreCard(List<Store>? storeCards) {
    this.storeCards = storeCards ?? [];
    notifyListeners();
  }

  void setSelectedRegionCode(String? regionCode) {
    _selectedRegionCode = regionCode;
    notifyListeners();
  }

  Future<void> fetchStoreList() async {
    try {
      print("store_provider::fetchStoreList:: fetch 호출");
      var response = await Api().client.getStoreList();
      var storeList = response.store;
      storeList.forEach(
        (element) {
          print(
              "${element.store_name} ${element.store_lat} ${element.store_lng} ");
        },
      );
      setStoreCard(storeList);
    } catch (error) {
      print("store_provider::fetchStoreList:: fetch 오류: $error");
      setStoreCard(StoreDummyRepository.stores);
    }
  }

  Future<void> fetchAvailableRegions() async {
    try {
      print("store_provider::fetchAvailableRegions:: fetch 호출");
      var response = await Api().client.getAvailableRegions();
      _availableRegions = response.regions;
      notifyListeners();
    } catch (error) {
      print("store_provider::fetchAvailableRegions:: fetch 오류: $error");
      _availableRegions = [];
      notifyListeners();
    }
  }

  List<Store>? getStoreList() {
    return storeCards;
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

  Future<Store> fetchDetailStore(int storeId) async {
    print("store_provider::getDetailStore:: fetch 호출");

    var response = await Api().client.getStoreDetailInfo(storeId);
    print(
        "store_provider::getDetailStore:: response.store.store_address: ${response.store.store_address}");
    print(
        "store_provider::getDetailStore:: response.store 전체: ${response.store.toJson()}");
    _store = response.store;
    notifyListeners();

    return response.store;
  }

  List<Store> _offlineFallbackStores() {
    return [
      Store(
        store_id: 101,
        store_name: "광화문 로스터리",
        store_address: "서울특별시 종로구 세종대로 175",
        store_lat: 37.5720,
        store_lng: 126.9769,
        store_description: "시청 뷰를 즐길 수 있는 핸드드립 전문 카페",
        store_logo: "",
      ),
      Store(
        store_id: 102,
        store_name: "홍대 브루잉랩",
        store_address: "서울특별시 마포구 와우산로 45",
        store_lat: 37.5525,
        store_lng: 126.9238,
        store_description: "싱글 오리진 콜드브루와 디저트가 인기인 공간",
        store_logo: "",
      ),
      Store(
        store_id: 103,
        store_name: "성수 리버뷰 카페",
        store_address: "서울특별시 성동구 뚝섬로 377",
        store_lat: 37.5447,
        store_lng: 127.0563,
        store_description: "한강을 내려다보는 루프탑 테라스 카페",
        store_logo: "",
      ),
    ];
  }
}
