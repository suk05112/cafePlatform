import 'package:json_annotation/json_annotation.dart';

part 'payment_url_response.g.dart';

@JsonSerializable()
class PaymentUrlResponse {
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'order_no', fromJson: _toString)
  final String orderNo;
  @JsonKey(name: 'gifticon_id')
  final int gifticonId;
  @JsonKey(name: 'online_url')
  final String onlineUrl;
  @JsonKey(name: 'mobile_url')
  final String mobileUrl;
  @JsonKey(fromJson: _toString)
  final String token;

  PaymentUrlResponse({
    required this.orderId,
    required this.orderNo,
    required this.gifticonId,
    required this.onlineUrl,
    required this.mobileUrl,
    required this.token,
  });

  factory PaymentUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentUrlResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentUrlResponseToJson(this);
}

String _toString(dynamic v) => v?.toString() ?? '';
