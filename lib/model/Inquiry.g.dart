// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Inquiry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inquiry _$InquiryFromJson(Map<String, dynamic> json) => Inquiry(
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$InquiryToJson(Inquiry instance) => <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
    };

InquiryPostResponse _$InquiryPostResponseFromJson(Map<String, dynamic> json) =>
    InquiryPostResponse();

Map<String, dynamic> _$InquiryPostResponseToJson(
        InquiryPostResponse instance) =>
    <String, dynamic>{};

InquiryResponse _$InquiryResponseFromJson(Map<String, dynamic> json) =>
    InquiryResponse(
      title: json['title'] as String,
      content: json['content'] as String,
      response: json['response'] as String?,
      status: json['status'] as String,
      inquiry_created: DateTime.parse(json['inquiry_created'] as String),
      response_created: json['response_created'] == null
          ? null
          : DateTime.parse(json['response_created'] as String),
    );

Map<String, dynamic> _$InquiryResponseToJson(InquiryResponse instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'response': instance.response,
      'status': instance.status,
      'inquiry_created': instance.inquiry_created.toIso8601String(),
      'response_created': instance.response_created?.toIso8601String(),
    };

InquiryListResponse _$InquiryListResponseFromJson(Map<String, dynamic> json) =>
    InquiryListResponse(
      inquiryResponse: (json['inquiry_list'] as List<dynamic>)
          .map((e) => InquiryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InquiryListResponseToJson(
        InquiryListResponse instance) =>
    <String, dynamic>{
      'inquiry_list': instance.inquiryResponse,
    };
