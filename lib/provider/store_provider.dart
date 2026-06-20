import 'package:flutter/foundation.dart';
import 'package:cafeplatform/api/API.dart';
import 'package:cafeplatform/dummyData.dart';
import 'package:cafeplatform/model/Store.dart';
import 'package:cafeplatform/model/region.dart';

class StoreProvider extends ChangeNotifier {
  Store? _store;
  late List<Store>? storeCards = []; // 하위 호환성을 위한 기존 필드
  List<Region> _availableRegions = [];
  String? _selectedRegionCode;

  // 리스트 뷰용 상태
  List<Store>? _listViewStores = [];
  String? _listViewNextCursor;
  bool _listViewHasMore = false;
  bool _listViewIsLoading = false;
  bool _listViewIsLoadingMore = false;
  String? _listViewCurrentDistrictCode;

  // 지도 뷰용 상태
  List<Store>? _mapViewStores = [];
  String? _mapViewNextCursor;
  bool _mapViewHasMore = false;
  bool _mapViewIsLoadingMore = false;
  String? _mapViewCurrentDistrictCode;

  Store? get store => _store;
  List<Region> get availableRegions => _availableRegions;
  String? get selectedRegionCode => _selectedRegionCode;

  // 리스트 뷰 getters
  List<Store>? get listViewStores => _listViewStores;
  String? get listViewNextCursor => _listViewNextCursor;
  bool get listViewHasMore => _listViewHasMore;
  bool get listViewIsLoading => _listViewIsLoading;
  bool get listViewIsLoadingMore => _listViewIsLoadingMore;

  // 지도 뷰 getters
  List<Store>? get mapViewStores => _mapViewStores;
  String? get mapViewNextCursor => _mapViewNextCursor;
  bool get mapViewHasMore => _mapViewHasMore;
  bool get mapViewIsLoadingMore => _mapViewIsLoadingMore;

  // 하위 호환성을 위한 getters (리스트 뷰용)
  String? get nextCursor => _listViewNextCursor;
  bool get hasMore => _listViewHasMore;
  bool get isLoadingMore => _listViewIsLoadingMore;

  void setStoreCard(List<Store>? storeCards) {
    // 하위 호환성을 위해 기존 필드도 업데이트 (리스트 뷰용)
    this.storeCards = storeCards ?? [];
    _listViewStores = storeCards ?? [];
    _listViewNextCursor = null;
    _listViewHasMore = false;
    notifyListeners();
  }

  void appendStoreCard(
      List<Store> newStores, String? nextCursor, bool? hasMore) {
    // 하위 호환성을 위해 기존 필드도 업데이트 (리스트 뷰용)
    this.storeCards = [...(this.storeCards ?? []), ...newStores];
    _listViewStores = [...(_listViewStores ?? []), ...newStores];
    _listViewNextCursor = nextCursor;
    _listViewHasMore = hasMore ?? false;
    _listViewIsLoadingMore = false;
    notifyListeners();
  }

  // 리스트 뷰용 메서드
  void setListViewStores(List<Store>? stores) {
    _listViewStores = stores ?? [];
    _listViewNextCursor = null;
    _listViewHasMore = false;
    // 하위 호환성을 위해 기존 필드도 업데이트
    this.storeCards = stores ?? [];
    notifyListeners();
  }

  void appendListViewStores(
      List<Store> newStores, String? nextCursor, bool? hasMore) {
    _listViewStores = [...(_listViewStores ?? []), ...newStores];
    _listViewNextCursor = nextCursor;
    _listViewHasMore = hasMore ?? false;
    _listViewIsLoadingMore = false;
    // 하위 호환성을 위해 기존 필드도 업데이트
    this.storeCards = [...(this.storeCards ?? []), ...newStores];
    notifyListeners();
  }

  // 지도 뷰용 메서드
  void setMapViewStores(List<Store>? stores) {
    _mapViewStores = stores ?? [];
    _mapViewNextCursor = null;
    _mapViewHasMore = false;
    notifyListeners();
  }

  void appendMapViewStores(
      List<Store> newStores, String? nextCursor, bool? hasMore) {
    _mapViewStores = [...(_mapViewStores ?? []), ...newStores];
    _mapViewNextCursor = nextCursor;
    _mapViewHasMore = hasMore ?? false;
    _mapViewIsLoadingMore = false;
    notifyListeners();
  }

  void setSelectedRegionCode(String? regionCode) {
    _selectedRegionCode = regionCode;
    notifyListeners();
  }

  void resetPagination() {
    // 리스트 뷰만 리셋 (지도 뷰는 유지)
    _listViewNextCursor = null;
    _listViewHasMore = false;
    _listViewIsLoadingMore = false;
    _listViewStores = [];
    storeCards = [];
    notifyListeners();
  }

  void resetMapViewPagination() {
    // 지도 뷰만 리셋
    _mapViewNextCursor = null;
    _mapViewHasMore = false;
    _mapViewIsLoadingMore = false;
    _mapViewStores = [];
    notifyListeners();
  }

  Future<void> fetchStoreListByDistrict(String districtCode,
      {String? cursor, int limit = 20, bool append = false}) async {
    // 리스트 뷰용으로 기본 동작 유지
    await fetchListViewStoresByDistrict(districtCode,
        cursor: cursor, limit: limit, append: append);
  }

