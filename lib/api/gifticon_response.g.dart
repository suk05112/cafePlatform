// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifticon_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseGifticonResponse _$PurchaseGifticonResponseFromJson(
        Map<String, dynamic> json) =>
    PurchaseGifticonResponse(
      order_id: json['order_id'] as int,
      gifticon_id: json['gifticon_id'] as int,
      order_no: json['order_no'] as String,
    );

Map<String, dynamic> _$PurchaseGifticonResponseToJson(
        PurchaseGifticonResponse instance) =>
    <String, dynamic>{
      'order_id': instance.order_id,
      'gifticon_id': instance.gifticon_id,
      'order_no': instance.order_no,
    };

PaymentResultRequest _$PaymentResultRequestFromJson(
        Map<String, dynamic> json) =>
    PaymentResultRequest(
      order_id: json['order_id'] as int,
      payment_key: json['payment_key'] as String?,
      is_success: json['is_success'] as bool,
    );

Map<String, dynamic> _$PaymentResultRequestToJson(
        PaymentResultRequest instance) =>
    <String, dynamic>{
      'order_id': instance.order_id,
      'payment_key': instance.payment_key,
      'is_success': instance.is_success,
    };

GetGifticonResponse _$GetGifticonResponseFromJson(Map<String, dynamic> json) =>
    GetGifticonResponse(
      gifticon: Gifticon.fromJson(json['gifticon'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetGifticonResponseToJson(
        GetGifticonResponse instance) =>
    <String, dynamic>{
      'gifticon': instance.gifticon,
    };
