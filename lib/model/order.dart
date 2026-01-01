import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  int order_id;
  int store_id;
  int order_number;
  String sender;
  DateTime created_time;
  int price;
  String menu_name;
  String status;

  Order(
      {required this.order_id,
      required this.store_id,
      required this.order_number,
      required this.sender,
      required this.created_time,
      required this.price,
      required this.menu_name,
      required this.status});

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
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
