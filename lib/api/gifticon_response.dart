import 'package:json_annotation/json_annotation.dart';
import 'package:cafeplatform/model/gifticon.dart';

part 'gifticon_response.g.dart';

@JsonSerializable()
class PurchaseGifticonResponse {
  @JsonKey(name: 'order_id')
  int order_id;

  @JsonKey(name: 'gifticon_id')
  int gifticon_id;

  @JsonKey(name: 'order_no')
  String order_no;

  PurchaseGifticonResponse({
    required this.order_id,
    required this.gifticon_id,
    required this.order_no,
  });

  factory PurchaseGifticonResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseGifticonResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseGifticonResponseToJson(this);
}

@JsonSerializable()
class PaymentResultRequest {
  @JsonKey(name: 'order_id')
  int order_id;

  @JsonKey(name: 'payment_key')
  String? payment_key;

  @JsonKey(name: 'is_success')
  bool is_success;

  PaymentResultRequest({
    required this.order_id,
    this.payment_key,
    required this.is_success,
  });

  factory PaymentResultRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$PaymentResultRequestToJson(this);
    // is_success가 false이면 payment_key를 null로 설정 (또는 제거)
    if (!is_success) {
      json['payment_key'] = null;
    }
    return json;
  }
}

@JsonSerializable()
class GetGifticonResponse {
  Gifticon gifticon;

  GetGifticonResponse({required this.gifticon});

  factory GetGifticonResponse.fromJson(Map<String, dynamic> json) =>
      _$GetGifticonResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetGifticonResponseToJson(this);
}
