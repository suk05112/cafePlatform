// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionResponse _$AppVersionResponseFromJson(Map<String, dynamic> json) =>
    AppVersionResponse(
      version: json['version'] as String?,
      isForceUpdate: json['is_force_update'] as bool,
    );

Map<String, dynamic> _$AppVersionResponseToJson(AppVersionResponse instance) =>
    <String, dynamic>{
      'version': instance.version,
      'is_force_update': instance.isForceUpdate,
    };
