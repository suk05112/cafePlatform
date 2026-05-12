// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentUrlResponse _$PaymentUrlResponseFromJson(Map<String, dynamic> json) =>
    PaymentUrlResponse(
      orderId: json['order_id'] as int,
      orderNo: _toString(json['order_no']),
      gifticonId: json['gifticon_id'] as int,
      onlineUrl: json['online_url'] as String,
      mobileUrl: json['mobile_url'] as String,
      token: _toString(json['token']),
    );

Map<String, dynamic> _$PaymentUrlResponseToJson(PaymentUrlResponse instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'order_no': instance.orderNo,
      'gifticon_id': instance.gifticonId,
      'online_url': instance.onlineUrl,
      'mobile_url': instance.mobileUrl,
      'token': instance.token,
    };
