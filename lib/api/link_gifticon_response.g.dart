// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_gifticon_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkGifticonResponse _$LinkGifticonResponseFromJson(
        Map<String, dynamic> json) =>
    LinkGifticonResponse(
      message: json['message'] as String,
      gifticon_id: json['gifticon_id'] as int,
      user_id: json['user_id'] as int,
    );

Map<String, dynamic> _$LinkGifticonResponseToJson(
        LinkGifticonResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'gifticon_id': instance.gifticon_id,
      'user_id': instance.user_id,
    };
