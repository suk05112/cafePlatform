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
class StoreListPagination {
  @JsonKey(name: 'cursor')
  String? cursor;

  @JsonKey(name: 'next_cursor')
  String? next_cursor;

  @JsonKey(name: 'limit')
  int limit;

  @JsonKey(name: 'has_next')
  bool has_next;

  StoreListPagination({
    this.cursor,
    this.next_cursor,
    required this.limit,
    required this.has_next,
  });

  factory StoreListPagination.fromJson(Map<String, dynamic> json) {
    // cursor와 next_cursor는 문자열 또는 int로 올 수 있음 (하위 호환성)
    String? parseCursor(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is int) return value.toString();
      return value.toString();
    }

    return StoreListPagination(
      cursor: parseCursor(json['cursor']),
      next_cursor: parseCursor(json['next_cursor']),
      limit: json['limit'] as int? ?? 50,
      has_next: json['has_next'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'next_cursor': next_cursor,
      'limit': limit,
      'has_next': has_next,
    };
  }
}

@JsonSerializable()
class StoreListResponse {
  List<Store> store;
  @JsonKey(name: 'pagination')
  StoreListPagination? pagination;

  StoreListResponse({
    required this.store,
    this.pagination,
  });

  factory StoreListResponse.fromJson(Map<String, dynamic> json) {
    var storeListData = json['store'];

    if (storeListData == null || storeListData is! List) {
      return StoreListResponse(
        store: [],
        pagination: json['pagination'] != null
            ? StoreListPagination.fromJson(
                json['pagination'] as Map<String, dynamic>)
            : null,
      );
    }

    final storeList = storeListData
        .map((e) => Store.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = json['pagination'] != null
        ? StoreListPagination.fromJson(
            json['pagination'] as Map<String, dynamic>)
        : null;

    return StoreListResponse(
      store: storeList,
      pagination: pagination,
    );
  }

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
  @JsonKey(name: 'store_id')
  int store_id;
  @JsonKey(name: 'store_name')
  String store_name;
  @JsonKey(name: 'store_logo')
  String store_logo;
  @JsonKey(name: 'store_lat')
  double? store_lat;
  @JsonKey(name: 'store_lng')
  double? store_lng;
  @JsonKey(name: 'store_address')
  String? store_address;
  @JsonKey(name: 'status')
  String? status;
  @JsonKey(name: 'inspection_status')
  String? inspection_status;
  @JsonKey(name: 'open_yn')
  String? open_yn;
  @JsonKey(name: 'store_description')
  String? store_description;

  StoreCard({
    required this.store_id,
    required this.store_name,
    required this.store_logo,
    this.store_lat,
    this.store_lng,
    this.store_address,
    this.status,
    this.inspection_status,
    this.open_yn,
    this.store_description,
  });

  factory StoreCard.fromJson(Map<String, dynamic> json) {
    return StoreCard(
      store_id: (json['store_id'] as num?)?.toInt() ?? 0,
      store_name: json['store_name'] as String? ?? '',
      store_logo: json['store_logo'] as String? ?? '',
      store_lat: json['store_lat'] != null
          ? (json['store_lat'] as num).toDouble()
          : null,
      store_lng: json['store_lng'] != null
          ? (json['store_lng'] as num).toDouble()
          : null,
      store_address: json['store_address'] as String?,
      status: json['status'] as String?,
      inspection_status: json['inspection_status'] as String?,
      open_yn: json['open_yn'] as String?,
      store_description: json['store_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': store_id,
      'store_name': store_name,
      'store_logo': store_logo,
      'store_lat': store_lat,
      'store_lng': store_lng,
      'store_address': store_address,
      'status': status,
      'inspection_status': inspection_status,
      'open_yn': open_yn,
      'store_description': store_description,
    };
  }
}
