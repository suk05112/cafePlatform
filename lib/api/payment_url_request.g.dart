// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_url_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentUrlRequest _$PaymentUrlRequestFromJson(Map<String, dynamic> json) =>
    PaymentUrlRequest(
      type: json['type'] as int,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String,
      receiverPhoneNumber: json['receiver_phone_number'] as String,
      menuId: json['menu_id'] as int,
      storeId: json['store_id'] as int,
      totalPrice: json['total_price'] as int,
      pgcode: json['pgcode'] as String,
      payment: json['payment'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
    );

Map<String, dynamic> _$PaymentUrlRequestToJson(PaymentUrlRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'receiver_phone_number': instance.receiverPhoneNumber,
      'menu_id': instance.menuId,
      'store_id': instance.storeId,
      'total_price': instance.totalPrice,
      'pgcode': instance.pgcode,
      'payment': instance.payment,
      'idempotency_key': instance.idempotencyKey,
    };
