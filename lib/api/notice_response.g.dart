// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotice _$UserNoticeFromJson(Map<String, dynamic> json) => UserNotice(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserNoticeToJson(UserNotice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };

UserNoticeListResponse _$UserNoticeListResponseFromJson(
        Map<String, dynamic> json) =>
    UserNoticeListResponse(
      notices: (json['notices'] as List<dynamic>)
          .map((e) => UserNotice.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$UserNoticeListResponseToJson(
        UserNoticeListResponse instance) =>
    <String, dynamic>{
      'notices': instance.notices,
      'total': instance.total,
    };
