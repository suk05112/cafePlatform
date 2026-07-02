// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeListItem _$NoticeListItemFromJson(Map<String, dynamic> json) =>
    NoticeListItem(
      id: json['id'] as int,
      title: json['title'] as String,
      created_at: json['created_at'] as String,
    );

Map<String, dynamic> _$NoticeListItemToJson(NoticeListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.created_at,
    };

NoticePagination _$NoticePaginationFromJson(Map<String, dynamic> json) =>
    NoticePagination(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      total_pages: json['total_pages'] as int,
    );

Map<String, dynamic> _$NoticePaginationToJson(NoticePagination instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'total_pages': instance.total_pages,
    };

UserNoticeListResponse _$UserNoticeListResponseFromJson(
        Map<String, dynamic> json) =>
    UserNoticeListResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => NoticeListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          NoticePagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserNoticeListResponseToJson(
        UserNoticeListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
      'pagination': instance.pagination,
    };

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

UserNoticeDetailResponse _$UserNoticeDetailResponseFromJson(
        Map<String, dynamic> json) =>
    UserNoticeDetailResponse(
      message: json['message'] as String,
      data: UserNotice.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserNoticeDetailResponseToJson(
        UserNoticeDetailResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };
