import 'package:json_annotation/json_annotation.dart';

part 'order_status_response.g.dart';

@JsonSerializable()
class OrderStatusResponse {
  @JsonKey(name: 'order_id')
  int order_id;

  String status;

  OrderStatusResponse({
    required this.order_id,
    required this.status,
  });

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderStatusResponseToJson(this);
}
