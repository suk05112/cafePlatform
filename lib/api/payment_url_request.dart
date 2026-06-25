import 'package:json_annotation/json_annotation.dart';

part 'payment_url_request.g.dart';

@JsonSerializable()
class PaymentUrlRequest {
  final int type;
  final String sender;
  final String receiver;
  @JsonKey(name: 'receiver_phone_number')
  final String receiverPhoneNumber;
  @JsonKey(name: 'menu_id')
  final int menuId;
  @JsonKey(name: 'store_id')
  final int storeId;
  @JsonKey(name: 'total_price')
  final int totalPrice;
  final String pgcode;
  final String? payment;
  @JsonKey(name: 'idempotency_key')
  final String? idempotencyKey;

  PaymentUrlRequest({
    required this.type,
    required this.sender,
    required this.receiver,
    required this.receiverPhoneNumber,
    required this.menuId,
    required this.storeId,
    required this.totalPrice,
    required this.pgcode,
    this.payment,
    this.idempotencyKey,
  });

  factory PaymentUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentUrlRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentUrlRequestToJson(this);
}
