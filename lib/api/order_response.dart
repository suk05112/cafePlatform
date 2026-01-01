import 'package:json_annotation/json_annotation.dart';
import 'package:cafeplatform/model/order.dart';

part 'order_response.g.dart';

@JsonSerializable()
class OrderListResponse {
  @JsonKey(name: 'order_list', defaultValue: [])
  List<Order> orderList;

  OrderListResponse({required this.orderList});

  factory OrderListResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderListResponseToJson(this);
}