  // 리스트 뷰용 메서드
  Future<void> fetchListViewStoresByDistrict(String districtCode,
      {String? cursor, int limit = 20, bool append = false}) async {
    if (_listViewIsLoadingMore) return;

    try {
      _listViewCurrentDistrictCode = districtCode;
      if (!append) {
        _listViewIsLoading = true;
        _listViewIsLoadingMore = false;
        notifyListeners();
      } else {
        _listViewIsLoadingMore = true;
        notifyListeners();
      }

      print(
          "store_provider::fetchListViewStoresByDistrict:: fetch 호출 - districtCode: $districtCode, cursor: $cursor, limit: $limit");
      var response = await Api()
          .client
          .getStoreListByDistrict(districtCode, cursor, limit);
      var storeList = response.store;

      final nextCursor = response.pagination?.next_cursor;
      final hasNext = response.pagination?.has_next ?? false;
      print(
          "store_provider::fetchListViewStoresByDistrict:: 응답 받음 - store 개수: ${storeList.length}, next_cursor: $nextCursor, has_next: $hasNext");

      if (append) {
        appendListViewStores(storeList, nextCursor, hasNext);
      } else {
        _listViewStores = storeList;
        _listViewNextCursor = nextCursor;
        _listViewHasMore = hasNext;
        _listViewIsLoading = false;
        _listViewIsLoadingMore = false;
        this.storeCards = storeList;
        notifyListeners();
      }
    } catch (error) {
      print("store_provider::fetchListViewStoresByDistrict:: fetch 오류: $error");
      _listViewIsLoading = false;
      _listViewIsLoadingMore = false;
      notifyListeners();
      if (!append) {
        setListViewStores(StoreDummyRepository.stores);
      }
    }
  }

  // 지도 뷰용 메서드
  Future<void> fetchMapViewStoresByDistrict(String districtCode,
      {String? cursor, int limit = 20, bool append = false}) async {
    if (_mapViewIsLoadingMore) return;

    try {
      _mapViewCurrentDistrictCode = districtCode;
      if (!append) {
        _mapViewIsLoadingMore = false;
      } else {
        _mapViewIsLoadingMore = true;
        notifyListeners();
      }

      print(
          "store_provider::fetchMapViewStoresByDistrict:: fetch 호출 - districtCode: $districtCode, cursor: $cursor, limit: $limit");
      var response = await Api()
          .client
          .getStoreListByDistrict(districtCode, cursor, limit);
      var storeList = response.store;

      final nextCursor = response.pagination?.next_cursor;
      final hasNext = response.pagination?.has_next ?? false;
      print(
          "store_provider::fetchMapViewStoresByDistrict:: 응답 받음 - store 개수: ${storeList.length}, next_cursor: $nextCursor, has_next: $hasNext");

      if (append) {
        appendMapViewStores(storeList, nextCursor, hasNext);
      } else {
        setMapViewStores(storeList);
        _mapViewNextCursor = nextCursor;
        _mapViewHasMore = hasNext;
      }
    } catch (error) {
      print("store_provider::fetchMapViewStoresByDistrict:: fetch 오류: $error");
      _mapViewIsLoadingMore = false;
      notifyListeners();
      if (!append) {
        setMapViewStores(StoreDummyRepository.stores);
      }
    }
  }

  // 지도 뷰용 현위치 검색
  Future<void> fetchMapViewStoresByLocation(double lat, double lng) async {
    try {
      print(
          "store_provider::fetchMapViewStoresByLocation:: fetch 호출 - lat: $lat, lng: $lng");
      var response = await Api().client.getStoreListByLocation(lat, lng);
      var storeList = response.store;

      print(
          "store_provider::fetchMapViewStoresByLocation:: 응답 받음 - store 개수: ${storeList.length}");
      setMapViewStores(storeList);
    } catch (error) {
      print("store_provider::fetchMapViewStoresByLocation:: fetch 오류: $error");
      setMapViewStores([]);
    }
  }

  Future<void> loadMoreStores() async {
    // 리스트 뷰용
    if (_listViewIsLoadingMore ||
        !_listViewHasMore ||
        _listViewNextCursor == null ||
        _listViewCurrentDistrictCode == null) {
      return;
    }

    await fetchListViewStoresByDistrict(_listViewCurrentDistrictCode!,
        cursor: _listViewNextCursor!, append: true);
  }

  Future<void> loadMoreMapViewStores() async {
    // 지도 뷰용
    if (_mapViewIsLoadingMore ||
        !_mapViewHasMore ||
        _mapViewNextCursor == null ||
        _mapViewCurrentDistrictCode == null) {
      return;
    }

    await fetchMapViewStoresByDistrict(_mapViewCurrentDistrictCode!,
        cursor: _mapViewNextCursor!, append: true);
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
    if (_availableRegions.isNotEmpty) return;
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

  // 매장 상세 메모리 캐시 (storeId → (store, 캐시 시각))
  final Map<int, ({Store store, DateTime cachedAt})> _detailCache = {};
  static const Duration _cacheTtl = Duration(hours: 1);

  Future<Store> fetchDetailStore(int storeId) async {
    final cached = _detailCache[storeId];
    if (cached != null && DateTime.now().difference(cached.cachedAt) < _cacheTtl) {
      _store = cached.store;
      return cached.store;
    }

    print("store_provider::getDetailStore:: fetch 호출");
    var response = await Api().client.getStoreDetailInfo(storeId);
    _store = response.store;
    _detailCache[storeId] = (store: response.store, cachedAt: DateTime.now());
    notifyListeners();

    return response.store;
  }
}
