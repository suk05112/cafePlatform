// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifnut_image_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GifnutImageUrlResponse _$GifnutImageUrlResponseFromJson(
        Map<String, dynamic> json) =>
    GifnutImageUrlResponse(
      url: json['url'] as String,
      bucket: json['bucket'] as String,
      objectKey: json['key'] as String,
      expiresIn: json['expires_in'] as int,
      expiresInHours: (json['expires_in_hours'] as num).toDouble(),
    );

Map<String, dynamic> _$GifnutImageUrlResponseToJson(
        GifnutImageUrlResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
      'bucket': instance.bucket,
      'key': instance.objectKey,
      'expires_in': instance.expiresIn,
      'expires_in_hours': instance.expiresInHours,
    };
