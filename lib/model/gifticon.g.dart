// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifticon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gifticon _$GifticonFromJson(Map<String, dynamic> json) => Gifticon(
      gifticon_id: json['gifticon_id'] as int? ?? 0,
      order_id: json['order_id'] as int? ?? 0,
      order_no: json['order_no'] as String?,
      gift_code: json['gift_code'] as String?,
      name: json['name'] as String? ?? "",
      total_price: json['total_price'] as int? ?? 0,
      description: json['description'] as String? ?? "",
      sender: json['sender'] as String? ?? "",
      receiver: json['receiver'] as String? ?? "",
      menu_url: json['menu_url'] as String? ?? "",
      menu_id: json['menu_id'] as int?,
      receiver_phone_number: json['receiver_phone_number'] as String?,
      status: json['status'] as String?,
      type: json['type'] as int?,
      store_id: json['store_id'] as int?,
      validity: json['validity'] == null
          ? null
          : DateTime.parse(json['validity'] as String),
      payment: json['payment'] as String?,
      msg: json['msg'] as String?,
      created_time: json['created_time'] == null
          ? null
          : DateTime.parse(json['created_time'] as String),
      store_lat: (json['store_lat'] as num?)?.toDouble() ?? 0.0,
      store_lng: (json['store_lng'] as num?)?.toDouble() ?? 0.0,
      store_name: json['store_name'] as String? ?? "",
    )..paymentKey = json['payment_key'] as String?;

Map<String, dynamic> _$GifticonToJson(Gifticon instance) => <String, dynamic>{
      'gifticon_id': instance.gifticon_id,
      'order_id': instance.order_id,
      'order_no': instance.order_no,
      'payment_key': instance.paymentKey,
      'gift_code': instance.gift_code,
      'name': instance.name,
      'total_price': instance.total_price,
      'description': instance.description,
      'validity': instance.validity?.toIso8601String(),
      'sender': instance.sender,
      'receiver': instance.receiver,
      'menu_url': instance.menu_url,
      'menu_id': instance.menu_id,
      'status': instance.status,
      'type': instance.type,
      'receiver_phone_number': instance.receiver_phone_number,
      'store_id': instance.store_id,
      'payment': instance.payment,
      'msg': instance.msg,
      'created_time': instance.created_time?.toIso8601String(),
      'store_lat': instance.store_lat,
      'store_lng': instance.store_lng,
      'store_name': instance.store_name,
    };

GifticonListResponse _$GifticonListResponseFromJson(
        Map<String, dynamic> json) =>
    GifticonListResponse(
      gifticonList: (json['gifticonList'] as List<dynamic>)
          .map((e) => Gifticon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GifticonListResponseToJson(
        GifticonListResponse instance) =>
    <String, dynamic>{
      'gifticonList': instance.gifticonList,
    };
