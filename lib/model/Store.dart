import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Store {
  int owner_id;
  int store_id;
  String store_name;
  String store_logo;
  String store_telephone;
  String store_description;
  List<String> store_photo_urls;
  int store_photo_cnt;
  String store_address;
  double store_lat, store_lng;
  String? inspection_status;
  DateTime? updated_time;
  bool isDummy;
  String? region_name;
  String? region_code;
  String? district_name;
  String? district_code;
  String? open_yn;

  Store(
      {this.owner_id = 0,
      this.store_id = 0,
      this.store_name = "",
      this.store_logo = "",
      this.store_telephone = "",
      this.store_description = "",
      this.store_photo_urls = const [],
      this.store_photo_cnt = 0,
      this.store_address = "",
      this.store_lat = 10,
      this.store_lng = 0,
      this.inspection_status,
      this.updated_time,
      this.isDummy = false,
      this.region_name,
      this.region_code,
      this.district_name,
      this.district_code,
      this.open_yn
      // this.business_registration = File(),
      });
  // Store({
  //   required this.owner_id,
  //   required this.store_name,
  //   required this.store_logo,
  //   required this.store_telephone,
  //   required this.store_description,
  //   required this.store_photo,
  //   required this.store_photo_cnt,
  //   required this.store_address,
  //   required this.store_lat,
  //   required this.store_lng,
  //   required this.business_registration,
  // });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);
}

@JsonSerializable()
class Body2 {
  List<Store> store;

  Body2({required this.store});

  factory Body2.fromJson(Map<String, dynamic> json) => _$Body2FromJson(json);
  Map<String, dynamic> toJson() => _$Body2ToJson(this);
}

@JsonSerializable()
class StoreListResponse {
  List<Store> store;

  StoreListResponse({
    required this.store,
  });

  factory StoreListResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreListResponseToJson(this);
}

@JsonSerializable()
class StoreResponse {
  Store store;

  StoreResponse({required this.store});

  factory StoreResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreResponseToJson(this);
}

@JsonSerializable()
class StoreCard {
  int store_id;
  String store_name;
  String store_logo;
  double store_lat, store_lng;

  StoreCard(
      {required this.store_id,
      required this.store_name,
      required this.store_logo,
      required this.store_lat,
      required this.store_lng});

  factory StoreCard.fromJson(Map<String, dynamic> json) =>
      _$StoreCardFromJson(json);
  Map<String, dynamic> toJson() => _$StoreCardToJson(this);
}
