// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_gifticon_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkGifticonRequest _$LinkGifticonRequestFromJson(Map<String, dynamic> json) =>
    LinkGifticonRequest(
      user_id: (json['user_id'] as num).toInt(),
      gifticon_id: (json['gifticon_id'] as num).toInt(),
      receiver_phone: json['receiver_phone'] as String,
    );

Map<String, dynamic> _$LinkGifticonRequestToJson(
        LinkGifticonRequest instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'gifticon_id': instance.gifticon_id,
      'receiver_phone': instance.receiver_phone,
    };
