// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PopupItem _$PopupItemFromJson(Map<String, dynamic> json) => PopupItem(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      linkUrl: json['link_url'] as String?,
      displayOrder: json['display_order'] as int,
    );

Map<String, dynamic> _$PopupItemToJson(PopupItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image_url': instance.imageUrl,
      'link_url': instance.linkUrl,
      'display_order': instance.displayOrder,
    };

PopupListResponse _$PopupListResponseFromJson(Map<String, dynamic> json) =>
    PopupListResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => PopupItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PopupListResponseToJson(PopupListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };
