// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifticon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gifticon _$GifticonFromJson(Map<String, dynamic> json) => Gifticon(
      order_id: (json['order_id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? "",
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? "",
      sender: json['sender'] as String? ?? "",
      receiver: json['receiver'] as String? ?? "",
      use_yn: (json['use_yn'] as num?)?.toInt() ?? 1,
      availability: (json['availability'] as num?)?.toInt() ?? 0,
      menu_url: json['menu_url'] as String? ?? "",
    )..validity = json['validity'] == null
        ? null
        : DateTime.parse(json['validity'] as String);

Map<String, dynamic> _$GifticonToJson(Gifticon instance) => <String, dynamic>{
      'order_id': instance.order_id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'validity': instance.validity?.toIso8601String(),
      'sender': instance.sender,
      'receiver': instance.receiver,
      'use_yn': instance.use_yn,
      'availability': instance.availability,
      'menu_url': instance.menu_url,
    };

GifticonListResponse _$GifticonListResponseFromJson(
        Map<String, dynamic> json) =>
    GifticonListResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      gifticonList: (json['gifticonList'] as List<dynamic>)
          .map((e) => Gifticon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GifticonListResponseToJson(
        GifticonListResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'gifticonList': instance.gifticonList,
    };
