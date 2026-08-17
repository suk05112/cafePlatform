import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  @JsonKey(name: 'order_id')
  int order_id;

  @JsonKey(name: 'store_id')
  int store_id;

  @JsonKey(name: 'order_number')
  String order_number;

  String sender;

  @JsonKey(name: 'created_time', fromJson: _dateTimeFromJson)
  DateTime created_time;

  int price;

  @JsonKey(name: 'menu_name')
  String menu_name;

  @JsonKey(name: 'menu_url')
  String? menu_url;

  String status;

  @JsonKey(name: 'product_type')
  String? product_type;

  Order(
      {required this.order_id,
      required this.store_id,
      required this.order_number,
      required this.sender,
      required this.created_time,
      required this.price,
      required this.menu_name,
      this.menu_url,
      required this.status,
      this.product_type});

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  static DateTime _dateTimeFromJson(dynamic dateTime) {
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    } else if (dateTime is int) {
      // Unix timestamp인 경우
      return DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
    }
    return DateTime.now();
  }
}

class OrderDetail {
  int order_id;
  int store_id;
  int order_number;
  int price;
  String name;
  int status; // 주문상태
  DateTime created_time;
  String payment; // 결제ㅇ식
  bool inCancelled;

  OrderDetail({
    required this.order_id,
    required this.store_id,
    required this.order_number,
    required this.price,
    required this.name,
    required this.status,
    required this.created_time,
    required this.payment,
    required this.inCancelled,
  });
}
