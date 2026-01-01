// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailGifticon _$OrderDetailGifticonFromJson(Map<String, dynamic> json) =>
    OrderDetailGifticon(
      gifticon_id: (json['gifticon_id'] as num?)?.toInt(),
      gift_code: json['gift_code'] as String?,
      type: (json['type'] as num?)?.toInt(),
      sender: json['sender'] as String?,
      receiver: json['receiver'] as String?,
      receiver_phone: json['receiver_phone'] as String?,
      status: json['status'] as String?,
      validity:
          OrderDetailGifticon._dateTimeFromJson(json['validity'] as String?),
      menu_id: (json['menu_id'] as num?)?.toInt(),
      menu_name: json['menu_name'] as String?,
      menu_price: (json['menu_price'] as num?)?.toInt(),
      menu_url: json['menu_url'] as String?,
      created_at:
          OrderDetailGifticon._dateTimeFromJson(json['created_at'] as String?),
      is_receiver_linked: json['is_receiver_linked'] as bool?,
    );

Map<String, dynamic> _$OrderDetailGifticonToJson(
        OrderDetailGifticon instance) =>
    <String, dynamic>{
      'gifticon_id': instance.gifticon_id,
      'gift_code': instance.gift_code,
      'type': instance.type,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'receiver_phone': instance.receiver_phone,
      'status': instance.status,
      'validity': OrderDetailGifticon._dateTimeToJson(instance.validity),
      'menu_id': instance.menu_id,
      'menu_name': instance.menu_name,
      'menu_price': instance.menu_price,
      'menu_url': instance.menu_url,
      'created_at': OrderDetailGifticon._dateTimeToJson(instance.created_at),
      'is_receiver_linked': instance.is_receiver_linked,
    };

OrderDetailResponse _$OrderDetailResponseFromJson(Map<String, dynamic> json) =>
    OrderDetailResponse(
      order_id: (json['order_id'] as num?)?.toInt(),
      order_no: json['order_no'] as String?,
      user_id: (json['user_id'] as num?)?.toInt(),
      store_id: (json['store_id'] as num?)?.toInt(),
      store_name: json['store_name'] as String?,
      store_address: json['store_address'] as String?,
      store_telephone: json['store_telephone'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      status: json['status'] as String?,
      payment: json['payment'] as String?,
      payment_key: json['payment_key'] as String?,
      created_at:
          OrderDetailResponse._dateTimeFromJson(json['created_at'] as String?),
      gifticons: (json['gifticons'] as List<dynamic>?)
              ?.map((e) =>
                  OrderDetailGifticon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gifticon_count: (json['gifticon_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderDetailResponseToJson(
        OrderDetailResponse instance) =>
    <String, dynamic>{
      'order_id': instance.order_id,
      'order_no': instance.order_no,
      'user_id': instance.user_id,
      'store_id': instance.store_id,
      'store_name': instance.store_name,
      'store_address': instance.store_address,
      'store_telephone': instance.store_telephone,
      'amount': instance.amount,
      'status': instance.status,
      'payment': instance.payment,
      'payment_key': instance.payment_key,
      'created_at': OrderDetailResponse._dateTimeToJson(instance.created_at),
      'gifticons': instance.gifticons,
      'gifticon_count': instance.gifticon_count,
    };

GetOrderDetailResponse _$GetOrderDetailResponseFromJson(
        Map<String, dynamic> json) =>
    GetOrderDetailResponse(
      order_detail: OrderDetailResponse.fromJson(
          json['order_detail'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetOrderDetailResponseToJson(
        GetOrderDetailResponse instance) =>
    <String, dynamic>{
      'order_detail': instance.order_detail,
    };
