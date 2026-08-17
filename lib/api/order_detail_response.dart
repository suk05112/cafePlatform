import 'package:json_annotation/json_annotation.dart';

part 'order_detail_response.g.dart';

@JsonSerializable()
class OrderDetailGifticon {
  @JsonKey(name: 'gifticon_id')
  int? gifticon_id;

  @JsonKey(name: 'gift_code')
  String? gift_code;

  int? type;
  String? sender;
  String? receiver;

  @JsonKey(name: 'receiver_phone')
  String? receiver_phone;

  String? status;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? validity;

  @JsonKey(name: 'menu_id')
  int? menu_id;

  @JsonKey(name: 'menu_name')
  String? menu_name;

  @JsonKey(name: 'menu_price')
  int? menu_price;

  @JsonKey(name: 'menu_url')
  String? menu_url;

  @JsonKey(
      name: 'created_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? created_at;

  @JsonKey(name: 'is_receiver_linked')
  bool? is_receiver_linked;

  OrderDetailGifticon({
    this.gifticon_id,
    this.gift_code,
    this.type,
    this.sender,
    this.receiver,
    this.receiver_phone,
    this.status,
    this.validity,
    this.menu_id,
    this.menu_name,
    this.menu_price,
    this.menu_url,
    this.created_at,
    this.is_receiver_linked,
  });

  factory OrderDetailGifticon.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailGifticonFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailGifticonToJson(this);

  static DateTime? _dateTimeFromJson(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String? _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

@JsonSerializable()
class OrderDetailResponse {
  @JsonKey(name: 'order_id')
  int? order_id;

  @JsonKey(name: 'order_no')
  String? order_no;

  @JsonKey(name: 'user_id')
  int? user_id;

  @JsonKey(name: 'store_id')
  int? store_id;

  @JsonKey(name: 'store_name')
  String? store_name;

  @JsonKey(name: 'store_address')
  String? store_address;

  @JsonKey(name: 'store_telephone')
  String? store_telephone;

  @JsonKey(name: 'product_type')
  String? product_type;

  int? amount;
  String? status;
  String? payment;

  @JsonKey(name: 'payment_key')
  String? payment_key;

  @JsonKey(
      name: 'created_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? created_at;

  @JsonKey(defaultValue: [])
  List<OrderDetailGifticon> gifticons;

  @JsonKey(name: 'gifticon_count')
  int? gifticon_count;

  OrderDetailResponse({
    this.order_id,
    this.order_no,
    this.user_id,
    this.store_id,
    this.store_name,
    this.store_address,
    this.store_telephone,
    this.product_type,
    this.amount,
    this.status,
    this.payment,
    this.payment_key,
    this.created_at,
    this.gifticons = const [],
    this.gifticon_count,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailResponseToJson(this);

  static DateTime? _dateTimeFromJson(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String? _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

@JsonSerializable()
class GetOrderDetailResponse {
  @JsonKey(name: 'order_detail')
  OrderDetailResponse order_detail;

  GetOrderDetailResponse({required this.order_detail});

  factory GetOrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GetOrderDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetOrderDetailResponseToJson(this);
}
