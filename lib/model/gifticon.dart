import 'package:json_annotation/json_annotation.dart';

part 'gifticon.g.dart';

@JsonSerializable()
class Gifticon {
  int gifticon_id;
  int order_id;
  @JsonKey(name: 'order_no')
  String? order_no;
  @JsonKey(name: 'payment_key')
  String? paymentKey;
  @JsonKey(name: 'gift_code')
  String? gift_code;
  String name;
  int total_price;
  String description;
  DateTime? validity; // 1: 유효기간 만료, 2:
  @JsonKey(name: 'purchaser_refund_deadline')
  DateTime? purchaserRefundDeadline; // 구매자 100% 환불 마감일 (발급 시점 정책 고정값, null=환불불가)
  String sender;
  String receiver;
  String? menu_url;
  int? menu_id;
  @JsonKey(name: 'status')
  String? status; // 'UNUSED', 'USED', 'EXPIRED', 'CANCELED'
  int? type;
  String? receiver_phone_number;
  int? store_id;
  String? payment;
  String? msg;
  DateTime? created_time;
  double store_lat;
  double store_lng;
  String store_name;
  @JsonKey(name: 'store_address')
  String? store_address;

  // Gifticon({this.order_id = 0,});
  Gifticon(
      {this.gifticon_id = 0,
      this.order_id = 0,
      this.order_no,
      this.gift_code,
      this.name = "",
      this.total_price = 0,
      this.description = "",
      // this.validity = DateTime(2020, 1, 1, 1, 1),
      this.sender = "",
      this.receiver = "",
      this.menu_url = "",
      this.menu_id,
      this.receiver_phone_number,
      this.status,
      this.type,
      this.store_id,
      this.validity,
      this.purchaserRefundDeadline,
      this.payment,
      this.msg,
      this.created_time,
      this.store_lat = 0.0,
      this.store_lng = 0.0,
      this.store_name = "",
      this.store_address});

  factory Gifticon.fromJson(Map<String, dynamic> json) =>
      _$GifticonFromJson(json);
  Map<String, dynamic> toJson() => _$GifticonToJson(this);
}

@JsonSerializable()
class GifticonListResponse {
  List<Gifticon> gifticonList;

  GifticonListResponse({required this.gifticonList});

  factory GifticonListResponse.fromJson(Map<String, dynamic> json) =>
      _$GifticonListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GifticonListResponseToJson(this);
}
